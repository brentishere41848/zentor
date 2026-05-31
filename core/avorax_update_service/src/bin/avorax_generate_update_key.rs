use anyhow::Result;
use ed25519_dalek::SigningKey;

fn main() -> Result<()> {
    let mut seed = [0_u8; 32];
    getrandom::getrandom(&mut seed)
        .map_err(|error| anyhow::anyhow!("failed to generate update key: {error}"))?;
    let signing_key = SigningKey::from_bytes(&seed);
    let verifying_key = signing_key.verifying_key();
    println!("private={}", hex::encode(seed));
    println!("public={}", hex::encode(verifying_key.to_bytes()));
    Ok(())
}
