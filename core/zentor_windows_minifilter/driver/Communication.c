#include "ZentorAvFilter.h"

static NTSTATUS
ZentorPortConnect(
    _In_ PFLT_PORT ClientPort,
    _In_opt_ PVOID ServerPortCookie,
    _In_reads_bytes_opt_(SizeOfContext) PVOID ConnectionContext,
    _In_ ULONG SizeOfContext,
    _Outptr_result_maybenull_ PVOID *ConnectionCookie
    )
{
    UNREFERENCED_PARAMETER(ServerPortCookie);
    UNREFERENCED_PARAMETER(ConnectionContext);
    UNREFERENCED_PARAMETER(SizeOfContext);
    UNREFERENCED_PARAMETER(ConnectionCookie);

    ZentorGlobals.ClientPort = ClientPort;
    return STATUS_SUCCESS;
}

static VOID
ZentorPortDisconnect(_In_opt_ PVOID ConnectionCookie)
{
    UNREFERENCED_PARAMETER(ConnectionCookie);

    if (ZentorGlobals.ClientPort != NULL) {
        FltCloseClientPort(ZentorGlobals.Filter, &ZentorGlobals.ClientPort);
        ZentorGlobals.ClientPort = NULL;
    }
}

static NTSTATUS
ZentorPortMessage(
    _In_opt_ PVOID PortCookie,
    _In_reads_bytes_opt_(InputBufferLength) PVOID InputBuffer,
    _In_ ULONG InputBufferLength,
    _Out_writes_bytes_to_opt_(OutputBufferLength, *ReturnOutputBufferLength) PVOID OutputBuffer,
    _In_ ULONG OutputBufferLength,
    _Out_ PULONG ReturnOutputBufferLength
    )
{
    UNREFERENCED_PARAMETER(PortCookie);
    UNREFERENCED_PARAMETER(InputBuffer);
    UNREFERENCED_PARAMETER(InputBufferLength);
    UNREFERENCED_PARAMETER(OutputBuffer);
    UNREFERENCED_PARAMETER(OutputBufferLength);

    *ReturnOutputBufferLength = 0;
    return STATUS_SUCCESS;
}

NTSTATUS
ZentorCreateCommunicationPort(_In_ PDRIVER_OBJECT DriverObject)
{
    NTSTATUS status;
    UNICODE_STRING portName;
    OBJECT_ATTRIBUTES objectAttributes;
    PSECURITY_DESCRIPTOR securityDescriptor = NULL;

    UNREFERENCED_PARAMETER(DriverObject);

    RtlInitUnicodeString(&portName, ZENTOR_FILTER_PORT_NAME);

    status = FltBuildDefaultSecurityDescriptor(&securityDescriptor, FLT_PORT_ALL_ACCESS);
    if (!NT_SUCCESS(status)) {
        return status;
    }

    InitializeObjectAttributes(
        &objectAttributes,
        &portName,
        OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE,
        NULL,
        securityDescriptor);

    status = FltCreateCommunicationPort(
        ZentorGlobals.Filter,
        &ZentorGlobals.ServerPort,
        &objectAttributes,
        NULL,
        ZentorPortConnect,
        ZentorPortDisconnect,
        ZentorPortMessage,
        1);

    FltFreeSecurityDescriptor(securityDescriptor);
    return status;
}

VOID
ZentorCloseCommunicationPort(VOID)
{
    if (ZentorGlobals.ClientPort != NULL) {
        FltCloseClientPort(ZentorGlobals.Filter, &ZentorGlobals.ClientPort);
        ZentorGlobals.ClientPort = NULL;
    }
    if (ZentorGlobals.ServerPort != NULL) {
        FltCloseCommunicationPort(ZentorGlobals.ServerPort);
        ZentorGlobals.ServerPort = NULL;
    }
}

NTSTATUS
ZentorSendScanRequest(
    _In_ PZENTOR_SCAN_REQUEST Request,
    _Out_ PZENTOR_SCAN_VERDICT Verdict
    )
{
    NTSTATUS status;
    LARGE_INTEGER timeout;
    ULONG replyLength = sizeof(ZENTOR_SCAN_VERDICT);

    RtlZeroMemory(Verdict, sizeof(ZENTOR_SCAN_VERDICT));
    Verdict->Version = 1;
    Verdict->RequestId = Request->RequestId;
    Verdict->Action = ZentorActionTimeoutAllow;
    Verdict->FinalVerdict = ZentorVerdictUnknown;
    Verdict->Confidence = ZentorConfidenceLow;

    if (ZentorGlobals.ClientPort == NULL) {
        return STATUS_PORT_DISCONNECTED;
    }

    timeout.QuadPart = -(10 * 1000 * (LONGLONG)ZentorGlobals.PreExecutionTimeoutMs);
    status = FltSendMessage(
        ZentorGlobals.Filter,
        &ZentorGlobals.ClientPort,
        Request,
        sizeof(ZENTOR_SCAN_REQUEST),
        Verdict,
        &replyLength,
        &timeout);

    if (status == STATUS_TIMEOUT) {
        Verdict->Action = ZentorActionTimeoutAllow;
        Verdict->FinalVerdict = ZentorVerdictUnknown;
        Verdict->Confidence = ZentorConfidenceLow;
    }

    return status;
}
