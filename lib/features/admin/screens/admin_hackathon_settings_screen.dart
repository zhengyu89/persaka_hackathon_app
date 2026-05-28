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
  final TextEditingController _minimumJudgesController =
      TextEditingController();
  final TextEditingController _judgeSubmissionDeadlineController =
      TextEditingController();

  bool _allowScoreEditing = true;
  bool _anonymousJudging = false;
  String _scoreScaleOption = '1-10';
  String _scoringMethod = 'Average Score';
  DateTime? _judgeSubmissionDeadline;
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
    _minimumJudgesController.dispose();
    _judgeSubmissionDeadlineController.dispose();
    super.dispose();
  }

  void _hydrate(HackathonSummary hackathon) {
    final judging = hackathon.judgingRules;
    final requirements = hackathon.submissionRequirements;
    _judgesPerTeamController.text = (judging['judgesPerTeam'] ?? 2).toString();
    final scoreScale = (judging['scoreScale'] ?? 10).toString();
    _scoreScaleOption =
        const ['5', '10', '100'].contains(scoreScale)
            ? '1-$scoreScale'
            : 'Custom';
    _scoreScaleController.text = scoreScale;
    _allowScoreEditing = judging['allowScoreEditing'] != false;
    _anonymousJudging = judging['anonymousJudging'] == true;
    _minimumJudgesController.text =
        (judging['minimumJudgesRequired'] ?? 1).toString();
    _scoringMethod = (judging['scoringMethod'] ?? 'Average Score').toString();
    if (!const [
      'Average Score',
      'Highest Score',
      'Weighted Average',
    ].contains(_scoringMethod)) {
      _scoringMethod = 'Average Score';
    }
    final deadline = judging['judgeSubmissionDeadline'];
    _judgeSubmissionDeadline =
        deadline is Timestamp
            ? deadline.toDate()
            : DateTime.tryParse((deadline ?? '').toString());
    _judgeSubmissionDeadlineController.text = _formatDateTime(
      _judgeSubmissionDeadline,
    );
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
    final scoreScale =
        _scoreScaleOption == 'Custom'
            ? int.tryParse(_scoreScaleController.text.trim()) ?? 10
            : int.tryParse(_scoreScaleOption.replaceFirst('1-', '')) ?? 10;
    final minimumJudgesRequired =
        int.tryParse(_minimumJudgesController.text.trim()) ?? 1;

    try {
      await FirebaseFirestore.instance
          .collection('hackathons')
          .doc(widget.hackathon.id)
          .set({
            'judgingRules': {
              'judgesPerTeam': judgesPerTeam,
              'scoreScale': scoreScale,
              'scoreScaleMode': _scoreScaleOption,
              'allowScoreEditing': _allowScoreEditing,
              'anonymousJudging': _anonymousJudging,
              'minimumJudgesRequired': minimumJudgesRequired,
              'scoringMethod': _scoringMethod,
              'judgeSubmissionDeadline':
                  _judgeSubmissionDeadline == null
                      ? null
                      : Timestamp.fromDate(_judgeSubmissionDeadline!),
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

  Future<void> _pickJudgeSubmissionDeadline() async {
    final initialDate = _judgeSubmissionDeadline ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final deadline = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _judgeSubmissionDeadline = deadline;
      _judgeSubmissionDeadlineController.text = _formatDateTime(deadline);
    });
  }

  Future<void> _showCriteriaSheet({
    DocumentSnapshot<Map<String, dynamic>>? criterion,
  }) async {
    final criteriaSnapshot =
        await FirebaseFirestore.instance
            .collection('hackathons')
            .doc(widget.hackathon.id)
            .collection('criteria')
            .get();

    if (!mounted) {
      return;
    }

    final activeWeightExcluding = criteriaSnapshot.docs
        .where((doc) => doc.id != criterion?.id && doc.data()['active'] != false)
        .fold<double>(
          0,
          (total, doc) => total + _numberValue(doc.data()['weight']),
        );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder:
          (context) => _CriterionEditorSheet(
            hackathonId: widget.hackathon.id,
            criterion: criterion,
            activeWeightExcludingCriterion: activeWeightExcluding,
          ),
    );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingField(
                  title: 'Judges Per Team',
                  helper: 'Number of judges assigned to evaluate each team',
                  child: TextField(
                    controller: _judgesPerTeamController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('2'),
                  ),
                ),
                _SettingField(
                  title: 'Score Scale',
                  helper: 'Maximum score judges can give',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _scoreScaleOption,
                        decoration: _inputDecoration('Score scale'),
                        items:
                            const ['1-5', '1-10', '1-100', 'Custom']
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _scoreScaleOption = value;
                            if (value != 'Custom') {
                              _scoreScaleController.text = value.replaceFirst(
                                '1-',
                                '',
                              );
                            }
                          });
                        },
                      ),
                      if (_scoreScaleOption == 'Custom') ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _scoreScaleController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Maximum score'),
                        ),
                      ],
                    ],
                  ),
                ),
                _SettingField(
                  title: 'Allow Score Editing',
                  helper: 'Allow judges to modify submitted scores',
                  child: _SettingsSwitch(
                    title: 'Allow score editing',
                    value: _allowScoreEditing,
                    onChanged:
                        (value) => setState(() {
                          _allowScoreEditing = value;
                        }),
                  ),
                ),
                _SettingField(
                  title: 'Anonymous Judging',
                  helper: 'Hide participant identity during judging',
                  child: _SettingsSwitch(
                    title: 'Anonymous judging',
                    value: _anonymousJudging,
                    onChanged:
                        (value) => setState(() {
                          _anonymousJudging = value;
                        }),
                  ),
                ),
                _SettingField(
                  title: 'Minimum Judges Required',
                  helper: 'Minimum completed evaluations required',
                  child: TextField(
                    controller: _minimumJudgesController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('1'),
                  ),
                ),
                _SettingField(
                  title: 'Scoring Method',
                  helper: 'How final score is calculated',
                  child: Column(
                    children:
                        const [
                          'Average Score',
                          'Highest Score',
                          'Weighted Average',
                        ].map((method) {
                          return RadioListTile<String>(
                            value: method,
                            groupValue: _scoringMethod,
                            onChanged:
                                (value) => setState(() {
                                  _scoringMethod = value ?? 'Average Score';
                                }),
                            title: Text(method),
                            activeColor: const Color(0xFF4F39F6),
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                  ),
                ),
                _SettingField(
                  title: 'Judge Submission Deadline',
                  helper: 'Deadline for judges to submit evaluations',
                  child: TextField(
                    controller: _judgeSubmissionDeadlineController,
                    readOnly: true,
                    onTap: _pickJudgeSubmissionDeadline,
                    decoration: _inputDecoration(
                      'Select date and time',
                    ).copyWith(
                      suffixIcon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed:
                        _judgeSubmissionDeadline == null
                            ? null
                            : () {
                              setState(() {
                                _judgeSubmissionDeadline = null;
                                _judgeSubmissionDeadlineController.clear();
                              });
                            },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Clear deadline'),
                  ),
                ),
              ],
            ),
          ),
          _SettingsCard(
            title: 'Scoring Criteria Management',
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
                final totalActiveWeight = criteria
                    .where((doc) => doc.data()['active'] != false)
                    .fold<double>(
                      0,
                      (total, doc) => total + _numberValue(doc.data()['weight']),
                    );
                if (criteria.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No criteria yet.',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 14),
                      _WeightSummary(totalWeight: totalActiveWeight),
                    ],
                  );
                }
                return Column(
                  children: [
                    ...criteria.map((doc) {
                      final data = doc.data();
                      return _CriteriaTile(
                        name: (data['name'] ?? 'Untitled').toString(),
                        description: (data['description'] ?? '').toString(),
                        weight: _numberValue(data['weight']),
                        maxScore: _numberValue(data['maxScore'], fallback: 10),
                        active: data['active'] != false,
                        onTap: () => _showCriteriaSheet(criterion: doc),
                      );
                    }),
                    const SizedBox(height: 14),
                    _WeightSummary(totalWeight: totalActiveWeight),
                  ],
                );
              },
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
          _ParticipatingTeamsSection(hackathon: widget.hackathon),
          _AssignedJudgesSection(hackathon: widget.hackathon),
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

class _SettingField extends StatelessWidget {
  const _SettingField({
    required this.title,
    required this.helper,
    required this.child,
  });

  final String title;
  final String helper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
          const SizedBox(height: 8),
          Text(
            helper,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
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
  final double weight;
  final double maxScore;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Description:',
              style: TextStyle(
                color: Color(0xFF374151),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description.isEmpty ? '-' : description,
              style: const TextStyle(color: Color(0xFF4B5563), height: 1.35),
            ),
            const SizedBox(height: 10),
            Text(
              'Weight: ${_formatNumber(weight)}%',
              style: const TextStyle(color: Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            Text(
              'Max Score: ${_formatNumber(maxScore)}',
              style: const TextStyle(color: Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${active ? 'Active' : 'Inactive'}',
              style: TextStyle(
                color:
                    active ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 28),
          ],
        ),
      ),
    );
  }
}

class _WeightSummary extends StatelessWidget {
  const _WeightSummary({required this.totalWeight});

  final double totalWeight;

  @override
  Widget build(BuildContext context) {
    final color =
        totalWeight == 100
            ? const Color(0xFF16A34A)
            : totalWeight < 100
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626);
    final message =
        totalWeight == 100
            ? '✓ Weight distribution valid'
            : totalWeight < 100
            ? '⚠ Remaining weight: ${_formatNumber(100 - totalWeight)}%'
            : '⚠ Total weight exceeds 100%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Weight: ${_formatNumber(totalWeight)}%',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CriterionEditorSheet extends StatefulWidget {
  const _CriterionEditorSheet({
    required this.hackathonId,
    required this.criterion,
    required this.activeWeightExcludingCriterion,
  });

  final String hackathonId;
  final DocumentSnapshot<Map<String, dynamic>>? criterion;
  final double activeWeightExcludingCriterion;

  @override
  State<_CriterionEditorSheet> createState() => _CriterionEditorSheetState();
}

class _CriterionEditorSheetState extends State<_CriterionEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _weightController;
  late final TextEditingController _maxScoreController;
  bool _active = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.criterion?.data() ?? const <String, dynamic>{};
    _nameController = TextEditingController(
      text: (data['name'] ?? '').toString(),
    );
    _descriptionController = TextEditingController(
      text: (data['description'] ?? '').toString(),
    );
    _weightController = TextEditingController(
      text: _formatNumber(_numberValue(data['weight'])),
    );
    _maxScoreController = TextEditingController(
      text: _formatNumber(_numberValue(data['maxScore'], fallback: 10)),
    );
    _active = data['active'] != false;
    _weightController.addListener(_refreshWeightPreview);
  }

  @override
  void dispose() {
    _weightController.removeListener(_refreshWeightPreview);
    _nameController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _maxScoreController.dispose();
    super.dispose();
  }

  void _refreshWeightPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  double get _enteredWeight => _numberValue(_weightController.text);

  double get _currentActiveWeight =>
      widget.activeWeightExcludingCriterion + (_active ? _enteredWeight : 0);

  double get _remainingWeight => 100 - _currentActiveWeight;

  Future<void> _saveCriterion() async {
    final name = _nameController.text.trim();
    final weight = double.tryParse(_weightController.text.trim()) ?? 0;
    final maxScore = double.tryParse(_maxScoreController.text.trim()) ?? 0;
    final totalActiveWeight =
        widget.activeWeightExcludingCriterion + (_active ? weight : 0);

    if (name.isEmpty) {
      _showError('Criterion name required');
      return;
    }
    if (weight <= 0) {
      _showError('Weight must be greater than 0');
      return;
    }
    if (weight > 100) {
      _showError('Weight must be 100% or less');
      return;
    }
    if (maxScore <= 0) {
      _showError('Maximum judge score must be greater than 0');
      return;
    }
    if (totalActiveWeight > 100) {
      _showError('Total active criteria weight cannot exceed 100%');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final payload = {
      'name': name,
      'description': _descriptionController.text.trim(),
      'weight': weight,
      'maxScore': maxScore,
      'active': _active,
    };

    try {
      final collection = FirebaseFirestore.instance
          .collection('hackathons')
          .doc(widget.hackathonId)
          .collection('criteria');
      if (widget.criterion == null) {
        await collection.add(payload);
      } else {
        await collection
            .doc(widget.criterion!.id)
            .set(payload, SetOptions(merge: true));
      }

      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError('Failed to save criterion: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFDC2626)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          18,
          16,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.criterion == null ? 'Add Criterion' : 'Edit Criterion',
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Criterion Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                decoration: _inputDecoration('Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Weight Percentage (%)').copyWith(
                  helperText: 'Contribution to final score',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _maxScoreController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Maximum Judge Score').copyWith(
                  helperText: 'Highest score judge can assign',
                ),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                value: _active,
                onChanged:
                    (value) => setState(() {
                      _active = value;
                    }),
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Criterion'),
                activeColor: const Color(0xFF4F39F6),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Active Weight: ${_formatNumber(_currentActiveWeight)}%',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Remaining: ${_formatNumber(_remainingWeight)}%',
                      style: TextStyle(
                        color:
                            _remainingWeight < 0
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCriterion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F39F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(_isSaving ? 'Saving...' : 'Save Criterion'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticipatingTeamsSection extends StatelessWidget {
  const _ParticipatingTeamsSection({required this.hackathon});

  final HackathonSummary hackathon;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Participating Teams',
      child: FutureBuilder<List<_AdminTeamInfo>>(
        future: _loadHackathonTeams(hackathon),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Text(
              'Could not load participating teams.',
              style: TextStyle(color: Color(0xFFDC2626)),
            );
          }
          final teams = snapshot.data ?? const <_AdminTeamInfo>[];
          if (teams.isEmpty) {
            return const Text(
              'No participating teams yet.',
              style: TextStyle(color: Color(0xFF6B7280)),
            );
          }
          return Column(
            children:
                teams.map((team) {
                  return _AdminTeamTile(
                    team: team,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AdminHackathonTeamDetailScreen(
                                hackathonId: hackathon.id,
                                hackathonName: hackathon.title,
                                teamCode: team.code,
                              ),
                        ),
                      );
                    },
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}

class _AssignedJudgesSection extends StatelessWidget {
  const _AssignedJudgesSection({required this.hackathon});

  final HackathonSummary hackathon;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Assigned Judges',
      child: FutureBuilder<List<_AdminJudgeInfo>>(
        future: _loadHackathonJudges(hackathon),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Text(
              'Could not load assigned judges.',
              style: TextStyle(color: Color(0xFFDC2626)),
            );
          }
          final judges = snapshot.data ?? const <_AdminJudgeInfo>[];
          if (judges.isEmpty) {
            return const Text(
              'No judges assigned yet.',
              style: TextStyle(color: Color(0xFF6B7280)),
            );
          }
          return Column(
            children:
                judges.map((judge) {
                  return _AdminJudgeTile(
                    judge: judge,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AdminHackathonJudgeDetailScreen(
                                hackathonId: hackathon.id,
                                hackathonName: hackathon.title,
                                judgeId: judge.id,
                              ),
                        ),
                      );
                    },
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}

class AdminHackathonTeamDetailScreen extends StatelessWidget {
  const AdminHackathonTeamDetailScreen({
    super.key,
    required this.hackathonId,
    required this.hackathonName,
    required this.teamCode,
  });

  final String hackathonId;
  final String hackathonName;
  final String teamCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text('Team Details'),
      ),
      body: FutureBuilder<_TeamDetailPayload>(
        future: _loadTeamDetail(hackathonId, hackathonName, teamCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const _SettingsStateCard(
              icon: Icons.error_outline_rounded,
              title: 'Team not found',
              subtitle: 'This team could not be loaded from Firebase.',
            );
          }

          final payload = snapshot.data!;
          final team = payload.team;
          final judge = payload.judge;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                _SettingsCard(
                  title: team.name,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailLine(label: 'Team Code', value: team.code),
                      _DetailLine(
                        label: 'Description',
                        value: team.description,
                      ),
                      _DetailLine(label: 'Team Leader', value: team.leader),
                      _DetailLine(
                        label: 'Hackathon Name',
                        value: payload.hackathonName,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Members',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            team.members
                                .map((member) => _MiniChip(label: member))
                                .toList(),
                      ),
                    ],
                  ),
                ),
                _SettingsCard(
                  title: 'Assigned Judge',
                  child:
                      judge == null
                          ? const Text(
                            'Not Assigned Yet',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailLine(
                                label: 'Judge Name',
                                value: judge.name,
                              ),
                              _DetailLine(
                                label: 'Judge Email',
                                value: judge.email,
                              ),
                              _DetailLine(
                                label: 'Specialty',
                                value: judge.specialty,
                              ),
                              _DetailLine(
                                label: 'Assigned Date',
                                value: _formatDateTime(
                                  judge.assignedAt?.toDate(),
                                ),
                              ),
                            ],
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminHackathonJudgeDetailScreen extends StatelessWidget {
  const AdminHackathonJudgeDetailScreen({
    super.key,
    required this.hackathonId,
    required this.hackathonName,
    required this.judgeId,
  });

  final String hackathonId;
  final String hackathonName;
  final String judgeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text('Judge Details'),
      ),
      body: FutureBuilder<_JudgeDetailPayload>(
        future: _loadJudgeDetail(hackathonId, judgeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const _SettingsStateCard(
              icon: Icons.error_outline_rounded,
              title: 'Judge not found',
              subtitle: 'This judge could not be loaded from Firebase.',
            );
          }

          final payload = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                _SettingsCard(
                  title: payload.judge.name,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailLine(label: 'Email', value: payload.judge.email),
                      _DetailLine(
                        label: 'Specialty',
                        value: payload.judge.specialty,
                      ),
                      _DetailLine(label: 'Hackathon', value: hackathonName),
                    ],
                  ),
                ),
                _SettingsCard(
                  title: 'Assigned Teams',
                  child:
                      payload.teams.isEmpty
                          ? const Text(
                            'No teams assigned in this hackathon.',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          )
                          : Column(
                            children:
                                payload.teams
                                    .map(
                                      (team) =>
                                          _AdminTeamCompactTile(team: team),
                                    )
                                    .toList(),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminTeamTile extends StatelessWidget {
  const _AdminTeamTile({required this.team, required this.onTap});

  final _AdminTeamInfo team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        team.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        [
          team.code,
          team.description.isEmpty ? 'No description' : team.description,
          'Leader: ${team.leader.isEmpty ? 'Unknown' : team.leader}',
        ].join('\n'),
      ),
      trailing: Text(
        '${team.members.length} Members',
        style: const TextStyle(
          color: Color(0xFF4F39F6),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminTeamCompactTile extends StatelessWidget {
  const _AdminTeamCompactTile({required this.team});

  final _AdminTeamInfo team;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        team.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${team.code}\nLeader: ${team.leader.isEmpty ? 'Unknown' : team.leader}',
      ),
    );
  }
}

class _AdminJudgeTile extends StatelessWidget {
  const _AdminJudgeTile({required this.judge, required this.onTap});

  final _AdminJudgeInfo judge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        judge.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('${judge.email}\n${judge.specialty}'),
      trailing: Text(
        '${judge.assignedTeamCount} Teams',
        style: const TextStyle(
          color: Color(0xFF4F39F6),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.trim().isEmpty ? '-' : value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4F39F6),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AdminTeamInfo {
  const _AdminTeamInfo({
    required this.code,
    required this.name,
    required this.description,
    required this.leader,
    required this.members,
  });

  final String code;
  final String name;
  final String description;
  final String leader;
  final List<String> members;

  factory _AdminTeamInfo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return _AdminTeamInfo(
      code: (data['teamCode'] ?? doc.id).toString(),
      name: (data['teamName'] ?? 'Untitled Team').toString(),
      description: (data['teamDescription'] ?? '').toString(),
      leader: (data['leader'] ?? '').toString(),
      members: List<String>.from(data['members'] ?? const <String>[]),
    );
  }
}

class _AdminJudgeInfo {
  const _AdminJudgeInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.specialty,
    required this.assignedTeamCount,
    this.assignedAt,
  });

  final String id;
  final String name;
  final String email;
  final String specialty;
  final int assignedTeamCount;
  final Timestamp? assignedAt;
}

class _TeamDetailPayload {
  const _TeamDetailPayload({
    required this.team,
    required this.hackathonName,
    required this.judge,
  });

  final _AdminTeamInfo team;
  final String hackathonName;
  final _AdminJudgeInfo? judge;
}

class _JudgeDetailPayload {
  const _JudgeDetailPayload({required this.judge, required this.teams});

  final _AdminJudgeInfo judge;
  final List<_AdminTeamInfo> teams;
}

Future<List<_AdminTeamInfo>> _loadHackathonTeams(
  HackathonSummary hackathon,
) async {
  final firestore = FirebaseFirestore.instance;
  final teams = <_AdminTeamInfo>[];
  for (final teamCode in hackathon.registeredTeams) {
    final doc = await firestore.collection('teams').doc(teamCode).get();
    if (doc.exists) {
      teams.add(_AdminTeamInfo.fromDoc(doc));
    }
  }
  return teams;
}

Future<List<_AdminJudgeInfo>> _loadHackathonJudges(
  HackathonSummary hackathon,
) async {
  final firestore = FirebaseFirestore.instance;
  final byJudge = <String, List<Map<String, dynamic>>>{};
  for (final entry in hackathon.judgeAssignments.entries) {
    if (entry.value is! Map) {
      continue;
    }
    final assignment = Map<String, dynamic>.from(entry.value as Map);
    final judgeId = (assignment['judgeId'] ?? '').toString();
    if (judgeId.isEmpty) {
      continue;
    }
    byJudge
        .putIfAbsent(judgeId, () => <Map<String, dynamic>>[])
        .add(assignment);
  }

  final judges = <_AdminJudgeInfo>[];
  for (final entry in byJudge.entries) {
    final doc = await firestore.collection('users').doc(entry.key).get();
    final data = doc.data() ?? const <String, dynamic>{};
    final firstAssignment = entry.value.first;
    judges.add(
      _AdminJudgeInfo(
        id: entry.key,
        name:
            (data['name'] ?? firstAssignment['judgeName'] ?? 'Unknown Judge')
                .toString(),
        email: (data['email'] ?? '').toString(),
        specialty:
            (data['specialty'] ?? data['specialization'] ?? 'General')
                .toString(),
        assignedTeamCount: entry.value.length,
        assignedAt: firstAssignment['assignedAt'] as Timestamp?,
      ),
    );
  }
  judges.sort((a, b) => a.name.compareTo(b.name));
  return judges;
}

Future<_TeamDetailPayload> _loadTeamDetail(
  String hackathonId,
  String hackathonName,
  String teamCode,
) async {
  final firestore = FirebaseFirestore.instance;
  final teamDoc = await firestore.collection('teams').doc(teamCode).get();
  final hackathonDoc =
      await firestore.collection('hackathons').doc(hackathonId).get();
  final hackathonData = hackathonDoc.data() ?? const <String, dynamic>{};
  final assignments = _normalizeAssignments(hackathonData['judgeAssignments']);
  final assignment = assignments[teamCode];
  _AdminJudgeInfo? judge;

  if (assignment != null) {
    final judgeId = (assignment['judgeId'] ?? '').toString();
    if (judgeId.isNotEmpty) {
      final judgeDoc = await firestore.collection('users').doc(judgeId).get();
      final judgeData = judgeDoc.data() ?? const <String, dynamic>{};
      judge = _AdminJudgeInfo(
        id: judgeId,
        name:
            (judgeData['name'] ?? assignment['judgeName'] ?? 'Unknown Judge')
                .toString(),
        email: (judgeData['email'] ?? '').toString(),
        specialty:
            (judgeData['specialty'] ?? judgeData['specialization'] ?? 'General')
                .toString(),
        assignedTeamCount: 1,
        assignedAt: assignment['assignedAt'] as Timestamp?,
      );
    }
  }

  return _TeamDetailPayload(
    team: _AdminTeamInfo.fromDoc(teamDoc),
    hackathonName: (hackathonData['title'] ?? hackathonName).toString(),
    judge: judge,
  );
}

Future<_JudgeDetailPayload> _loadJudgeDetail(
  String hackathonId,
  String judgeId,
) async {
  final firestore = FirebaseFirestore.instance;
  final judgeDoc = await firestore.collection('users').doc(judgeId).get();
  final judgeData = judgeDoc.data() ?? const <String, dynamic>{};
  final hackathonDoc =
      await firestore.collection('hackathons').doc(hackathonId).get();
  final assignments = _normalizeAssignments(
    hackathonDoc.data()?['judgeAssignments'],
  );
  final teamCodes =
      assignments.entries
          .where(
            (entry) => (entry.value['judgeId'] ?? '').toString() == judgeId,
          )
          .map((entry) => entry.key)
          .toList();

  final teams = <_AdminTeamInfo>[];
  for (final teamCode in teamCodes) {
    final teamDoc = await firestore.collection('teams').doc(teamCode).get();
    if (teamDoc.exists) {
      teams.add(_AdminTeamInfo.fromDoc(teamDoc));
    }
  }

  return _JudgeDetailPayload(
    judge: _AdminJudgeInfo(
      id: judgeId,
      name: (judgeData['name'] ?? 'Unknown Judge').toString(),
      email: (judgeData['email'] ?? '').toString(),
      specialty:
          (judgeData['specialty'] ?? judgeData['specialization'] ?? 'General')
              .toString(),
      assignedTeamCount: teams.length,
    ),
    teams: teams,
  );
}

Map<String, Map<String, dynamic>> _normalizeAssignments(
  Object? rawAssignments,
) {
  if (rawAssignments is Map) {
    return rawAssignments.map((key, value) {
      return MapEntry(
        key.toString(),
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{},
      );
    });
  }
  if (rawAssignments is List) {
    final normalized = <String, Map<String, dynamic>>{};
    for (final assignment in rawAssignments) {
      if (assignment is! Map) {
        continue;
      }
      final data = Map<String, dynamic>.from(assignment);
      final teamCode = (data['teamCode'] ?? data['teamId'] ?? '').toString();
      if (teamCode.isNotEmpty) {
        normalized[teamCode] = data;
      }
    }
    return normalized;
  }
  return const <String, Map<String, dynamic>>{};
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

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
}

double _numberValue(dynamic value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse((value ?? '').toString()) ?? fallback;
}

String _formatNumber(double value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
