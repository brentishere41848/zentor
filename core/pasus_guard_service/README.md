# Pasus Guard Service

Pasus Guard Service is the user-mode real-time protection helper.

Windows v1 behavior is best-effort post-launch protection:

- Receives or observes process start events.
- Checks local allowlist/known threat hash state.
- Stops confirmed threat processes where the OS allows it.
- Moves confirmed threat executables to local quarantine.
- Writes visible events for the UI.

It does not claim kernel-level or true pre-execution blocking. Full on-access blocking requires a future signed minifilter driver.
