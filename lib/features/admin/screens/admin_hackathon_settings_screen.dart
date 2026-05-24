import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../submit/models/submission_models.dart';

class AdminHackathonSettingsScreen extends StatelessWidget {
  const AdminHackathonSettingsScreen({super.key, required this.hackathonId});

  final String hackathonId;

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('hackathons')
        .doc(hackathonId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final hackathon =
            data == null ? null : HackathonSummary.fromMap(hackathonId, data);

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF111827),
            elevation: 0,
            title: Text(hackathon?.title ?? 'Hackathon Settings'),
          ),
          body:
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : hackathon == null
                  ? const _SettingsStateCard(
                    icon: Icons.error_outline_rounded,
                    title: 'Hackathon not found',
                    subtitle: 'This settings page needs an existing hackathon.',
                  )
                  : _SettingsForm(hackathon: hackathon),
        );
      },
    );
  }
}

class _SettingsForm extends StatefulWidget {
  const _SettingsForm({required this.hackathon});

  final HackathonSummary hackathon;

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  final TextEditingController _judgesPerTeamController =
      TextEditingController();
  final TextEditingController _scoreScaleController = TextEditingController();
  final TextEditingController _submissionDeadlineController =
      TextEditingController();

  bool _allowScoreEditing = true;
  bool _anonymousJudging = false;
  bool _requireProjectTitle = true;
  bool _requireDescription = true;
  bool _requireGithub = true;
  bool _requireDemoVideo = false;
  bool _requireSlides = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _hydrate(widget.hackathon);
  }

  @override
  void didUpdateWidget(covariant _SettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hackathon.id != widget.hackathon.id) {
      _hydrate(widget.hackathon);
    }
  }

  @override
  void dispose() {
    _judgesPerTeamController.dispose();
    _scoreScaleController.dispose();
    _submissionDeadlineController.dispose();
    super.dispose();
  }

  void _hydrate(HackathonSummary hackathon) {
    final judging = hackathon.judgingRules;
    final requirements = hackathon.submissionRequirements;
    _judgesPerTeamController.text =
        (judging['judgesPerTeam'] ?? 2).toString();
    _scoreScaleController.text = (judging['scoreScale'] ?? 10).toString();
    _allowScoreEditing = judging['allowScoreEditing'] != false;
    _anonymousJudging = judging['anonymousJudging'] == true;
    _requireProjectTitle = requirements['requireProjectTitle'] != false;
    _requireDescription = requirements['requireDescription'] != false;
    _requireGithub = requirements['requireGithub'] != false;
    _requireDemoVideo = requirements['requireDemoVideo'] == true;
    _requireSlides = requirements['requireSlides'] == true;
    _submissionDeadlineController.text =
        (requirements['submissionDeadline'] ?? '').toString();
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    final judgesPerTeam =
        int.tryParse(_judgesPerTeamController.text.trim()) ?? 2;
    final scoreScale = int.tryParse(_scoreScaleController.text.trim()) ?? 10;

    try {
      await FirebaseFirestore.instance
          .collection('hackathons')
          .doc(widget.hackathon.id)
          .set({
            'judgingRules': {
              'judgesPerTeam': judgesPerTeam,
              'scoreScale': scoreScale,
              'allowScoreEditing': _allowScoreEditing,
              'anonymousJudging': _anonymousJudging,
            },
            'submissionRequirements': {
              'requireProjectTitle': _requireProjectTitle,
              'requireDescription': _requireDescription,
              'requireGithub': _requireGithub,
              'requireDemoVideo': _requireDemoVideo,
              'requireSlides': _requireSlides,
              'submissionDeadline': _submissionDeadlineController.text.trim(),
            },
          }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hackathon settings saved.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showCriteriaSheet({
    DocumentSnapshot<Map<String, dynamic>>? criterion,
  }) async {
    final data = criterion?.data() ?? const <String, dynamic>{};
    final nameController = TextEditingController(
      text: (data['name'] ?? '').toString(),
    );
    final descriptionController = TextEditingController(
      text: (data['description'] ?? '').toString(),
    );
    final weightController = TextEditingController(
      text: (data['weight'] ?? 0).toString(),
    );
    final maxScoreController = TextEditingController(
      text: (data['maxScore'] ?? 10).toString(),
    );
    var active = data['active'] != false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                18,
                16,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    criterion == null ? 'Add Criterion' : 'Edit Criterion',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: _inputDecoration('Criterion name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: _inputDecoration('Description'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Weight'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxScoreController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Max score'),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    value: active,
                    onChanged:
                        (value) => setSheetState(() {
                          active = value;
                        }),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    activeColor: const Color(0xFF4F39F6),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final payload = {
                          'name': nameController.text.trim(),
                          'description': descriptionController.text.trim(),
                          'weight':
                              double.tryParse(weightController.text.trim()) ??
                              0,
                          'maxScore':
                              double.tryParse(maxScoreController.text.trim()) ??
                              10,
                          'active': active,
                        };
                        final collection = FirebaseFirestore.instance
                            .collection('hackathons')
                            .doc(widget.hackathon.id)
                            .collection('criteria');
                        if (criterion == null) {
                          await collection.add(payload);
                        } else {
                          await collection
                              .doc(criterion.id)
                              .set(payload, SetOptions(merge: true));
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F39F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Save Criterion'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    weightController.dispose();
    maxScoreController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          _SettingsCard(
            title: 'Judging Rules',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _judgesPerTeamController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Judges per team'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _scoreScaleController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Score scale'),
                      ),
                    ),
                  ],
                ),
                _SettingsSwitch(
                  title: 'Allow score editing',
                  value: _allowScoreEditing,
                  onChanged:
                      (value) => setState(() {
                        _allowScoreEditing = value;
                      }),
                ),
                _SettingsSwitch(
                  title: 'Anonymous judging',
                  value: _anonymousJudging,
                  onChanged:
                      (value) => setState(() {
                        _anonymousJudging = value;
                      }),
                ),
              ],
            ),
          ),
          _SettingsCard(
            title: 'Scoring Criteria',
            action: TextButton.icon(
              onPressed: () => _showCriteriaSheet(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance
                      .collection('hackathons')
                      .doc(widget.hackathon.id)
                      .collection('criteria')
                      .snapshots(),
              builder: (context, snapshot) {
                final criteria =
                    snapshot.data?.docs ??
                    const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                if (criteria.isEmpty) {
                  return const Text(
                    'No criteria yet.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  );
                }
                return Column(
                  children:
                      criteria.map((doc) {
                        final data = doc.data();
                        return _CriteriaTile(
                          name: (data['name'] ?? 'Untitled').toString(),
                          description: (data['description'] ?? '').toString(),
                          weight: (data['weight'] ?? 0).toString(),
                          maxScore: (data['maxScore'] ?? 10).toString(),
                          active: data['active'] != false,
                          onTap: () => _showCriteriaSheet(criterion: doc),
                        );
                      }).toList(),
                );
              },
            ),
          ),
          _SettingsCard(
            title: 'Score Weightage',
            child: const Text(
              'Criteria weights are saved inside each criteria document.',
              style: TextStyle(color: Color(0xFF6B7280), height: 1.4),
            ),
          ),
          _SettingsCard(
            title: 'Submission Requirements',
            child: Column(
              children: [
                _SettingsSwitch(
                  title: 'Project title',
                  value: _requireProjectTitle,
                  onChanged:
                      (value) => setState(() {
                        _requireProjectTitle = value;
                      }),
                ),
                _SettingsSwitch(
                  title: 'Description',
                  value: _requireDescription,
                  onChanged:
                      (value) => setState(() {
                        _requireDescription = value;
                      }),
                ),
                _SettingsSwitch(
                  title: 'GitHub link',
                  value: _requireGithub,
                  onChanged:
                      (value) => setState(() {
                        _requireGithub = value;
                      }),
                ),
                _SettingsSwitch(
                  title: 'Demo video',
                  value: _requireDemoVideo,
                  onChanged:
                      (value) => setState(() {
                        _requireDemoVideo = value;
                      }),
                ),
                _SettingsSwitch(
                  title: 'Slides',
                  value: _requireSlides,
                  onChanged:
                      (value) => setState(() {
                        _requireSlides = value;
                      }),
                ),
                TextField(
                  controller: _submissionDeadlineController,
                  decoration: _inputDecoration('Submission deadline'),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
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
                      : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
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
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFF4F39F6),
    );
  }
}

class _CriteriaTile extends StatelessWidget {
  const _CriteriaTile({
    required this.name,
    required this.description,
    required this.weight,
    required this.maxScore,
    required this.active,
    required this.onTap,
  });

  final String name;
  final String description;
  final String weight;
  final String maxScore;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        description.isEmpty
            ? 'Weight $weight | Max $maxScore'
            : '$description\nWeight $weight | Max $maxScore',
      ),
      trailing: Icon(
        active ? Icons.check_circle_rounded : Icons.pause_circle_outline,
        color: active ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
      ),
    );
  }
}

class _SettingsStateCard extends StatelessWidget {
  const _SettingsStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }
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
