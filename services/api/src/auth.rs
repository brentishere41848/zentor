use async_trait::async_trait;
use axum::extract::FromRequestParts;
use axum::http::request::Parts;
use axum::http::StatusCode;
use sha2::{Digest, Sha256};
use sqlx::PgPool;
use uuid::Uuid;

use crate::AppState;

#[derive(Debug, Clone)]
pub struct ApiAuth {
    pub project_id: Uuid,
}

#[async_trait]
impl FromRequestParts<AppState> for ApiAuth {
    type Rejection = (StatusCode, &'static str);

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        let Some(header) = parts.headers.get(axum::http::header::AUTHORIZATION) else {
            return Err((StatusCode::UNAUTHORIZED, "missing authorization"));
        };
        let Ok(value) = header.to_str() else {
            return Err((StatusCode::UNAUTHORIZED, "invalid authorization"));
        };
        let Some(token) = value.strip_prefix("Bearer ") else {
            return Err((StatusCode::UNAUTHORIZED, "invalid authorization"));
        };
        authenticate_key(&state.db, token)
            .await
            .map(|project_id| ApiAuth { project_id })
            .map_err(|_| (StatusCode::UNAUTHORIZED, "invalid api key"))
    }
}

pub async fn authenticate_key(pool: &PgPool, token: &str) -> sqlx::Result<Uuid> {
    let key_hash = hash_api_key(token);
    let row: (Uuid,) = sqlx::query_as(
        "select project_id from api_keys where key_hash = $1 and revoked_at is null limit 1",
    )
    .bind(key_hash)
    .fetch_one(pool)
    .await?;
    Ok(row.0)
}

pub fn hash_api_key(token: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(token.as_bytes());
    format!("sha256:{:x}", hasher.finalize())
}
