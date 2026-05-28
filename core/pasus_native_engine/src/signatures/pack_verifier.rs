use anyhow::{bail, Result};

use super::pack_format::SignaturePack;
use super::{NativeSignature, SignatureType};
use crate::engine::sha256_bytes;

pub const SIGNATURE_PACK_FORMAT: &str = "pasus-signature-pack-v1";

pub fn verify_pack(pack: &SignaturePack, canonical_bytes: &[u8]) -> Result<()> {
    if pack.format != SIGNATURE_PACK_FORMAT {
        bail!("unsupported signature pack format {}", pack.format);
    }
    if pack.version.trim().is_empty() {
        bail!("signature pack version is required");
    }
    if let Some(expected) = pack.pack_sha256.as_deref() {
        let actual = sha256_bytes(canonical_bytes);
        if !expected.eq_ignore_ascii_case(&actual) {
            bail!("signature pack hash mismatch");
        }
    }
    Ok(())
}

pub fn broad_signature_count(signatures: &[NativeSignature]) -> usize {
    signatures
        .iter()
        .filter(|signature| is_broad(signature))
        .count()
}

pub fn is_broad(signature: &NativeSignature) -> bool {
    matches!(
        signature.signature_type,
        SignatureType::AsciiString
            | SignatureType::Utf16String
            | SignatureType::BytePattern
            | SignatureType::MaskedBytePattern
    ) && signature.pattern.replace([' ', '_'], "").len() < 12
}
