use anyhow::{bail, Result};
use chrono::Utc;
use serde_json::Value;

use super::pack_format::{SignaturePack, SignaturePackMetadata};
use super::pack_verifier::{broad_signature_count, is_broad, SIGNATURE_PACK_FORMAT};
use super::{NativeSignature, SignatureType};
use crate::engine::sha256_bytes;
use crate::verdict::{Confidence, Verdict};

pub fn validate_signatures(signatures: &[NativeSignature]) -> Result<()> {
    for signature in signatures {
        if signature.id.trim().is_empty()
            || signature.name.trim().is_empty()
            || signature.false_positive_notes.trim().is_empty()
        {
            bail!("signature {} is missing required metadata", signature.id);
        }
        if is_broad(signature) && signature.confidence != Confidence::Low {
            bail!(
                "broad signature {} must be low confidence/review-only",
                signature.id
            );
        }
        if matches!(signature.confidence, Confidence::Confirmed)
            && !matches!(
                signature.signature_type,
                SignatureType::ExactHash | SignatureType::EicarTestSignature
            )
            && signature.action_policy != "quarantine_if_policy_allows"
            && signature.action_policy != "block_or_quarantine_if_policy_allows"
        {
            bail!(
                "confirmed signature {} must use an explicit blocking/quarantine policy",
                signature.id
            );
        }
        if signature.file_types.is_empty() {
            bail!("signature {} must declare file_types", signature.id);
        }
        if signature.pattern.trim().is_empty() {
            bail!(
                "signature {} must include a non-empty pattern",
                signature.id
            );
        }
    }
    Ok(())
}

pub fn compile_pack(
    mut signatures: Vec<NativeSignature>,
    version: String,
) -> Result<(SignaturePack, SignaturePackMetadata)> {
    signatures.sort_by(|left, right| left.id.cmp(&right.id));
    validate_signatures(&signatures)?;
    let created_at = Utc::now();
    let mut pack = SignaturePack {
        format: SIGNATURE_PACK_FORMAT.to_string(),
        version: version.clone(),
        compiler_version: Some(env!("CARGO_PKG_VERSION").to_string()),
        created_at: Some(created_at),
        pack_sha256: None,
        signatures,
    };
    let canonical = canonical_pack_bytes(&pack)?;
    let pack_sha256 = sha256_bytes(&canonical);
    pack.pack_sha256 = Some(pack_sha256.clone());
    let metadata = SignaturePackMetadata {
        format: SIGNATURE_PACK_FORMAT.to_string(),
        version,
        compiler_version: env!("CARGO_PKG_VERSION").to_string(),
        signature_count: pack.signatures.len(),
        pack_sha256,
        created_at,
        broad_signature_count: broad_signature_count(&pack.signatures),
        confirmed_signature_count: pack
            .signatures
            .iter()
            .filter(|signature| signature.confidence == Confidence::Confirmed)
            .count(),
    };
    Ok((pack, metadata))
}

pub fn canonical_pack_bytes(pack: &SignaturePack) -> Result<Vec<u8>> {
    let mut value = serde_json::to_value(pack)?;
    if let Value::Object(object) = &mut value {
        object.remove("pack_sha256");
    }
    Ok(serde_json::to_vec(&value)?)
}

#[allow(dead_code)]
pub fn verdict_from_action_policy(action_policy: &str) -> Verdict {
    match action_policy {
        "quarantine_if_policy_allows" | "block_or_quarantine_if_policy_allows" => {
            Verdict::ConfirmedMalware
        }
        "review_or_block_by_policy" => Verdict::Suspicious,
        _ => Verdict::Observation,
    }
}
