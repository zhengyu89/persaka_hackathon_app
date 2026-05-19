import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/widgets/participant_ui.dart';
import '../models/submission_models.dart';
import '../utils/submission_validators.dart';
import '../widgets/submission_workspace_view.dart';

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({
    super.key,
    this.firestore,
    this.auth,
    this.launchUrlOverride,
  });

  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  final Future<bool> Function(Uri uri)? launchUrlOverride;

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  String? _selectedTeamCode;
  String? _selectedHackathonId;
  bool _isSaving = false;

  FirebaseFirestore get _firestore =>
      widget.firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentEmail = _auth.currentUser?.email ?? '';

    if (currentEmail.isEmpty) {
      return _buildScaffold(
        SubmissionWorkspaceViewData(
          currentEmail: '',
          memberTeams: const [],
          leaderTeams: const [],
          selectedTeam: null,
          joinedHackathons: const [],
          selectedHackathon: null,
          existingSubmission: null,
          isSaving: false,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          _firestore
              .collection('teams')
              .where('members', arrayContains: currentEmail)
              .snapshots(),
      builder: (context, teamSnapshot) {
        if (teamSnapshot.connectionState == ConnectionState.waiting &&
            !teamSnapshot.hasData) {
          return _buildScaffold(
            SubmissionWorkspaceViewData(
              currentEmail: currentEmail,
              memberTeams: const [],
              leaderTeams: const [],
              selectedTeam: null,
              joinedHackathons: const [],
              selectedHackathon: null,
              existingSubmission: null,
              isSaving: false,
              isLoading: true,
            ),
          );
        }

        if (teamSnapshot.hasError) {
          return _buildErrorScaffold(
            title: 'Could not load your teams',
            subtitle:
                'Please try again once your connection to Firestore is available.',
          );
        }

        final teams =
            teamSnapshot.data?.docs
                .map(SubmissionTeamSummary.fromDocument)
                .toList() ??
            <SubmissionTeamSummary>[];
        teams.sort((a, b) {
          return (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          );
        });

        final leaderTeams =
            teams.where((team) => team.isLeader(currentEmail)).toList();
        final selectedTeam = _resolveSelectedTeam(leaderTeams);

        if (selectedTeam == null) {
          return _buildScaffold(
            SubmissionWorkspaceViewData(
              currentEmail: currentEmail,
              memberTeams: teams,
              leaderTeams: leaderTeams,
              selectedTeam: null,
              joinedHackathons: const [],
              selectedHackathon: null,
              existingSubmission: null,
              isSaving: false,
            ),
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              _firestore
                  .collection('hackathons')
                  .where('registeredTeams', arrayContains: selectedTeam.code)
                  .snapshots(),
          builder: (context, hackathonSnapshot) {
            if (hackathonSnapshot.connectionState == ConnectionState.waiting &&
                !hackathonSnapshot.hasData) {
              return _buildScaffold(
                SubmissionWorkspaceViewData(
                  currentEmail: currentEmail,
                  memberTeams: teams,
                  leaderTeams: leaderTeams,
                  selectedTeam: selectedTeam,
                  joinedHackathons: const [],
                  selectedHackathon: null,
                  existingSubmission: null,
                  isSaving: false,
                  isLoading: true,
                ),
              );
            }

            if (hackathonSnapshot.hasError) {
              return _buildErrorScaffold(
                title: 'Could not load joined hackathons',
                subtitle:
                    'Please try again after checking the team registration data.',
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

            final selectedHackathon = _resolveSelectedHackathon(hackathons);

            if (selectedHackathon == null) {
              return _buildScaffold(
                SubmissionWorkspaceViewData(
                  currentEmail: currentEmail,
                  memberTeams: teams,
                  leaderTeams: leaderTeams,
                  selectedTeam: selectedTeam,
                  joinedHackathons: hackathons,
                  selectedHackathon: null,
                  existingSubmission: null,
                  isSaving: false,
                ),
              );
            }

            final submissionId = submissionDocumentId(
              hackathonId: selectedHackathon.id,
              teamCode: selectedTeam.code,
            );

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream:
                  _firestore
                      .collection('submissions')
                      .doc(submissionId)
                      .snapshots(),
              builder: (context, submissionSnapshot) {
                if (submissionSnapshot.hasError) {
                  return _buildErrorScaffold(
                    title: 'Could not load submission links',
                    subtitle:
                        'The team and hackathon were found, but the submission record could not be read.',
                  );
                }

                final existingSubmission =
                    (submissionSnapshot.data?.exists ?? false)
                        ? SubmissionRecord.fromDocument(
                          submissionSnapshot.data!,
                        )
                        : null;

                return _buildScaffold(
                  SubmissionWorkspaceViewData(
                    currentEmail: currentEmail,
                    memberTeams: teams,
                    leaderTeams: leaderTeams,
                    selectedTeam: selectedTeam,
                    joinedHackathons: hackathons,
                    selectedHackathon: selectedHackathon,
                    existingSubmission: existingSubmission,
                    isSaving: _isSaving,
                  ),
                  selectedTeam: selectedTeam,
                  selectedHackathon: selectedHackathon,
                  currentEmail: currentEmail,
                );
              },
            );
          },
        );
      },
    );
  }

  SubmissionTeamSummary? _resolveSelectedTeam(
    List<SubmissionTeamSummary> leaderTeams,
  ) {
    if (leaderTeams.isEmpty) {
      return null;
    }

    return leaderTeams.firstWhere(
      (team) => team.code == _selectedTeamCode,
      orElse: () => leaderTeams.first,
    );
  }

  HackathonSummary? _resolveSelectedHackathon(
    List<HackathonSummary> hackathons,
  ) {
    if (hackathons.isEmpty) {
      return null;
    }

    return hackathons.firstWhere(
      (hackathon) => hackathon.id == _selectedHackathonId,
      orElse: () => hackathons.first,
    );
  }

  Widget _buildScaffold(
    SubmissionWorkspaceViewData data, {
    SubmissionTeamSummary? selectedTeam,
    HackathonSummary? selectedHackathon,
    String? currentEmail,
  }) {
    return ParticipantPageScaffold(
      title: 'Submission Hub',
      subtitle:
          'Open the organiser Google Form and submit your project video and repository links for each joined hackathon.',
      icon: Icons.upload_file_rounded,
      trailing: ParticipantInfoChip(
        label:
            data.hasLeaderTeam
                ? '${data.leaderTeams.length} Leader Team${data.leaderTeams.length == 1 ? '' : 's'}'
                : '${data.memberTeams.length} Teams',
        color: Colors.white,
      ),
      children: [
        SubmissionWorkspaceView(
          data: data,
          onTeamChanged: (teamCode) {
            setState(() {
              _selectedTeamCode = teamCode;
              _selectedHackathonId = null;
            });
          },
          onHackathonChanged: (hackathonId) {
            setState(() {
              _selectedHackathonId = hackathonId;
            });
          },
          onOpenParticipantForm:
              selectedHackathon == null
                  ? null
                  : () =>
                      _openExternalUrl(selectedHackathon.participantFormUrl),
          onSaveLinks: (repositoryUrl, videoUrl) async {
            if (selectedTeam == null ||
                selectedHackathon == null ||
                currentEmail == null ||
                currentEmail.isEmpty) {
              return;
            }

            await _saveSubmission(
              currentEmail: currentEmail,
              selectedTeam: selectedTeam,
              selectedHackathon: selectedHackathon,
              repositoryUrl: repositoryUrl,
              videoUrl: videoUrl,
            );
          },
          onOpenLink: (url) => _openExternalUrl(url),
        ),
      ],
    );
  }

  Widget _buildErrorScaffold({
    required String title,
    required String subtitle,
  }) {
    return ParticipantPageScaffold(
      title: 'Submission Hub',
      subtitle:
          'Open the organiser Google Form and submit your project video and repository links for each joined hackathon.',
      icon: Icons.upload_file_rounded,
      trailing: const ParticipantInfoChip(
        label: 'Unavailable',
        color: Colors.white,
      ),
      children: [
        ParticipantCard(
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ParticipantPalette.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: ParticipantPalette.danger,
                ),
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
        ),
      ],
    );
  }

  Future<void> _saveSubmission({
    required String currentEmail,
    required SubmissionTeamSummary selectedTeam,
    required HackathonSummary selectedHackathon,
    required String repositoryUrl,
    required String videoUrl,
  }) async {
    final submissionId = submissionDocumentId(
      hackathonId: selectedHackathon.id,
      teamCode: selectedTeam.code,
    );
    final docRef = _firestore.collection('submissions').doc(submissionId);

    setState(() {
      _isSaving = true;
    });

    try {
      final existingDoc = await docRef.get();
      final payload = <String, dynamic>{
        'hackathonId': selectedHackathon.id,
        'hackathonTitle': selectedHackathon.title,
        'teamCode': selectedTeam.code,
        'teamName': selectedTeam.name,
        'leaderEmail': selectedTeam.leaderEmail,
        'repositoryUrl': SubmissionValidators.normalizeUrl(repositoryUrl),
        'videoUrl': SubmissionValidators.normalizeUrl(videoUrl),
        'submittedByEmail': currentEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!existingDoc.exists) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(payload, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission links saved successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save submission links: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
