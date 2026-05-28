#include "ZentorAvFilter.h"

BOOLEAN
ZentorShouldBlockVerdict(_In_ PZENTOR_SCAN_VERDICT Verdict)
{
    if (Verdict == NULL) {
        return FALSE;
    }

    if (ZentorGlobals.Mode == ZentorModeObserveOnly || ZentorGlobals.Mode == ZentorModeDisabled) {
        return FALSE;
    }

    if (Verdict->Action == ZentorActionBlock || Verdict->Action == ZentorActionQuarantine) {
        return Verdict->FinalVerdict == ZentorVerdictConfirmedMalware ||
               Verdict->FinalVerdict == ZentorVerdictProbableMalware;
    }

    if (Verdict->Action == ZentorActionTimeoutBlock) {
        return ZentorGlobals.Mode == ZentorModeAggressive;
    }

    return FALSE;
}
