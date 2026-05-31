use super::{Confidence, Verdict};
use crate::scan::ScanActionMode;

pub fn should_auto_quarantine(
    mode: ScanActionMode,
    verdict: Verdict,
    confidence: Confidence,
) -> bool {
    match mode {
        ScanActionMode::DetectOnly | ScanActionMode::LockdownReview => false,
        ScanActionMode::AutoQuarantineConfirmed => {
            matches!(verdict, Verdict::ConfirmedMalware | Verdict::TestThreat)
                && confidence == Confidence::Confirmed
        }
        ScanActionMode::AutoQuarantineHighConfidence => {
            matches!(verdict, Verdict::ConfirmedMalware | Verdict::TestThreat)
                && confidence == Confidence::Confirmed
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn confirmed_mode_quarantines_only_confirmed_threats() {
        assert!(should_auto_quarantine(
            ScanActionMode::AutoQuarantineConfirmed,
            Verdict::ConfirmedMalware,
            Confidence::Confirmed,
        ));
        assert!(!should_auto_quarantine(
            ScanActionMode::AutoQuarantineConfirmed,
            Verdict::ProbableMalware,
            Confidence::High,
        ));
    }

    #[test]
    fn high_confidence_compat_mode_does_not_quarantine_probable_items() {
        assert!(!should_auto_quarantine(
            ScanActionMode::AutoQuarantineHighConfidence,
            Verdict::ProbableMalware,
            Confidence::High,
        ));
        assert!(should_auto_quarantine(
            ScanActionMode::AutoQuarantineHighConfidence,
            Verdict::TestThreat,
            Confidence::Confirmed,
        ));
    }
}
