use std::env;
use std::net::SocketAddr;

#[derive(Debug, Clone)]
pub struct ApiConfig {
    pub bind_addr: SocketAddr,
    pub database_url: String,
    pub redis_url: String,
    pub dev_project_id: String,
    pub dev_public_game_key: String,
}

impl ApiConfig {
    pub fn from_env() -> anyhow::Result<Self> {
        let bind_addr = env::var("PASUS_API_BIND_ADDR")
            .unwrap_or_else(|_| "0.0.0.0:8080".to_string())
            .parse()?;
        let database_url = env::var("DATABASE_URL")
            .unwrap_or_else(|_| "postgres://pasus:pasus@localhost:5432/pasus".to_string());
        let redis_url =
            env::var("REDIS_URL").unwrap_or_else(|_| "redis://localhost:6379".to_string());
        let dev_project_id =
            env::var("PASUS_DEV_PROJECT_ID").unwrap_or_else(|_| "pasus-default".to_string());
        let dev_public_game_key = env::var("PASUS_DEV_PUBLIC_GAME_KEY")
            .unwrap_or_else(|_| "pasus-public-client".to_string());
        Ok(Self {
            bind_addr,
            database_url,
            redis_url,
            dev_project_id,
            dev_public_game_key,
        })
    }
}
