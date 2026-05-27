import { WaitlistForm } from "../../components/waitlist-form";

export default async function WaitlistPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string }>;
}) {
  const params = await searchParams;
  return (
    <section className="py-20">
      <div className="container grid gap-10 lg:grid-cols-[0.9fr_1.1fr]">
        <div>
          <div className="pill bg-[#126BFF]/10 text-[#126BFF]">License waitlist</div>
          <h1 className="mt-6 text-5xl font-bold">Get notified when Pasus licensing opens.</h1>
          <p className="mt-5 leading-8 text-[#5B6678]">
            Licenses are not available yet. Waitlist storage uses local JSONL in development or a configured backend path in production.
          </p>
        </div>
        <WaitlistForm status={params.status} />
      </div>
    </section>
  );
}
