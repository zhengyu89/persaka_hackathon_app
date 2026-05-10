import 'dart:typed_data';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/widgets/hackathon_cover.dart';

class AdminManageHackathonsScreen extends StatelessWidget {
  const AdminManageHackathonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminAddHackathonScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4F39F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Hackathon'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('hackathons')
            .snapshots(),
        builder: (context, snapshot) {
          final hackathons = snapshot.data?.docs.toList() ?? [];
          hackathons.sort((a, b) {
            final aTime = a.data()['createdAt'] as Timestamp?;
            final bTime = b.data()['createdAt'] as Timestamp?;
            return (bTime?.millisecondsSinceEpoch ?? 0)
                .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
          });

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
                        'Create new hackathons with a description and poster, then let team leaders register from the team workspace.',
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
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
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
                      else
                        ...hackathons.map(
                          (doc) => _HackathonAdminCard(doc: doc),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdminAddHackathonScreen extends StatefulWidget {
  const AdminAddHackathonScreen({super.key});

  @override
  State<AdminAddHackathonScreen> createState() =>
      _AdminAddHackathonScreenState();
}

class _AdminAddHackathonScreenState
    extends State<AdminAddHackathonScreen> {
  final TextEditingController _titleController =
      TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedImageBytes;
  String _imageBase64 = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _createHackathon() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both title and description.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('hackathons').add({
        'title': title,
        'description': description,
        'imageBase64': _imageBase64,
        'registeredTeams': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.email,
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hackathon added successfully.'),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add hackathon: $error'),
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
        title: const Text('Add Hackathon'),
      ),
      body: SingleChildScrollView(
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
                  TextField(
                    controller: _titleController,
                    decoration: _inputDecoration('Spring Hack 2026'),
                  ),
                  const SizedBox(height: 20),
                  _AdminInputLabel('Description *'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: _inputDecoration(
                      'Write what teams should know about this hackathon.',
                    ),
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
                    const HackathonCover(
                      imageBase64: '',
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
                      if (_selectedImageBytes != null) ...[
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
                onPressed: _isSaving ? null : _createHackathon,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.rocket_launch_rounded),
                label: Text(_isSaving ? 'Saving...' : 'Publish Hackathon'),
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}

class _HackathonAdminCard extends StatelessWidget {
  const _HackathonAdminCard({
    required this.doc,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final registeredTeams =
        List<String>.from(data['registeredTeams'] ?? const []);
    final createdAt = data['createdAt'] as Timestamp?;

    return Container(
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
          HackathonCover(
            imageBase64: data['imageBase64'] ?? '',
            height: 180,
            placeholderLabel: 'No poster uploaded',
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
                      data['title'] ?? 'Untitled Hackathon',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No description',
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
                  '${registeredTeams.length} Teams',
                  style: const TextStyle(
                    color: Color(0xFF4F39F6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
              Text(
                createdAt == null
                    ? 'Publishing...'
                    : _formatDate(createdAt.toDate()),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                'Created by ${data['createdBy'] ?? 'admin'}',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = <int, String>{
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
          Icon(
            icon,
            size: 40,
            color: const Color(0xFF6D55F8),
          ),
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
  const _AdminFormCard({
    required this.title,
    required this.child,
  });

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
