use std::path::PathBuf;

#[derive(Debug, Clone)]
pub struct EngineConfig {
    pub signature_pack_path: PathBuf,
    pub rule_pack_path: PathBuf,
    pub ml_model_path: PathBuf,
    pub trust_store_path: PathBuf,
    pub quarantine_dir: PathBuf,
    pub compatibility_engines_enabled: bool,
}

impl EngineConfig {
    pub fn from_repo_root(root: impl Into<PathBuf>) -> Self {
        let root = root.into();
        Self {
            signature_pack_path: root
                .join("assets")
                .join("zentor_native")
                .join("signatures")
                .join("zentor_core.zsig"),
            rule_pack_path: root
                .join("assets")
                .join("zentor_native")
                .join("rules")
                .join("zentor_rules.zrule"),
            ml_model_path: root
                .join("assets")
                .join("zentor_native")
                .join("ml")
                .join("zentor_native_model.zmodel"),
            trust_store_path: root
                .join("assets")
                .join("zentor_native")
                .join("trust")
                .join("zentor_known_good.ztrust"),
            quarantine_dir: std::env::temp_dir().join("zentor-native-quarantine"),
            compatibility_engines_enabled: false,
        }
    }
}

impl Default for EngineConfig {
    fn default() -> Self {
        let root = std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
        Self::from_repo_root(root)
    }
}
