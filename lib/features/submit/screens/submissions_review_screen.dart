import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/widgets/participant_ui.dart';
import '../models/submission_models.dart';
import '../utils/submission_validators.dart';

class SubmissionsReviewScreen extends StatefulWidget {
  const SubmissionsReviewScreen({
    super.key,
    this.title = 'Submissions Review',
    this.subtitle =
        'Review registered teams, saved app links, and the organiser Google review sheet from one screen.',
    this.firestore,
    this.launchUrlOverride,
  });

  const SubmissionsReviewScreen.judge({
    super.key,
    this.firestore,
    this.launchUrlOverride,
  }) : title = 'Judging Submissions',
       subtitle =
           'Review team registrations, saved demo links, and the organiser review sheet while judging.';

  const SubmissionsReviewScreen.admin({
    super.key,
    this.firestore,
    this.launchUrlOverride,
  }) : title = 'Submitted Projects',
       subtitle =
           'Monitor registered teams, app submission links, and the organiser review sheet before judging.';

  final String title;
  final String subtitle;
  final FirebaseFirestore? firestore;
  final Future<bool> Function(Uri uri)? launchUrlOverride;

  @override
  State<SubmissionsReviewScreen> createState() =>
      _SubmissionsReviewScreenState();
}

class _SubmissionsReviewScreenState extends State<SubmissionsReviewScreen> {
  String? _selectedHackathonId;

  FirebaseFirestore get _firestore =>
      widget.firestore ?? FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('hackathons').snapshots(),
      builder: (context, hackathonSnapshot) {
        if (hackathonSnapshot.connectionState == ConnectionState.waiting &&
            !hackathonSnapshot.hasData) {
          return _buildScaffold(
            body: const ParticipantCard(
              child: SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: ParticipantPalette.primary,
                  ),
                ),
              ),
            ),
            trailingLabel: 'Loading',
          );
        }

        if (hackathonSnapshot.hasError) {
          return _buildScaffold(
            trailingLabel: 'Unavailable',
            body: const _ReviewStateCard(
              title: 'Could not load hackathons',
              subtitle:
                  'Please try again after checking your Firestore connection.',
              icon: Icons.error_outline_rounded,
              color: ParticipantPalette.danger,
            ),
          );
        }

        final hackathons =
            hackathonSnapshot.data?.docs
                .map(HackathonSummary.fromDocument)
                .toList() ??
            <HackathonSummary>[];
        hackathons.sort((a, b) {
          return (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          );
        });

        if (hackathons.isEmpty) {
          return _buildScaffold(
            trailingLabel: '0 Events',
            body: const _ReviewStateCard(
              title: 'No hackathons yet',
              subtitle:
                  'Create and publish a hackathon before teams can register and submit project links.',
              icon: Icons.event_busy_outlined,
              color: ParticipantPalette.warning,
            ),
          );
        }

        final selectedHackathon = _resolveSelectedHackathon(hackathons);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('teams').snapshots(),
          builder: (context, teamSnapshot) {
            if (teamSnapshot.hasError) {
              return _buildScaffold(
                trailingLabel: '${hackathons.length} Events',
                body: const _ReviewStateCard(
                  title: 'Could not load teams',
                  subtitle:
                      'Hackathons were loaded, but the team directory could not be read.',
                  icon: Icons.error_outline_rounded,
                  color: ParticipantPalette.danger,
                ),
              );
            }

            final teams =
                teamSnapshot.data?.docs
                    .map(SubmissionTeamSummary.fromDocument)
                    .toList() ??
                <SubmissionTeamSummary>[];
            final teamByCode = {for (final team in teams) team.code: team};

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  _firestore
                      .collection('submissions')
                      .where('hackathonId', isEqualTo: selectedHackathon.id)
                      .snapshots(),
              builder: (context, submissionSnapshot) {
                if (submissionSnapshot.hasError) {
                  return _buildScaffold(
                    trailingLabel:
                        '${selectedHackathon.registeredTeams.length} Teams',
                    body: const _ReviewStateCard(
                      title: 'Could not load submissions',
                      subtitle:
                          'The review workspace is available, but submission records could not be read.',
                      icon: Icons.error_outline_rounded,
                      color: ParticipantPalette.danger,
                    ),
                  );
                }

                final submissionByTeamCode = <String, SubmissionRecord>{};
                for (final doc
                    in submissionSnapshot.data?.docs ??
                        const <QueryDocumentSnapshot<Map<String, dynamic>>>[]) {
                  final record = SubmissionRecord.fromDocument(doc);
                  submissionByTeamCode[record.teamCode] = record;
                }

                final reviewItems =
                    selectedHackathon.registeredTeams
                        .map(
                          (teamCode) => _TeamReviewItem(
                            team: teamByCode[teamCode],
                            submission: submissionByTeamCode[teamCode],
                            teamCode: teamCode,
                          ),
                        )
                        .toList();

                final isAnonymous = selectedHackathon.anonymousJudging && widget.title != 'Submitted Projects';
                final registeredTeamsSorted = List<String>.from(selectedHackathon.registeredTeams)..sort();

                return _buildScaffold(
                  trailingLabel:
                      '${selectedHackathon.registeredTeams.length} Teams',
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReviewHeaderCard(
                        hackathons: hackathons,
                        selectedHackathonId: selectedHackathon.id,
                        onHackathonChanged: (hackathonId) {
                          setState(() {
                            _selectedHackathonId = hackathonId;
                          });
                        },
                      ),
                      _ReviewLinkCard(
                        hackathon: selectedHackathon,
                        onOpenReviewUrl:
                            selectedHackathon.hasReviewUrl
                                ? () => _openExternalUrl(
                                  selectedHackathon.reviewUrl,
                                )
                                : null,
                      ),
                      if (reviewItems.isEmpty)
                        const _ReviewStateCard(
                          title: 'No registered teams',
                          subtitle:
                              'Teams will appear here once a leader joins this hackathon from the team workspace.',
                          icon: Icons.groups_2_outlined,
                          color: ParticipantPalette.warning,
                        )
                      else
                        ...reviewItems.map(
                          (item) {
                            final index = registeredTeamsSorted.indexOf(item.teamCode);
                            final teamNum = index != -1 ? index + 1 : 1;
                            final maskedName = 'Team #$teamNum';

                            return _SubmittedTeamCard(
                              item: item,
                              onOpenLink: _openExternalUrl,
                              isAnonymous: isAnonymous,
                              displayName: isAnonymous ? maskedName : item.teamName,
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  HackathonSummary _resolveSelectedHackathon(
    List<HackathonSummary> hackathons,
  ) {
    return hackathons.firstWhere(
      (hackathon) => hackathon.id == _selectedHackathonId,
      orElse: () => hackathons.first,
    );
  }

  Widget _buildScaffold({required Widget body, required String trailingLabel}) {
    return ParticipantPageScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      icon: Icons.fact_check_rounded,
      trailing: ParticipantInfoChip(label: trailingLabel, color: Colors.white),
      children: [body],
    );
  }

  Future<void> _openExternalUrl(String rawUrl) async {
    final normalized = SubmissionValidators.normalizeUrl(rawUrl);
    final uri = Uri.tryParse(normalized);

    if (uri == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This link is not configured correctly yet.'),
        ),
      );
      return;
    }

    try {
      final launched =
          await (widget.launchUrlOverride?.call(uri) ??
              launchUrl(uri, mode: LaunchMode.externalApplication));

      if (launched || !mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $normalized')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link: $error')),
      );
    }
  }
}

class _ReviewHeaderCard extends StatelessWidget {
  const _ReviewHeaderCard({
    required this.hackathons,
    required this.selectedHackathonId,
    required this.onHackathonChanged,
  });

  final List<HackathonSummary> hackathons;
  final String selectedHackathonId;
  final ValueChanged<String?> onHackathonChanged;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParticipantSectionHeader(
            title: 'Hackathon Filter',
            subtitle:
                'Switch between hackathons to review each registered team and its saved app submission links.',
          ),
          DropdownButtonFormField<String>(
            value: selectedHackathonId,
            items:
                hackathons
                    .map(
                      (hackathon) => DropdownMenuItem<String>(
                        value: hackathon.id,
                        child: Text(hackathon.title),
                      ),
                    )
                    .toList(),
            onChanged: onHackathonChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewLinkCard extends StatelessWidget {
  const _ReviewLinkCard({
    required this.hackathon,
    required this.onOpenReviewUrl,
  });

  final HackathonSummary hackathon;
  final VoidCallback? onOpenReviewUrl;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParticipantSectionHeader(
            title: 'Organiser Review Sheet',
            subtitle:
                hackathon.hasReviewUrl
                    ? 'Open the external review sheet or response destination configured for ${hackathon.title}.'
                    : 'No review sheet URL has been configured for this hackathon yet.',
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOpenReviewUrl,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(
                hackathon.hasReviewUrl
                    ? 'Open Review Sheet'
                    : 'Review Sheet Not Configured',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ParticipantPalette.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStateCard extends StatelessWidget {
  const _ReviewStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ParticipantPalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ParticipantPalette.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamReviewItem {
  const _TeamReviewItem({
    required this.team,
    required this.submission,
    required this.teamCode,
  });

  final SubmissionTeamSummary? team;
  final SubmissionRecord? submission;
  final String teamCode;

  String get teamName => team?.name ?? 'Unknown Team';
  String get leaderEmail => team?.leaderEmail ?? submission?.leaderEmail ?? '—';
  int get memberCount => team?.members.length ?? 0;
  bool get hasRepository => submission?.hasRepositoryUrl ?? false;
  bool get hasVideo => submission?.hasVideoUrl ?? false;
  bool get isReady => submission?.isComplete ?? false;
}

class _SubmittedTeamCard extends StatelessWidget {
  const _SubmittedTeamCard({
    required this.item,
    required this.onOpenLink,
    required this.isAnonymous,
    required this.displayName,
  });

  final _TeamReviewItem item;
  final Future<void> Function(String url) onOpenLink;
  final bool isAnonymous;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: ParticipantPalette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isAnonymous)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ParticipantInfoChip(
                            label: 'Code ${item.teamCode}',
                            color: ParticipantPalette.primary,
                          ),
                          ParticipantInfoChip(
                            label: '${item.memberCount} Members',
                            color: ParticipantPalette.secondary,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              ParticipantInfoChip(
                label: item.isReady ? 'Ready' : 'Pending',
                color:
                    item.isReady
                        ? ParticipantPalette.success
                        : ParticipantPalette.warning,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ParticipantBulletRow(
            text: isAnonymous ? 'Leader: Anonymous' : 'Leader: ${item.leaderEmail}',
            icon: Icons.person_outline_rounded,
            color: ParticipantPalette.secondary,
          ),
          ParticipantBulletRow(
            text:
                item.hasRepository
                    ? 'Repository link saved in the app.'
                    : 'Repository link has not been submitted in the app yet.',
            icon: Icons.code_rounded,
            color:
                item.hasRepository
                    ? ParticipantPalette.success
                    : ParticipantPalette.warning,
          ),
          ParticipantBulletRow(
            text:
                item.hasVideo
                    ? 'Video link saved in the app.'
                    : 'Video link has not been submitted in the app yet.',
            icon: Icons.ondemand_video_rounded,
            color:
                item.hasVideo
                    ? ParticipantPalette.success
                    : ParticipantPalette.warning,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed:
                    item.hasRepository
                        ? () => onOpenLink(item.submission!.repositoryUrl)
                        : null,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open Repo'),
              ),
              OutlinedButton.icon(
                onPressed:
                    item.hasVideo
                        ? () => onOpenLink(item.submission!.videoUrl)
                        : null,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('Open Video'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
