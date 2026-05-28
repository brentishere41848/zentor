use std::env;
use std::fs;
use std::path::PathBuf;

use anyhow::{bail, Context, Result};
use zentor_native_engine::signatures::pack_format::SignaturePack;
use zentor_native_engine::signatures::signature_compiler;

fn main() -> Result<()> {
    let args = env::args().skip(1).collect::<Vec<_>>();
    if args.iter().any(|arg| arg == "--help" || arg == "-h") {
        print_help();
        return Ok(());
    }
    let input = value_after(&args, "--input").context("--input is required")?;
    let output = value_after(&args, "--output").context("--output is required")?;
    let metadata = value_after(&args, "--metadata").context("--metadata is required")?;
    let version = value_after(&args, "--version").unwrap_or_else(|| "0.1.0".to_string());

    let raw = fs::read_to_string(&input)
        .with_context(|| format!("failed to read signature source {input}"))?;
    let source_pack: SignaturePack = serde_json::from_str(&raw)
        .with_context(|| format!("failed to parse signature source {input}"))?;
    let (compiled_pack, compiled_metadata) =
        signature_compiler::compile_pack(source_pack.signatures, version)?;

    write_json(PathBuf::from(output), &compiled_pack)?;
    write_json(PathBuf::from(metadata), &compiled_metadata)?;
    Ok(())
}

fn value_after(args: &[String], key: &str) -> Option<String> {
    args.windows(2)
        .find(|pair| pair[0] == key)
        .map(|pair| pair[1].clone())
}

fn write_json<T: serde::Serialize>(path: PathBuf, value: &T) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    let json = serde_json::to_string_pretty(value)?;
    if json.trim().is_empty() {
        bail!("refusing to write empty compiler output");
    }
    fs::write(&path, format!("{json}\n"))
        .with_context(|| format!("failed to write {}", path.display()))?;
    Ok(())
}

fn print_help() {
    println!(
        "zentor-signature-compiler --input source.json --output zentor_core.zsig --metadata zentor_core.metadata.json [--version 0.1.0]"
    );
}
