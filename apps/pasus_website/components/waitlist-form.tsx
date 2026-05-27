import { joinWaitlist } from "../lib/waitlist";

export function WaitlistForm({ status }: { status?: string }) {
  const messages: Record<string, string> = {
    joined: "You are on the waitlist.",
    "backend-missing": "Waitlist backend not configured. No signup was saved.",
    "storage-failed": "Waitlist storage failed. No signup was saved.",
    invalid: "Please complete every field and consent checkbox.",
    "invalid-email": "Enter a valid email address.",
    spam: "Signup rejected.",
  };
  return (
    <form action={joinWaitlist} className="card grid gap-5 p-7">
      {status && <div className="rounded-2xl bg-[#F7F9FC] p-4 text-sm font-semibold">{messages[status] ?? status}</div>}
      <input name="website" className="hidden" tabIndex={-1} autoComplete="off" />
      <label className="grid gap-2 font-semibold">
        Email
        <input required name="email" type="email" className="rounded-2xl border border-[#E1E7EF] px-4 py-3" placeholder="you@example.com" />
      </label>
      <label className="grid gap-2 font-semibold">
        Use case
        <select required name="useCase" className="rounded-2xl border border-[#E1E7EF] px-4 py-3">
          <option value="personal">Personal device</option>
          <option value="family">Family</option>
          <option value="business">Small business</option>
          <option value="research">Testing/research</option>
        </select>
      </label>
      <label className="grid gap-2 font-semibold">
        Platform
        <select required name="platform" className="rounded-2xl border border-[#E1E7EF] px-4 py-3">
          <option value="windows">Windows</option>
          <option value="macos">macOS</option>
          <option value="linux">Linux</option>
          <option value="mobile">Android/iOS later</option>
        </select>
      </label>
      <label className="flex gap-3 text-sm text-[#5B6678]">
        <input required name="consent" type="checkbox" />
        <span>I agree to receive Pasus product updates.</span>
      </label>
      <button className="rounded-full bg-[#126BFF] px-6 py-4 font-bold text-white" type="submit">
        Join waitlist
      </button>
      <p className="text-xs leading-5 text-[#5B6678]">Waitlist email is used only for Pasus product updates. A production database is required before public launch.</p>
    </form>
  );
}
