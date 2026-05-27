export type ReleaseAsset = {
  name: string;
  url: string;
};

export function DownloadCard({ assets }: { assets: ReleaseAsset[] }) {
  const msi = assets.find((asset) => asset.name.endsWith(".msi"));
  const exe = assets.find((asset) => asset.name.endsWith(".exe"));
  return (
    <div className="card p-7">
      <h2 className="text-2xl font-bold">Windows preview installer</h2>
      <p className="mt-3 leading-7 text-[#5B6678]">Preview builds are for testing. Keep Microsoft Defender or your existing antivirus enabled.</p>
      <div className="mt-6 flex flex-wrap gap-3">
        {exe ? <a className="rounded-full bg-[#126BFF] px-5 py-3 font-bold text-white" href={exe.url}>Download EXE setup</a> : null}
        {msi ? <a className="rounded-full border border-[#E1E7EF] px-5 py-3 font-bold" href={msi.url}>Download MSI</a> : null}
        {!exe && !msi ? <span className="pill bg-[#F5A524]/12 text-[#8A5A00]">Preview build unavailable.</span> : null}
      </div>
      <p className="mt-6 text-sm text-[#5B6678]">Checksums are published by the release workflow when available. Verify downloaded installers before testing.</p>
    </div>
  );
}
