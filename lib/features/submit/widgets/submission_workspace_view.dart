import 'package:flutter/material.dart';

import '../../../shared/widgets/participant_ui.dart';
import '../models/submission_models.dart';
import '../utils/submission_validators.dart';

class SubmissionWorkspaceViewData {
  const SubmissionWorkspaceViewData({
    required this.currentEmail,
    required this.memberTeams,
    required this.leaderTeams,
    required this.selectedTeam,
    required this.joinedHackathons,
    required this.selectedHackathon,
    required this.existingSubmission,
    required this.isSaving,
    this.isLoading = false,
  });

  final String currentEmail;
  final List<SubmissionTeamSummary> memberTeams;
  final List<SubmissionTeamSummary> leaderTeams;
  final SubmissionTeamSummary? selectedTeam;
  final List<HackathonSummary> joinedHackathons;
  final HackathonSummary? selectedHackathon;
  final SubmissionRecord? existingSubmission;
  final bool isSaving;
  final bool isLoading;

  bool get hasSession => currentEmail.trim().isNotEmpty;
  bool get hasTeams => memberTeams.isNotEmpty;
  bool get hasLeaderTeam => leaderTeams.isNotEmpty;
  bool get hasHackathons => joinedHackathons.isNotEmpty;
  bool get canEditSelectedTeam =>
      selectedTeam != null && selectedTeam!.isLeader(currentEmail);
}

class SubmissionWorkspaceView extends StatelessWidget {
  const SubmissionWorkspaceView({
    super.key,
    required this.data,
    required this.onTeamChanged,
    required this.onHackathonChanged,
    required this.onOpenParticipantForm,
    required this.onSaveLinks,
    required this.onOpenLink,
  });

  final SubmissionWorkspaceViewData data;
  final ValueChanged<String?> onTeamChanged;
  final ValueChanged<String?> onHackathonChanged;
  final VoidCallback? onOpenParticipantForm;
  final Future<void> Function(String repositoryUrl, String videoUrl)
  onSaveLinks;
  final Future<void> Function(String url) onOpenLink;

  @override
  Widget build(BuildContext context) {
    if (data.isLoading) {
      return const ParticipantCard(
        child: SizedBox(
          height: 180,
          child: Center(
            child: CircularProgressIndicator(color: ParticipantPalette.primary),
          ),
        ),
      );
    }

    if (!data.hasSession) {
      return const _SingleStateView(
        title: 'No active session',
        subtitle: 'Sign in again to manage your team submissions.',
        icon: Icons.lock_outline_rounded,
        color: ParticipantPalette.danger,
      );
    }

    if (!data.hasTeams) {
      return const _SingleStateView(
        title: 'No teams yet',
        subtitle:
            'Join or create a team first, then this workspace will load your submission options automatically.',
        icon: Icons.groups_2_outlined,
        color: ParticipantPalette.primary,
      );
    }

    if (!data.hasLeaderTeam) {
      return _SingleStateView(
        title: 'Leader access required',
        subtitle:
            'Only team leaders can submit repository and demo links. You are currently a member in ${data.memberTeams.length} team${data.memberTeams.length == 1 ? '' : 's'}.',
        icon: Icons.shield_outlined,
        color: ParticipantPalette.warning,
        footer: Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              data.memberTeams
                  .map(
                    (team) => ParticipantInfoChip(
                      label: team.name,
                      color: ParticipantPalette.secondary,
                    ),
                  )
                  .toList(),
        ),
      );
    }

    if (data.selectedTeam == null) {
      return const _SingleStateView(
        title: 'Choose a team',
        subtitle: 'Select a leader-owned team to continue.',
        icon: Icons.arrow_drop_down_circle_outlined,
        color: ParticipantPalette.primary,
      );
    }

    if (!data.hasHackathons || data.selectedHackathon == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamSummaryCard(
            memberTeams: data.memberTeams,
            leaderTeams: data.leaderTeams,
            selectedTeam: data.selectedTeam!,
            selectedHackathon: null,
          ),
          _LeaderTeamPickerCard(
            leaderTeams: data.leaderTeams,
            selectedTeamCode: data.selectedTeam!.code,
            onChanged: onTeamChanged,
          ),
          const _SingleStateView(
            title: 'No hackathon joined',
            subtitle:
                'Register this team in a hackathon from the Teams workspace before submitting project links.',
            icon: Icons.rocket_launch_outlined,
            color: ParticipantPalette.warning,
          ),
        ],
      );
    }

    final selectedHackathon = data.selectedHackathon!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TeamSummaryCard(
          memberTeams: data.memberTeams,
          leaderTeams: data.leaderTeams,
          selectedTeam: data.selectedTeam!,
          selectedHackathon: selectedHackathon,
        ),
        _LeaderTeamPickerCard(
          leaderTeams: data.leaderTeams,
          selectedTeamCode: data.selectedTeam!.code,
          onChanged: onTeamChanged,
        ),
        _HackathonPickerCard(
          hackathons: data.joinedHackathons,
          selectedHackathonId: selectedHackathon.id,
          onChanged: onHackathonChanged,
        ),
        _GoogleFormCard(
          hackathon: selectedHackathon,
          onOpenParticipantForm: onOpenParticipantForm,
        ),
        SubmissionLinksFormCard(
          key: ValueKey<String>(
            '${data.selectedTeam!.code}_${selectedHackathon.id}',
          ),
          initialRepositoryUrl: data.existingSubmission?.repositoryUrl ?? '',
          initialVideoUrl: data.existingSubmission?.videoUrl ?? '',
          isSaving: data.isSaving,
          onSave: onSaveLinks,
          onOpenLink: onOpenLink,
          lastUpdated: data.existingSubmission?.updatedAt?.toDate(),
          submittedByEmail: data.existingSubmission?.submittedByEmail ?? '',
        ),
      ],
    );
  }
}

class SubmissionLinksFormCard extends StatefulWidget {
  const SubmissionLinksFormCard({
    super.key,
    required this.initialRepositoryUrl,
    required this.initialVideoUrl,
    required this.isSaving,
    required this.onSave,
    required this.onOpenLink,
    this.lastUpdated,
    this.submittedByEmail = '',
  });

  final String initialRepositoryUrl;
  final String initialVideoUrl;
  final bool isSaving;
  final Future<void> Function(String repositoryUrl, String videoUrl) onSave;
  final Future<void> Function(String url) onOpenLink;
  final DateTime? lastUpdated;
  final String submittedByEmail;

  @override
  State<SubmissionLinksFormCard> createState() =>
      _SubmissionLinksFormCardState();
}

class _SubmissionLinksFormCardState extends State<SubmissionLinksFormCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _repositoryController;
  late final TextEditingController _videoController;

  @override
  void initState() {
    super.initState();
    _repositoryController = TextEditingController(
      text: widget.initialRepositoryUrl,
    );
    _videoController = TextEditingController(text: widget.initialVideoUrl);
  }

  @override
  void didUpdateWidget(covariant SubmissionLinksFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRepositoryUrl != widget.initialRepositoryUrl) {
      _repositoryController.text = widget.initialRepositoryUrl;
    }
    if (oldWidget.initialVideoUrl != widget.initialVideoUrl) {
      _videoController.text = widget.initialVideoUrl;
    }
  }

  @override
  void dispose() {
    _repositoryController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSave(
      SubmissionValidators.normalizeUrl(_repositoryController.text),
      SubmissionValidators.normalizeUrl(_videoController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRepository = _repositoryController.text.trim().isNotEmpty;
    final hasVideo = _videoController.text.trim().isNotEmpty;

    return ParticipantCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ParticipantSectionHeader(
              title: 'Mobile App Submission',
              subtitle:
                  widget.lastUpdated == null
                      ? 'Save your team repository and demo video for judges.'
                      : 'Last updated ${_formatDateTime(widget.lastUpdated!)} by ${widget.submittedByEmail.isEmpty ? 'your team leader' : widget.submittedByEmail}.',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _repositoryController,
              onChanged: (_) => setState(() {}),
              validator: SubmissionValidators.validateRepositoryUrl,
              decoration: _inputDecoration(
                label: 'GitHub Repository URL',
                hintText: 'https://github.com/your-team/project',
                icon: Icons.code_rounded,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _videoController,
              onChanged: (_) => setState(() {}),
              validator: SubmissionValidators.validateVideoUrl,
              decoration: _inputDecoration(
                label: 'Project Video URL',
                hintText: 'https://youtube.com/watch?v=demo',
                icon: Icons.ondemand_video_rounded,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      hasRepository
                          ? () => widget.onOpenLink(_repositoryController.text)
                          : null,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open Repo'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      hasVideo
                          ? () => widget.onOpenLink(_videoController.text)
                          : null,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: const Text('Open Video'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isSaving ? null : _handleSave,
                icon:
                    widget.isSaving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.save_rounded),
                label: Text(widget.isSaving ? 'Saving...' : 'Save Submission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ParticipantPalette.primary,
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
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: ParticipantPalette.primary,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ParticipantPalette.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: ParticipantPalette.danger,
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  String _formatDateTime(DateTime value) {
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.day}/${value.month}/${value.year} ${value.hour}:$minute';
  }
}

class _SingleStateView extends StatelessWidget {
  const _SingleStateView({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.footer,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? footer;

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
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 14), footer!],
        ],
      ),
    );
  }
}

class _TeamSummaryCard extends StatelessWidget {
  const _TeamSummaryCard({
    required this.memberTeams,
    required this.leaderTeams,
    required this.selectedTeam,
    required this.selectedHackathon,
  });

  final List<SubmissionTeamSummary> memberTeams;
  final List<SubmissionTeamSummary> leaderTeams;
  final SubmissionTeamSummary selectedTeam;
  final HackathonSummary? selectedHackathon;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParticipantSectionHeader(
            title: 'Submission Status',
            subtitle:
                'Track which leader-owned team and hackathon this submission belongs to.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ParticipantInfoChip(
                label: '${memberTeams.length} Joined Teams',
                color: ParticipantPalette.secondary,
              ),
              ParticipantInfoChip(
                label:
                    '${leaderTeams.length} Leader Team${leaderTeams.length == 1 ? '' : 's'}',
                color: ParticipantPalette.warning,
              ),
              if (selectedHackathon != null)
                ParticipantInfoChip(
                  label: selectedHackathon!.title,
                  color: ParticipantPalette.primary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: ParticipantPalette.headerGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedTeam.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedHackathon == null
                      ? 'Select a joined hackathon for this team before uploading project links.'
                      : 'Submitting for ${selectedHackathon!.title}.',
                  style: const TextStyle(
                    color: Color(0xFFEAE7FF),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderTeamPickerCard extends StatelessWidget {
  const _LeaderTeamPickerCard({
    required this.leaderTeams,
    required this.selectedTeamCode,
    required this.onChanged,
  });

  final List<SubmissionTeamSummary> leaderTeams;
  final String selectedTeamCode;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParticipantSectionHeader(
            title: 'Leader Team',
            subtitle:
                'Choose which leader-owned team should receive this submission record.',
          ),
          DropdownButtonFormField<String>(
            value: selectedTeamCode,
            items:
                leaderTeams
                    .map(
                      (team) => DropdownMenuItem<String>(
                        value: team.code,
                        child: Text(team.name),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
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

class _HackathonPickerCard extends StatelessWidget {
  const _HackathonPickerCard({
    required this.hackathons,
    required this.selectedHackathonId,
    required this.onChanged,
  });

  final List<HackathonSummary> hackathons;
  final String selectedHackathonId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParticipantSectionHeader(
            title: 'Joined Hackathon',
            subtitle:
                'Each submission is saved separately for every hackathon your team has joined.',
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
            onChanged: onChanged,
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

class _GoogleFormCard extends StatelessWidget {
  const _GoogleFormCard({
    required this.hackathon,
    required this.onOpenParticipantForm,
  });

  final HackathonSummary hackathon;
  final VoidCallback? onOpenParticipantForm;

  @override
  Widget build(BuildContext context) {
    final configured = hackathon.hasParticipantFormUrl;

    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParticipantSectionHeader(
            title: 'Project Details Form',
            subtitle:
                configured
                    ? 'Open the organiser Google Form to submit your project summary and required details.'
                    : 'This hackathon does not have a Google Form link configured yet.',
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  configured
                      ? ParticipantPalette.primary.withOpacity(0.08)
                      : ParticipantPalette.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  configured
                      ? Icons.description_rounded
                      : Icons.warning_amber_rounded,
                  color:
                      configured
                          ? ParticipantPalette.primary
                          : ParticipantPalette.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    configured
                        ? 'Google Form ready for ${hackathon.title}.'
                        : 'Ask an organiser to add the participant Google Form URL for ${hackathon.title}.',
                    style: const TextStyle(
                      color: ParticipantPalette.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: configured ? onOpenParticipantForm : null,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(
                configured ? 'Open Google Form' : 'Form Not Configured',
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
