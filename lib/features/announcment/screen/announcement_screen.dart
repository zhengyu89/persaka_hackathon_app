import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/schedule_service.dart';
import '../../../shared/widgets/participant_ui.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final ScheduleService _service = ScheduleService();
  String _selectedFilter = 'All';

  static const List<String> _filters = ['All', 'Important', 'General'];

  @override
  Widget build(BuildContext context) {
    return ParticipantPageScaffold(
      title: 'Announcements',
      subtitle: 'Stay up to date with everything happening at the event.',
      icon: Icons.campaign_rounded,
      trailing: const _NotificationIcon(),
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: _service.getAnnouncements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const ParticipantCard(
                child: SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ParticipantPalette.primary,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return const ParticipantCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParticipantSectionHeader(
                      title: 'Latest Updates',
                      subtitle: 'Announcements are currently unavailable.',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Failed to load announcements',
                          style: TextStyle(color: ParticipantPalette.danger),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const ParticipantCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParticipantSectionHeader(
                      title: 'Latest Updates',
                      subtitle: 'Important updates will appear here.',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No announcements yet',
                          style: TextStyle(color: ParticipantPalette.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // NOTE: matches the assumption already baked into the old
            // ScheduleScreen announcements tab — the query is assumed to
            // return most-recent-first, so the first doc is treated as the
            // pinned/"Important" one. There is no real isImportant field in
            // Firestore yet (confirmed via ManageScheduleScreen's "Post
            // Announcement" dialog, which only collects title + message).
            final allItems = docs.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value.data() as Map<String, dynamic>;
              return _AnnouncementData(
                title: data['title'] ?? '',
                message: data['message'] ?? '',
                createdBy: data['createdBy'] ?? '',
                createdAt: data['createdAt'] as Timestamp?,
                isImportant: index == 0,
              );
            }).toList();

            final filtered = switch (_selectedFilter) {
              'Important' => allItems.where((a) => a.isImportant).toList(),
              'General' => allItems.where((a) => !a.isImportant).toList(),
              _ => allItems,
            };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilterChipRow(
                  filters: _filters,
                  selected: _selectedFilter,
                  onSelected: (value) =>
                      setState(() => _selectedFilter = value),
                ),
                ParticipantCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ParticipantSectionHeader(
                        title: 'Latest Updates',
                        subtitle:
                            '${filtered.length} update${filtered.length == 1 ? '' : 's'}',
                      ),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No announcements in this category yet.',
                              style:
                                  TextStyle(color: ParticipantPalette.textSecondary),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((item) => _AnnouncementTile(item: item)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AnnouncementData {
  const _AnnouncementData({
    required this.title,
    required this.message,
    required this.createdBy,
    required this.createdAt,
    required this.isImportant,
  });

  final String title;
  final String message;
  final String createdBy;
  final Timestamp? createdAt;
  final bool isImportant;

  String get timeAgo {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final dt = createdAt!.toDate();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.item});

  final _AnnouncementData item;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        item.isImportant ? ParticipantPalette.danger : ParticipantPalette.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.isImportant) ...[
                      const ParticipantInfoChip(
                        label: 'Important',
                        color: ParticipantPalette.danger,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: ParticipantPalette.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (item.timeAgo.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.timeAgo,
                          style: TextStyle(
                            color: ParticipantPalette.textSecondary.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.message,
                  style: const TextStyle(
                    color: ParticipantPalette.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (item.createdBy.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: ParticipantPalette.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Posted by ${item.createdBy}',
                        style: TextStyle(
                          color: ParticipantPalette.textSecondary.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ParticipantPalette.primary
                      : ParticipantPalette.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : ParticipantPalette.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.notifications_rounded, color: Colors.white),
    );
  }
}
