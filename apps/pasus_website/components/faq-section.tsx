const faqs = [
  ["When will licenses be available?", "Licensing is not live yet. Join the waitlist to be notified when it opens."],
  ["Will Pasus work offline?", "Core scanning, quarantine, allowlist, and local review are designed to work offline."],
  ["Will Pasus replace my current antivirus?", "Do not replace your existing antivirus until Pasus is production validated."],
  ["What platforms are supported?", "Windows is the first priority. Other platforms may have limited features."],
  ["Is cloud required?", "No. Cloud features are optional for updates, reporting, and future licensing."],
  ["Can I use it without an account?", "Preview builds are designed to run local scans without an account."],
];

export function FaqSection() {
  return (
    <section className="py-20">
      <div className="container">
        <h2 className="text-4xl font-bold">Questions before release.</h2>
        <div className="mt-8 grid gap-4 md:grid-cols-2">
          {faqs.map(([question, answer]) => (
            <div key={question} className="card p-6">
              <h3 className="font-bold">{question}</h3>
              <p className="mt-3 leading-7 text-[#5B6678]">{answer}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
