#pragma once

#include <ntddk.h>

#define ZENTOR_PROCESS_GUARD_DEVICE_NAME L"\\Device\\ZentorProcessGuard"
#define ZENTOR_PROCESS_GUARD_DOS_NAME L"\\DosDevices\\ZentorProcessGuard"

DRIVER_INITIALIZE DriverEntry;
DRIVER_UNLOAD ZentorProcessGuardUnload;

VOID
ZentorProcessNotify(
    _Inout_ PEPROCESS Process,
    _In_ HANDLE ProcessId,
    _Inout_opt_ PPS_CREATE_NOTIFY_INFO CreateInfo
    );
