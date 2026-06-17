import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/widgets/hackathon_cover.dart';
import '../../submit/models/submission_models.dart';
import '../../submit/utils/submission_validators.dart';
import 'admin_manage_judges_screen.dart';

String _formatDate(DateTime? date) {
  if (date == null) {
    return '';
  }

  final month =
      <int, String>{
        1: 'Jan',
        2: 'Feb',
        3: 'Mar',
        4: 'Apr',
        5: 'May',
        6: 'Jun',
        7: 'Jul',
        8: 'Aug',
        9: 'Sep',
        10: 'Oct',
        11: 'Nov',
        12: 'Dec',
      }[date.month];

  return '${date.day} $month ${date.year}';
}

class AdminManageHackathonsScreen extends StatefulWidget {
  const AdminManageHackathonsScreen({super.key});

  @override
  State<AdminManageHackathonsScreen> createState() =>
      _AdminManageHackathonsScreenState();
}

class _AdminManageHackathonsScreenState
    extends State<AdminManageHackathonsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HackathonSummary> _filterHackathons(List<HackathonSummary> hackathons) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return hackathons;
    }

    return hackathons.where((hackathon) {
      final searchable =
          [
            hackathon.title,
            hackathon.status,
            _formatDate(hackathon.startDate?.toDate()),
            _formatDate(hackathon.endDate?.toDate()),
            _formatDate(hackathon.createdAt?.toDate()),
          ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAddHackathonScreen()),
          );
        },
        backgroundColor: const Color(0xFF4F39F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Hackathon'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('hackathons').snapshots(),
        builder: (context, snapshot) {
          final hackathons =
              snapshot.data?.docs.map(HackathonSummary.fromDocument).toList() ??
              <HackathonSummary>[];
          hackathons.sort((a, b) {
            return (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
              a.createdAt?.millisecondsSinceEpoch ?? 0,
            );
          });
          final filteredHackathons = _filterHackathons(hackathons);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4F39F6),
                        Color(0xFF9810FA),
                        Color(0xFF432DD7),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(34),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${hackathons.length} Live',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Manage Hackathons',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create hackathons, configure participant Google Forms, and keep organiser review links ready for judges.',
                        style: TextStyle(
                          color: Color(0xFFEAE7FF),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _HackathonSearchHeaderDelegate(
                  child: _HackathonSearchBar(
                    controller: _searchController,
                    onChanged:
                        (value) => setState(() {
                          _searchQuery = value;
                        }),
                    onClear: _clearSearch,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (snapshot.hasError)
                      const _AdminStateCard(
                        title: 'Could not load hackathons',
                        subtitle:
                            'Please try again once Firestore is reachable.',
                        icon: Icons.error_outline_rounded,
                      )
                    else if (hackathons.isEmpty)
                      const _AdminStateCard(
                        title: 'No hackathons yet',
                        subtitle:
                            'Create the first event to make it available for team leaders.',
                        icon: Icons.event_busy_outlined,
                      )
                    else if (filteredHackathons.isEmpty)
                      const _AdminStateCard(
                        title: 'No matching hackathons',
                        subtitle:
                            'Try searching by hackathon name, date, or status.',
                        icon: Icons.search_off_rounded,
                      )
                    else
                      ...filteredHackathons.map(
                        (hackathon) =>
                            _HackathonAdminCard(hackathon: hackathon),
                      ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HackathonSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HackathonSearchHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Container(
        color: const Color(0xFFF3F4F6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HackathonSearchHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _HackathonSearchBar extends StatelessWidget {
  const _HackathonSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search by name, date, or status',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon:
                value.text.isEmpty
                    ? null
                    : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
        );
      },
    );
  }
}

class AdminAddHackathonScreen extends StatefulWidget {
  const AdminAddHackathonScreen({super.key, this.hackathon});

  final HackathonSummary? hackathon;

  @override
  State<AdminAddHackathonScreen> createState() =>
      _AdminAddHackathonScreenState();
}

class _AdminAddHackathonScreenState extends State<AdminAddHackathonScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _participantFormUrlController =
      TextEditingController();
  final TextEditingController _reviewUrlController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedImageBytes;
  String _imageBase64 = '';
  String _status = 'Upcoming';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  bool get _isEditing => widget.hackathon != null;

  @override
  void initState() {
    super.initState();
    final hackathon = widget.hackathon;
    if (hackathon == null) {
      return;
    }

    _titleController.text = hackathon.title;
    _descriptionController.text = hackathon.description;
    _participantFormUrlController.text = hackathon.participantFormUrl;
    _reviewUrlController.text = hackathon.reviewUrl;
    _imageBase64 = hackathon.imageBase64;
    _status = _normalizeStatus(hackathon.status);
    _startDate = hackathon.startDate?.toDate();
    _endDate = hackathon.endDate?.toDate();
    _startDateController.text = _formatDate(_startDate);
    _endDateController.text = _formatDate(_endDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _participantFormUrlController.dispose();
    _reviewUrlController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _normalizeStatus(String status) {
    const statuses = ['Upcoming', 'Active', 'Closed'];
    return statuses.contains(status) ? status : 'Upcoming';
  }

  Future<void> _pickDate({
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final initialDate = selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) {
      return;
    }

    onPicked(picked);
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedImageBytes = bytes;
      _imageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _createOrUpdateHackathon() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'imageBase64': _imageBase64,
      'participantFormUrl': SubmissionValidators.normalizeUrl(
        _participantFormUrlController.text,
      ),
      'reviewUrl': SubmissionValidators.normalizeUrl(_reviewUrlController.text),
      'status': _status,
      'startDate': _startDate == null ? null : Timestamp.fromDate(_startDate!),
      'endDate': _endDate == null ? null : Timestamp.fromDate(_endDate!),
    };

    try {
      if (_isEditing) {
        await FirebaseFirestore.instance
            .collection('hackathons')
            .doc(widget.hackathon!.id)
            .set(payload, SetOptions(merge: true));
      } else {
        payload['registeredTeams'] = <String>[];
        payload['judgeAssignments'] = <Map<String, dynamic>>[];
        payload['createdAt'] = FieldValue.serverTimestamp();
        payload['createdBy'] = FirebaseAuth.instance.currentUser?.email;
        payload['finalResultsRevealed'] = false;
        payload['finalResultsPublishedAt'] = null;
        payload['finalResultsPublishedBy'] = '';
        payload['judgingRules'] = {
          'judgesPerTeam': 2,
          'scoreScale': 10,
          'scoreScaleMode': '1-10',
          'allowScoreEditing': true,
          'anonymousJudging': false,
          'minimumJudgesRequired': 1,
          'scoringMethod': 'Average Score',
          'judgeSubmissionDeadline': null,
        };
        payload['submissionRequirements'] = {
          'requireProjectTitle': true,
          'requireDescription': true,
          'requireGithub': true,
          'requireDemoVideo': false,
          'requireSlides': false,
          'submissionDeadline': '',
        };
        await FirebaseFirestore.instance.collection('hackathons').add(payload);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Hackathon updated successfully.'
                : 'Hackathon added successfully.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Failed to update hackathon: $error'
                : 'Failed to add hackathon: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Text(_isEditing ? 'Edit Hackathon' : 'Add Hackathon'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            children: [
              _AdminFormCard(
                title: 'Hackathon Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AdminInputLabel('Hackathon Name *'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _titleController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Please enter the hackathon name.';
                        }
                        return null;
                      },
                      decoration: _inputDecoration('Spring Hack 2026'),
                    ),
                    const SizedBox(height: 20),
                    _AdminInputLabel('Description *'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Please enter the description.';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        'Write what teams should know about this hackathon.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _AdminInputLabel('Participant Google Form URL *'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _participantFormUrlController,
                      validator:
                          (value) =>
                              SubmissionValidators.validateRequiredHttpsUrl(
                                value,
                                label: 'the participant Google Form URL',
                              ),
                      decoration: _inputDecoration(
                        'https://docs.google.com/forms/...',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _AdminInputLabel('Organiser Review URL *'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _reviewUrlController,
                      validator:
                          (value) =>
                              SubmissionValidators.validateRequiredHttpsUrl(
                                value,
                                label: 'the organiser review URL',
                              ),
                      decoration: _inputDecoration(
                        'https://docs.google.com/spreadsheets/...',
                      ),
                    ),
                  ],
                ),
              ),
              _AdminFormCard(
                title: 'Status & Schedule',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AdminInputLabel('Status'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: _inputDecoration('Status'),
                      items:
                          const ['Upcoming', 'Active', 'Closed']
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _status = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startDateController,
                            readOnly: true,
                            decoration: _inputDecoration('Start date'),
                            onTap:
                                () => _pickDate(
                                  selectedDate: _startDate,
                                  onPicked: (date) {
                                    setState(() {
                                      _startDate = date;
                                      _startDateController.text = _formatDate(
                                        date,
                                      );
                                    });
                                  },
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _endDateController,
                            readOnly: true,
                            decoration: _inputDecoration('End date'),
                            onTap:
                                () => _pickDate(
                                  selectedDate: _endDate,
                                  onPicked: (date) {
                                    setState(() {
                                      _endDate = date;
                                      _endDateController.text = _formatDate(
                                        date,
                                      );
                                    });
                                  },
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _AdminFormCard(
                title: 'Poster / Picture',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedImageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _selectedImageBytes!,
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      HackathonCover(
                        imageBase64: _imageBase64,
                        height: 190,
                        placeholderLabel: 'Pick a poster image',
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Choose Image'),
                          ),
                        ),
                        if (_imageBase64.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedImageBytes = null;
                                _imageBase64 = '';
                              });
                            },
                            child: const Text('Remove'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Images are stored directly in Firestore for this demo flow, so a smaller poster works best.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _createOrUpdateHackathon,
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(
                            _isEditing
                                ? Icons.save_rounded
                                : Icons.rocket_launch_rounded,
                          ),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isEditing
                        ? 'Save Changes'
                        : 'Publish Hackathon',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F39F6),
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
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _HackathonAdminCard extends StatelessWidget {
  const _HackathonAdminCard({required this.hackathon});

  final HackathonSummary hackathon;

  void _openSettings(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/app/admin/hackathon/${Uri.encodeComponent(hackathon.id)}/settings',
    );
  }

  Future<void> _deleteHackathon(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Hackathon'),
            content: Text('Delete ${hackathon.title}? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('hackathons')
          .doc(hackathon.id)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Hackathon deleted.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete hackathon: $error')),
        );
      }
    }
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsSheetItem(
                  icon: Icons.edit_rounded,
                  label: 'Edit Hackathon',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                AdminAddHackathonScreen(hackathon: hackathon),
                      ),
                    );
                  },
                ),
                _SettingsSheetItem(
                  icon: Icons.rule_rounded,
                  label: 'Configure Scoring',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openSettings(context);
                  },
                ),
                _SettingsSheetItem(
                  icon: Icons.tune_rounded,
                  label: 'Weightage Settings',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openSettings(context);
                  },
                ),
                _SettingsSheetItem(
                  icon: Icons.gavel_rounded,
                  label: 'Judging Rules',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openSettings(context);
                  },
                ),
                _SettingsSheetItem(
                  icon: Icons.assignment_turned_in_rounded,
                  label: 'Submission Requirements',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openSettings(context);
                  },
                ),
                _SettingsSheetItem(
                  icon: Icons.groups_rounded,
                  label: 'Assign Judges',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminManageJudgesScreen(),
                      ),
                    );
                  },
                ),
                _SettingsSheetItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete Hackathon',
                  color: const Color(0xFFDC2626),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _deleteHackathon(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSettings(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                HackathonCover(
                  imageBase64: hackathon.imageBase64,
                  height: 180,
                  placeholderLabel: 'No poster uploaded',
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => _showSettingsSheet(context),
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: Color(0xFF4F39F6),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _StatusChip(
                    label: hackathon.status,
                    color: _statusColor(hackathon.status),
                    backgroundColor: _statusBackgroundColor(hackathon.status),
                  ),
                ),
              ],
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
                          color: Color(0xFF111827),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hackathon.description.isEmpty
                            ? 'No description'
                            : hackathon.description,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${hackathon.registeredTeams.length} Teams',
                    style: const TextStyle(
                      color: Color(0xFF4F39F6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label:
                      hackathon.hasParticipantFormUrl
                          ? 'Participant Form Ready'
                          : 'Participant Form Missing',
                  color:
                      hackathon.hasParticipantFormUrl
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                  backgroundColor:
                      hackathon.hasParticipantFormUrl
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                ),
                _StatusChip(
                  label:
                      hackathon.hasReviewUrl
                          ? 'Review URL Ready'
                          : 'Review URL Missing',
                  color:
                      hackathon.hasReviewUrl
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFDC2626),
                  backgroundColor:
                      hackathon.hasReviewUrl
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFFEE2E2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dateLabel(),
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  'Organizer ${_organizerName(hackathon.createdBy)}',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel() {
    if (hackathon.startDate != null && hackathon.endDate != null) {
      return '${_formatDate(hackathon.startDate!.toDate())} - ${_formatDate(hackathon.endDate!.toDate())}';
    }
    if (hackathon.startDate != null) {
      return 'Starts ${_formatDate(hackathon.startDate!.toDate())}';
    }
    if (hackathon.createdAt != null) {
      return _formatDate(hackathon.createdAt!.toDate());
    }
    return 'Publishing...';
  }

  String _organizerName(String createdBy) {
    final trimmed = createdBy.trim();
    if (trimmed.isEmpty) {
      return 'Admin';
    }

    final emailName = trimmed.split('@').first;
    return emailName
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF16A34A);
      case 'Closed':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }

  Color _statusBackgroundColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFFDCFCE7);
      case 'Closed':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }
}

class _SettingsSheetItem extends StatelessWidget {
  const _SettingsSheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF111827),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
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
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AdminStateCard extends StatelessWidget {
  const _AdminStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF6D55F8)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminFormCard extends StatelessWidget {
  const _AdminFormCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _AdminInputLabel extends StatelessWidget {
  const _AdminInputLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
