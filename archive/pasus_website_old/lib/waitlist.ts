"use server";

import { mkdir, appendFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { redirect } from "next/navigation";

const useCases = new Set(["personal", "family", "business", "research"]);
const platforms = new Set(["windows", "macos", "linux", "mobile"]);

export async function joinWaitlist(formData: FormData) {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const useCase = String(formData.get("useCase") ?? "");
  const platform = String(formData.get("platform") ?? "");
  const consent = formData.get("consent") === "on";
  const website = String(formData.get("website") ?? "").trim();

  if (website) redirect("/waitlist?status=spam");
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    redirect("/waitlist?status=invalid-email");
  }
  if (!useCases.has(useCase) || !platforms.has(platform) || !consent) {
    redirect("/waitlist?status=invalid");
  }

  const configuredPath = process.env.PASUS_WAITLIST_JSONL;
  const storagePath =
    configuredPath ??
    (process.env.NODE_ENV === "development"
      ? join(process.cwd(), ".data", "waitlist.jsonl")
      : "");

  if (!storagePath) {
    redirect("/waitlist?status=backend-missing");
  }

  const entry = {
    email,
    useCase,
    platform,
    consent,
    createdAt: new Date().toISOString(),
  };

  try {
    await mkdir(dirname(storagePath), { recursive: true });
    await appendFile(storagePath, `${JSON.stringify(entry)}\n`, "utf8");
  } catch {
    redirect("/waitlist?status=storage-failed");
  }

  redirect("/waitlist?status=joined");
}
