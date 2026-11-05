import '../calendar.dart';
import '../repositories/ledger_repository.dart';
import 'payment_event.dart';

/// Deduplication and matching — the two steps between "a payment was parsed"
/// and "a payment is in the ledger".
///
/// Both are pure functions over data the caller supplies, so both are tested
/// directly and neither can be accidentally skipped by a screen doing its own
/// thing.

/// What [deduplicate] decided about one incoming event.
class DedupeDecision {
  const DedupeDecision({
    required this.event,
    required this.isDuplicate,
    this.reason,
  });

  final PaymentEvent event;
  final bool isDuplicate;

  /// Why it was rejected, shown in the review queue so a user can tell
  /// "already imported" from "arrived twice in this file".
  final String? reason;
}

/// The result of screening a batch of parsed events.
class DedupeResult {
  const DedupeResult({required this.accepted, required this.duplicates});

  final List<PaymentEvent> accepted;
  final List<DedupeDecision> duplicates;

  int get acceptedCount => accepted.length;
  int get duplicateCount => duplicates.length;
}

/// Screens [incoming] against what the app has already seen.
///
/// [knownKeys] are the dedupe keys of events already recorded — both imported
/// payments and events still sitting in the review queue. The same payout
/// legitimately arrives by notification, then email, then statement; without
/// this step the ledger would count it three times.
///
/// Duplicates *within* the batch are caught too, because a user re-downloading
/// an overlapping date range is the single most likely way to double-import.
DedupeResult deduplicate({
  required List<PaymentEvent> incoming,
  required Set<String> knownKeys,
}) {
  final List<PaymentEvent> accepted = <PaymentEvent>[];
  final List<DedupeDecision> duplicates = <DedupeDecision>[];
  final Set<String> seenInBatch = <String>{};

  for (final PaymentEvent event in incoming) {
    final String key = event.dedupeKey;
    if (knownKeys.contains(key)) {
      duplicates.add(
        DedupeDecision(
          event: event,
          isDuplicate: true,
          reason: 'Already recorded',
        ),
      );
      continue;
    }
    if (!seenInBatch.add(key)) {
      duplicates.add(
        DedupeDecision(
          event: event,
          isDuplicate: true,
          reason: 'Appears twice in this file',
        ),
      );
      continue;
    }
    accepted.add(event);
  }

  return DedupeResult(accepted: accepted, duplicates: duplicates);
}

/// A candidate milestone for an incoming payment, with the evidence for it.
class MatchSuggestion implements Comparable<MatchSuggestion> {
  const MatchSuggestion({
    required this.candidate,
    required this.score,
    required this.reasons,
  });

  final MilestoneWithContext candidate;

  /// 0–100. Not a probability — a ranking, so the best guess sits at the top of
  /// the review screen.
  final int score;

  /// Plain-language evidence, shown to the user so the suggestion can be
  /// judged rather than trusted.
  final List<String> reasons;

  /// High enough that the review screen preselects it.
  ///
  /// Even at this level nothing is imported without the user confirming: a
  /// wrong automatic match silently corrupts a financial record, and the cost
  /// of one extra tap is far lower than the cost of finding that out at tax
  /// time.
  bool get isStrong => score >= 70;

  @override
  int compareTo(MatchSuggestion other) => other.score.compareTo(score);
}

/// Ranks [candidates] against [event], best first.
///
/// Scores are additive evidence, deliberately simple and explainable: every
/// point on the board corresponds to a sentence the user can read in
/// [MatchSuggestion.reasons]. Candidates with no evidence at all are dropped
/// rather than listed at zero.
List<MatchSuggestion> suggestMatches({
  required PaymentEvent event,
  required List<MilestoneWithContext> candidates,
}) {
  final List<MatchSuggestion> suggestions = <MatchSuggestion>[];

  for (final MilestoneWithContext candidate in candidates) {
    if (candidate.milestone.isCancelled || candidate.milestone.isFullyPaid) {
      continue;
    }
    // A payment can only settle a milestone billed in the same currency.
    if (candidate.milestone.currency != event.currency) continue;

    int score = 0;
    final List<String> reasons = <String>[];

    // Strongest evidence: the platform's own contract/order id is recorded on
    // the project. This is what `Project.externalRef` exists for.
    final String? projectRef = candidate.project.externalRef?.trim();
    final String? hint = event.projectHint?.trim();
    if (projectRef != null &&
        projectRef.isNotEmpty &&
        hint != null &&
        hint.isNotEmpty &&
        projectRef.toLowerCase() == hint.toLowerCase()) {
      score += 50;
      reasons.add('Project reference matches $projectRef');
    }

    if (candidate.milestone.sourceId == event.sourceId) {
      score += 10;
      reasons.add('Same payment source');
    }

    // Amount is strong evidence, but only exactly: "close to" invites matching
    // a payment against the wrong milestone of a similar size.
    final int outstanding = candidate.milestone.outstanding.minorUnits;
    final int incoming = event.amountToRecord.minorUnits;
    if (incoming == outstanding) {
      score += 30;
      reasons.add('Settles the outstanding balance exactly');
    } else if (incoming == candidate.milestone.netAmount.minorUnits) {
      score += 25;
      reasons.add('Matches the expected net amount');
    } else if (incoming == candidate.milestone.grossAmount.minorUnits) {
      score += 20;
      reasons.add('Matches the amount billed');
    } else if (incoming < outstanding) {
      score += 5;
      reasons.add('Fits within the outstanding balance');
    }

    if (_namesLookAlike(event.clientHint, candidate.client.name) ||
        _namesLookAlike(event.clientHint, candidate.client.company)) {
      score += 20;
      reasons.add('Client name matches ${candidate.client.name}');
    }

    // Payments usually land near the due date; a year away is weak evidence
    // against, not for.
    final int daysApart =
        daysBetween(candidate.milestone.dueDate, event.occurredAt).abs();
    if (daysApart <= 7) {
      score += 15;
      reasons.add('Received within a week of the due date');
    } else if (daysApart <= 45) {
      score += 8;
      reasons.add('Received near the due date');
    } else if (daysApart > 365) {
      score -= 10;
    }

    if (score <= 0 || reasons.isEmpty) continue;
    suggestions.add(
      MatchSuggestion(
        candidate: candidate,
        score: score.clamp(0, 100),
        reasons: reasons,
      ),
    );
  }

  suggestions.sort();
  return suggestions;
}

/// Loose name comparison for matching a platform buyer name to a client.
///
/// Platforms render names inconsistently — "Acme Studio", "acme_studio",
/// "Acme Studio Pvt Ltd". Comparing on letters and digits alone, and accepting
/// containment in either direction, catches those without the false positives a
/// fuzzy edit-distance match would bring.
bool _namesLookAlike(String? a, String? b) {
  if (a == null || b == null) return false;
  final String left = _reduce(a);
  final String right = _reduce(b);
  // Two- and three-letter reductions collide far too easily to be evidence.
  if (left.length < 4 || right.length < 4) return false;
  return left == right || left.contains(right) || right.contains(left);
}

String _reduce(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
