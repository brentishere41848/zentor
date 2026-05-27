import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

const root = process.cwd();
const files = [];
function walk(dir) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    const stat = statSync(path);
    if (stat.isDirectory()) walk(path);
    else if (/\.(tsx|ts|md|css)$/.test(path)) files.push(path);
  }
}
walk(join(root, "app"));
walk(join(root, "components"));
walk(join(root, "lib"));

const text = files.map((file) => readFileSync(file, "utf8")).join("\n").toLowerCase();
const forbidden = [
  "anti-cheat",
  "fair play",
  "player session",
  "match telemetry",
  "fake checkout",
  "buy now",
  "certified by av-test",
  "100% protection",
  "perfect protection",
];
for (const phrase of forbidden) {
  if (text.includes(phrase)) {
    throw new Error(`Forbidden website phrase found: ${phrase}`);
  }
}
for (const route of ["app/page.tsx", "app/pricing/page.tsx", "app/download/page.tsx", "app/waitlist/page.tsx"]) {
  statSync(join(root, route));
}
console.log("Pasus website content tests passed.");
