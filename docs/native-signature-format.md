# Pasus Native Signature Format

Native signature packs use the `.psig` extension. The current v1 pack is JSON for auditability and validation; the compiler path can emit a compact binary pack later without changing runtime policy.

Default pack:

- `assets/pasus_native/signatures/pasus_core.psig`
- `assets/pasus_native/signatures/pasus_core.metadata.json`

Compiler:

```powershell
cargo run --manifest-path core\pasus_native_engine\Cargo.toml --bin pasus-signature-compiler -- `
  --input assets\pasus_native\signatures\pasus_core.psig `
  --output assets\pasus_native\signatures\pasus_core.psig `
  --metadata assets\pasus_native\signatures\pasus_core.metadata.json `
  --version 0.1.1
```

The compiler validates human-readable signature JSON, sorts signatures deterministically, writes a compiled `.psig` pack, and emits metadata with a canonical pack hash. Runtime loading verifies the pack format and the hash when present.

Signature types include:

- `exact_hash`
- `partial_hash`
- `byte_pattern`
- `masked_byte_pattern`
- `ascii_string`
- `utf16_string`
- `pe_import_combo`
- `pe_section_entropy`
- `pe_resource_indicator`
- `script_pattern`
- `powershell_encoded_command`
- `archive_nested_executable`
- `eicar_test_signature`

Every signature requires metadata, confidence, false-positive notes, file type filters, and an action policy. Broad signatures must be review-only unless additional context produces a stronger fused verdict. Confirmed signatures must use an explicit blocking or quarantine policy.

PNE detects the EICAR safe anti-malware test string internally, without ClamAV or YARA.
