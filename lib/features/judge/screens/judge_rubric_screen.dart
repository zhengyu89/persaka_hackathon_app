import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/hackathon_cover.dart';
import '../../../shared/widgets/participant_ui.dart';
import '../../submit/models/submission_models.dart';
import '../models/judge_rubric_models.dart';

class JudgeRubricScreen extends StatelessWidget {
  const JudgeRubricScreen({
    super.key,
    required this.hackathonId,
    required this.assignedTeamIds,
  });

  final String hackathonId;
  final List<String> assignedTeamIds;

  @override
  Widget build(BuildContext context) {
    final hackathonRef = FirebaseFirestore.instance
        .collection('hackathons')
        .doc(hackathonId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: hackathonRef.snapshots(),
      builder: (context, hackathonSnapshot) {
        final hackathonData = hackathonSnapshot.data?.data();
        final hackathon =
            hackathonData == null
                ? null
                : HackathonSummary.fromMap(hackathonId, hackathonData);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              hackathonRef
                  .collection('criteria')
                  .where('active', isEqualTo: true)
                  .snapshots(),
          builder: (context, criteriaSnapshot) {
            final criteria =
                criteriaSnapshot.data?.docs
                    .map(JudgeCriterion.fromDocument)
                    .toList() ??
                <JudgeCriterion>[];
            criteria.sort((a, b) => b.weight.compareTo(a.weight));

            final totalWeight = criteria.fold<double>(
              0,
              (total, criterion) => total + criterion.weight,
            );

            return Scaffold(
              backgroundColor: ParticipantPalette.pageBackground,
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
                      decoration: const BoxDecoration(
                        gradient: ParticipantPalette.headerGradient,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scoring Rubric',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Review the active judging criteria before scoring teams.',
                                  style: TextStyle(
                                    color: Color(0xFFEAE7FF),
                                    fontSize: 14,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                    sliver: SliverList.list(
                      children: [
                        if (hackathonSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            hackathon == null)
                          const ParticipantCard(
                            child: SizedBox(
                              height: 160,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ParticipantPalette.primary,
                                ),
                              ),
                            ),
                          )
                        else if (hackathon == null)
                          const _RubricStateCard(
                            title: 'Hackathon not found',
                            subtitle:
                                'This rubric needs an existing hackathon assignment.',
                            icon: Icons.error_outline_rounded,
                          )
                        else ...[
                          _RubricHeroCard(
                            hackathon: hackathon,
                            assignedTeamsCount: assignedTeamIds.length,
                          ),
                          if (criteriaSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !criteriaSnapshot.hasData)
                            const ParticipantCard(
                              child: SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: ParticipantPalette.primary,
                                  ),
                                ),
                              ),
                            )
                          else if (criteria.isEmpty)
                            const _RubricStateCard(
                              title: 'No rubric configured yet',
                              subtitle:
                                  'The admin needs to add active criteria before judging starts.',
                              icon: Icons.rule_folder_outlined,
                            )
                          else
                            ...criteria.map(_CriterionCard.new),
                          _WeightSummaryCard(
                            totalCriteria: criteria.length,
                            totalWeight: totalWeight,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: ElevatedButton.icon(
                    onPressed:
                        criteria.isEmpty || assignedTeamIds.isEmpty
                            ? null
                            : () {
                              Navigator.pushNamed(
                                context,
                                '/app/judge/team/${Uri.encodeComponent(assignedTeamIds.first)}/score',
                                arguments: {'hackathonId': hackathonId},
                              );
                            },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Judging'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ParticipantPalette.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      disabledForegroundColor: const Color(0xFF9CA3AF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      shadowColor: ParticipantPalette.primary.withOpacity(0.28),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RubricHeroCard extends StatelessWidget {
  const _RubricHeroCard({
    required this.hackathon,
    required this.assignedTeamsCount,
  });

  final HackathonSummary hackathon;
  final int assignedTeamsCount;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HackathonCover(
            imageBase64: hackathon.imageBase64,
            height: 170,
            borderRadius: 20,
            placeholderLabel: 'No poster available',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hackathon.title,
                      style: const TextStyle(
                        color: ParticipantPalette.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$assignedTeamsCount Assigned Teams',
                      style: const TextStyle(
                        color: ParticipantPalette.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const ParticipantInfoChip(
                label: 'Judge View',
                color: ParticipantPalette.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriterionCard extends StatelessWidget {
  const _CriterionCard(this.criterion);

  final JudgeCriterion criterion;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criterion.name,
            style: const TextStyle(
              color: ParticipantPalette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _RubricLine(label: 'Weight', value: '${_formatNumber(criterion.weight)}%'),
          const SizedBox(height: 12),
          const Text(
            'Description:',
            style: TextStyle(
              color: ParticipantPalette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            criterion.description.isEmpty
                ? 'No description provided.'
                : criterion.description,
            style: const TextStyle(
              color: ParticipantPalette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _RubricLine(
            label: 'Max Score',
            value: _formatNumber(criterion.maxScore),
          ),
          const Divider(height: 28),
          const Text(
            'Score Guide:',
            style: TextStyle(
              color: ParticipantPalette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const _ScoreGuideRow(range: '1-2', label: 'Poor'),
          const _ScoreGuideRow(range: '3-4', label: 'Fair'),
          const _ScoreGuideRow(range: '5-6', label: 'Good'),
          const _ScoreGuideRow(range: '7-8', label: 'Very Good'),
          const _ScoreGuideRow(range: '9-10', label: 'Excellent'),
        ],
      ),
    );
  }
}

class _RubricLine extends StatelessWidget {
  const _RubricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: ParticipantPalette.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: ParticipantPalette.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ScoreGuideRow extends StatelessWidget {
  const _ScoreGuideRow({required this.range, required this.label});

  final String range;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              range,
              style: const TextStyle(
                color: ParticipantPalette.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: ParticipantPalette.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _WeightSummaryCard extends StatelessWidget {
  const _WeightSummaryCard({
    required this.totalCriteria,
    required this.totalWeight,
  });

  final int totalCriteria;
  final double totalWeight;

  @override
  Widget build(BuildContext context) {
    final isComplete = totalWeight == 100;

    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParticipantSectionHeader(
            title: 'Weight Summary',
            subtitle: 'Rubric totals update from Firestore in realtime.',
          ),
          Row(
            children: [
              _SummaryTile(label: 'Total Criteria', value: '$totalCriteria'),
              const SizedBox(width: 12),
              _SummaryTile(
                label: 'Total Weight',
                value: '${_formatNumber(totalWeight)}%',
              ),
            ],
          ),
          if (!isComplete) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ParticipantPalette.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ParticipantPalette.warning.withOpacity(0.22),
                ),
              ),
              child: const Text(
                'Rubric configuration incomplete',
                style: TextStyle(
                  color: Color(0xFF9A3412),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ParticipantPalette.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ParticipantPalette.primary.withOpacity(0.14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: ParticipantPalette.primary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: ParticipantPalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RubricStateCard extends StatelessWidget {
  const _RubricStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        children: [
          Icon(icon, color: ParticipantPalette.primary, size: 40),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: ParticipantPalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ParticipantPalette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
