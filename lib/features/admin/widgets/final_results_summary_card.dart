import 'package:flutter/material.dart';

String finalResultsActionLabel(bool isRevealed) {
  return isRevealed ? 'Republish Final Results' : 'Reveal Final Results';
}

class FinalResultsSummaryCard extends StatelessWidget {
  const FinalResultsSummaryCard({
    super.key,
    required this.readyTeams,
    required this.totalTeams,
    required this.minimumJudgesRequired,
    required this.isRevealed,
    required this.isPublishing,
    required this.onPublish,
    this.publishedAtLabel,
    this.publishedBy,
  });

  final int readyTeams;
  final int totalTeams;
  final int minimumJudgesRequired;
  final bool isRevealed;
  final bool isPublishing;
  final VoidCallback? onPublish;
  final String? publishedAtLabel;
  final String? publishedBy;

  bool get _hasRegisteredTeams => totalTeams > 0;

  @override
  Widget build(BuildContext context) {
    final readyLabel = '$readyTeams / $totalTeams Teams Ready';
    final canPublish =
        onPublish != null && _hasRegisteredTeams && !isPublishing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              label: readyLabel,
              textColor: const Color(0xFF2563EB),
              backgroundColor: const Color(0xFFDBEAFE),
            ),
            _InfoChip(
              label:
                  'Min $minimumJudgesRequired Judge${minimumJudgesRequired == 1 ? '' : 's'}',
              textColor: const Color(0xFF7C3AED),
              backgroundColor: const Color(0xFFEDE9FE),
            ),
            _InfoChip(
              label: isRevealed ? 'Revealed' : 'Hidden',
              textColor:
                  isRevealed
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706),
              backgroundColor:
                  isRevealed
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _descriptionText(),
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 13,
            height: 1.45,
          ),
        ),
        if ((publishedAtLabel ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailLine(label: 'Last Published', value: publishedAtLabel!.trim()),
        ],
        if ((publishedBy ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _DetailLine(label: 'Published By', value: publishedBy!.trim()),
        ],
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canPublish ? onPublish : null,
            icon:
                isPublishing
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Icon(
                      isRevealed
                          ? Icons.refresh_rounded
                          : Icons.visibility_rounded,
                    ),
            label: Text(
              isPublishing
                  ? 'Publishing...'
                  : finalResultsActionLabel(isRevealed),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F39F6),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              disabledForegroundColor: const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _descriptionText() {
    if (!_hasRegisteredTeams) {
      return 'Register at least one team before publishing final results.';
    }
    if (readyTeams >= totalTeams) {
      return 'All registered teams meet the judging threshold. Publishing now will freeze the standings shown to participants.';
    }
    return 'Some teams are still below the judging threshold. Publishing now will keep them visible as pending and unranked for participants.';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
