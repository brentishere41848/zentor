#include "ZentorProcessGuard.h"

static BOOLEAN g_CallbackRegistered = FALSE;

NTSTATUS
DriverEntry(_In_ PDRIVER_OBJECT DriverObject, _In_ PUNICODE_STRING RegistryPath)
{
    NTSTATUS status;
    UNREFERENCED_PARAMETER(RegistryPath);

    DriverObject->DriverUnload = ZentorProcessGuardUnload;

    status = PsSetCreateProcessNotifyRoutineEx(ZentorProcessNotify, FALSE);
    if (NT_SUCCESS(status)) {
        g_CallbackRegistered = TRUE;
    }

    return status;
}

VOID
ZentorProcessGuardUnload(_In_ PDRIVER_OBJECT DriverObject)
{
    UNREFERENCED_PARAMETER(DriverObject);

    if (g_CallbackRegistered) {
        PsSetCreateProcessNotifyRoutineEx(ZentorProcessNotify, TRUE);
        g_CallbackRegistered = FALSE;
    }
}
