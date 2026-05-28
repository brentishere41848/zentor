const items = [
  "v0.1 preview builds",
  "faster quick scan",
  "background service",
  "quarantine UI",
  "real-time guard",
  "driver validation",
  "licensing",
  "signed updates",
  "production AI model",
  "external validation",
];

export default function RoadmapPage() {
  return (
    <section className="py-20">
      <div className="container">
        <h1 className="text-5xl font-bold">Roadmap</h1>
        <p className="mt-5 max-w-3xl leading-8 text-[#5B6678]">
          This roadmap shows work in progress. It does not claim unfinished features are production-ready.
        </p>
        <div className="mt-10 grid gap-4 md:grid-cols-2">
          {items.map((item) => (
            <div key={item} className="card p-6 font-bold">{item}</div>
          ))}
        </div>
      </div>
    </section>
  );
}
