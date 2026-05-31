use anyhow::{Context, Result};
use ed25519_dalek::{Signer, SigningKey};
use std::path::PathBuf;

fn main() -> Result<()> {
    let mut args = std::env::args().skip(1);
    let manifest_path = PathBuf::from(args.next().context("manifest path is required")?);
    let sig_path = PathBuf::from(args.next().context("signature output path is required")?);
    let private_key_hex = std::env::var("AVORAX_UPDATE_SIGNING_PRIVATE_KEY_HEX")
        .context("AVORAX_UPDATE_SIGNING_PRIVATE_KEY_HEX is required")?;
    let key_bytes = hex::decode(private_key_hex.trim()).context("invalid private key hex")?;
    anyhow::ensure!(
        key_bytes.len() == 32 || key_bytes.len() == 64,
        "Ed25519 private key must be a 32-byte seed or 64-byte expanded key"
    );
    let mut seed = [0_u8; 32];
    seed.copy_from_slice(&key_bytes[..32]);
    let signing_key = SigningKey::from_bytes(&seed);
    let manifest = std::fs::read(&manifest_path)
        .with_context(|| format!("failed to read {}", manifest_path.display()))?;
    let signature = signing_key.sign(&manifest);
    std::fs::write(&sig_path, hex::encode(signature.to_bytes()))
        .with_context(|| format!("failed to write {}", sig_path.display()))?;
    Ok(())
}
