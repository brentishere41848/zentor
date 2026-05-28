#include "ZentorAvFilter.h"

FLT_PREOP_CALLBACK_STATUS
ZentorPreCreate(
    _Inout_ PFLT_CALLBACK_DATA Data,
    _In_ PCFLT_RELATED_OBJECTS FltObjects,
    _Flt_CompletionContext_Outptr_ PVOID *CompletionContext
    )
{
    ZENTOR_SCAN_REQUEST request;
    ZENTOR_SCAN_VERDICT verdict;
    UNICODE_STRING requestName;
    NTSTATUS status;

    UNREFERENCED_PARAMETER(CompletionContext);

    if (ZentorGlobals.Mode == ZentorModeDisabled || ZentorGlobals.Mode == ZentorModeObserveOnly) {
        return FLT_PREOP_SUCCESS_NO_CALLBACK;
    }

    status = ZentorBuildScanRequest(Data, FltObjects, ZentorEventFileOpen, &request);
    if (!NT_SUCCESS(status)) {
        return FLT_PREOP_SUCCESS_NO_CALLBACK;
    }

    RtlInitUnicodeString(&requestName, request.FilePath);
    if (ZentorShouldExcludePath(&requestName)) {
        return FLT_PREOP_SUCCESS_NO_CALLBACK;
    }

    status = ZentorSendScanRequest(&request, &verdict);
    if (!NT_SUCCESS(status) && status != STATUS_TIMEOUT) {
        return FLT_PREOP_SUCCESS_NO_CALLBACK;
    }

    if (ZentorShouldBlockVerdict(&verdict)) {
        Data->IoStatus.Status = STATUS_ACCESS_DENIED;
        Data->IoStatus.Information = 0;
        return FLT_PREOP_COMPLETE;
    }

    return FLT_PREOP_SUCCESS_NO_CALLBACK;
}

FLT_PREOP_CALLBACK_STATUS
ZentorPreAcquireForSectionSync(
    _Inout_ PFLT_CALLBACK_DATA Data,
    _In_ PCFLT_RELATED_OBJECTS FltObjects,
    _Flt_CompletionContext_Outptr_ PVOID *CompletionContext
    )
{
    ZENTOR_SCAN_REQUEST request;
    ZENTOR_SCAN_VERDICT verdict;
    NTSTATUS status;

    UNREFERENCED_PARAMETER(CompletionContext);

    if (ZentorGlobals.Mode == ZentorModeDisabled || ZentorGlobals.Mode == ZentorModeObserveOnly) {
        return FLT_PREOP_SUCCESS_NO_CALLBACK;
    }

    if (Data->Iopb->Parameters.AcquireForSectionSynchronization.SyncType != SyncTypeCreateSection) {
        return FLT_PREOP_SUCCESS_NO_CALLBACK;
    }

    status = ZentorBuildScanRequest(Data, FltObjects, ZentorEventSectionCreateAttempt, &request);
    if (!NT_SUCCESS(status)) {
        return FLT_PREOP_SUCCESS_NO_CALLBACK;
    }

    status = ZentorSendScanRequest(&request, &verdict);
    if (!NT_SUCCESS(status) && status != STATUS_TIMEOUT) {
        return FLT_PREOP_SUCCESS_NO_CALLBACK;
    }

    if (ZentorShouldBlockVerdict(&verdict)) {
        Data->IoStatus.Status = STATUS_ACCESS_DENIED;
        Data->IoStatus.Information = 0;
        return FLT_PREOP_COMPLETE;
    }

    return FLT_PREOP_SUCCESS_NO_CALLBACK;
}
