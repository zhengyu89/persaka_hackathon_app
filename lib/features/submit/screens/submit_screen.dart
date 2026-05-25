import 'package:flutter/material.dart';
import '../../../shared/widgets/participant_ui.dart';

class SubmitScreen extends StatelessWidget {
  const SubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticipantPageScaffold(
      title: 'Submission Hub',
      subtitle:
          'A no-logic submission UI with status cards, deliverables, and upload placeholders.',
      icon: Icons.upload_file_rounded,
      trailing: const ParticipantInfoChip(
        label: 'Draft',
        color: Colors.white,
      ),
      children: const [
        _SubmissionStatusCard(),
        _DeliverablesCard(),
        _UploadSlotsCard(),
        _RulesCard(),
      ],
    );
  }
}

class _SubmissionStatusCard extends StatelessWidget {
  const _SubmissionStatusCard();

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParticipantSectionHeader(
            title: 'Submission Status',
            subtitle: 'The layout is ready for future validation and upload progress.',
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: ParticipantPalette.headerGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final delivery closes in 18h 24m',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete your pitch deck, repository link, and demo video before lock.',
                  style: TextStyle(
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

class _DeliverablesCard extends StatelessWidget {
  const _DeliverablesCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Required Deliverables',
            subtitle: 'Checklist styling based on the participant dashboard language.',
          ),
          _DeliverableRow(
            title: 'Pitch Deck',
            subtitle: 'PDF or Canva share link',
            complete: true,
          ),
          _DeliverableRow(
            title: 'Source Repository',
            subtitle: 'Public or judge-accessible repository URL',
            complete: true,
          ),
          _DeliverableRow(
            title: 'Demo Video',
            subtitle: '60 to 90 second product walkthrough',
            complete: false,
          ),
          _DeliverableRow(
            title: 'Project Summary',
            subtitle: 'Problem, solution, and impact statement',
            complete: false,
          ),
        ],
      ),
    );
  }
}

class _DeliverableRow extends StatelessWidget {
  const _DeliverableRow({
    required this.title,
    required this.subtitle,
    required this.complete,
  });

  final String title;
  final String subtitle;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: complete
              ? ParticipantPalette.success.withOpacity(0.08)
              : const Color(0xFFF8F8FD),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              complete ? Icons.check_circle_rounded : Icons.timelapse_rounded,
              color: complete
                  ? ParticipantPalette.success
                  : ParticipantPalette.warning,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ParticipantPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ParticipantPalette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadSlotsCard extends StatelessWidget {
  const _UploadSlotsCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Upload Placeholders',
            subtitle: 'These blocks can later become file pickers and link inputs.',
          ),
          _UploadSlot(
            icon: Icons.slideshow_rounded,
            title: 'Pitch Deck Slot',
            subtitle: 'Drop presentation file or add hosted link',
          ),
          _UploadSlot(
            icon: Icons.ondemand_video_rounded,
            title: 'Demo Video Slot',
            subtitle: 'Reserve space for the final walkthrough clip',
          ),
          _UploadSlot(
            icon: Icons.link_rounded,
            title: 'Repository Slot',
            subtitle: 'Connect GitHub or GitLab project URL',
          ),
        ],
      ),
    );
  }
}

class _UploadSlot extends StatelessWidget {
  const _UploadSlot({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ParticipantPalette.primary.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
          color: ParticipantPalette.primary.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ParticipantPalette.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ParticipantPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ParticipantPalette.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded,
                color: ParticipantPalette.primary),
          ],
        ),
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Submission Notes',
            subtitle: 'Helpful reminders styled as a participant checklist.',
          ),
          ParticipantBulletRow(
            text: 'Keep all shared links accessible to judges without extra login friction.',
            icon: Icons.verified_user_rounded,
            color: ParticipantPalette.primary,
          ),
          ParticipantBulletRow(
            text: 'Demo video should focus on the problem, flow, and impact in under 90 seconds.',
            icon: Icons.movie_creation_rounded,
            color: ParticipantPalette.secondary,
          ),
          ParticipantBulletRow(
            text: 'Last-minute edits after lock may not be accepted unless approved by organizers.',
            icon: Icons.warning_amber_rounded,
            color: ParticipantPalette.warning,
          ),
        ],
      ),
    );
  }
}
