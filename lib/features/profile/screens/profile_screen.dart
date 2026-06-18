import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/participant_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  String? _email;
  String? _role;
  String? _photoURL;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _authService.getUserProfile();
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    setState(() {
      _email = user?.email ?? '';
      _nameController.text =
          data?['name'] ?? data?['displayName'] ?? user?.displayName ?? '';
      _phoneController.text = data?['phoneNumber'] ?? '';
      _photoURL = data?['photoURL'];
      _role = data?['role'] ?? 'participant';
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _authService.updateProfile(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: ParticipantPalette.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: ParticipantPalette.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Log out',
              style: TextStyle(
                color: ParticipantPalette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Are you sure you want to log out?',
              style: TextStyle(color: ParticipantPalette.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ParticipantPalette.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Log out'),
              ),
            ],
          ),
    );
    if (confirmed != true) {
      return;
    }

    try {
      await _authService.logout();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout warning: ${e.toString()}'),
          backgroundColor: ParticipantPalette.warning,
        ),
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String get _roleLabel {
    switch (_role) {
      case 'admin':
        return 'Admin';
      case 'judge':
        return 'Judge';
      default:
        return 'Participant';
    }
  }

  Color get _roleColor {
    switch (_role) {
      case 'admin':
        return ParticipantPalette.danger;
      case 'judge':
        return ParticipantPalette.warning;
      default:
        return ParticipantPalette.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: ParticipantPalette.pageBackground,
        body: Center(
          child: CircularProgressIndicator(color: ParticipantPalette.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ParticipantPalette.pageBackground,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // Purple gradient header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
                decoration: const BoxDecoration(
                  gradient: ParticipantPalette.headerGradient,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    // Title + edit button row
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'My Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isEditing = !_isEditing),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isEditing ? Icons.close : Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isEditing ? 'Cancel' : 'Edit',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Avatar
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.white.withOpacity(0.22),
                            backgroundImage:
                                _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                    : (_photoURL != null
                                        ? NetworkImage(_photoURL!)
                                            as ImageProvider
                                        : null),
                            child:
                                _pickedImage == null && _photoURL == null
                                    ? Text(
                                      _initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                    : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ParticipantPalette.primary,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 15,
                                  color: ParticipantPalette.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      _nameController.text.isEmpty
                          ? 'Your Name'
                          : _nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Email
                    Text(
                      _email ?? '',
                      style: const TextStyle(
                        color: Color(0xFFEAE7FF),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _roleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Body cards
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              sliver: SliverList.list(
                children: [
                  // Personal details card
                  ParticipantCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParticipantSectionHeader(
                          title: 'Personal Details',
                          subtitle:
                              _isEditing
                                  ? 'Update your information below.'
                                  : 'Your registered account details.',
                        ),

                        // Full name
                        _isEditing
                            ? _buildEditField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline_rounded,
                              validator:
                                  (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Please enter your name'
                                          : null,
                            )
                            : _buildReadRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Full Name',
                              value:
                                  _nameController.text.isEmpty
                                      ? '—'
                                      : _nameController.text,
                            ),

                        const SizedBox(height: 14),

                        // Email — always read-only
                        _buildReadRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _email ?? '—',
                        ),

                        const SizedBox(height: 14),

                        // Phone
                        _isEditing
                            ? _buildEditField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator:
                                  (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Please enter your phone number'
                                          : null,
                            )
                            : _buildReadRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value:
                                  _phoneController.text.isEmpty
                                      ? '—'
                                      : _phoneController.text,
                            ),

                        // Save button — edit mode only
                        if (_isEditing) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ParticipantPalette.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child:
                                  _isSaving
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                      : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Account card
                  ParticipantCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ParticipantSectionHeader(
                          title: 'Account',
                          subtitle: 'Your role and session information.',
                        ),
                        _buildReadRow(
                          icon: Icons.shield_outlined,
                          label: 'Role',
                          value: _roleLabel,
                          valueColor: _roleColor,
                        ),
                      ],
                    ),
                  ),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ParticipantPalette.danger,
                        side: const BorderSide(
                          color: ParticipantPalette.danger,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const _PersakaPoweredByCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ParticipantPalette.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: ParticipantPalette.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: ParticipantPalette.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? ParticipantPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        color: ParticipantPalette.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ParticipantPalette.textSecondary,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: ParticipantPalette.primary, size: 20),
        filled: true,
        fillColor: ParticipantPalette.primary.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ParticipantPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ParticipantPalette.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ParticipantPalette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ParticipantPalette.danger,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _PersakaPoweredByCard extends StatelessWidget {
  const _PersakaPoweredByCard();

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Powered By',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ParticipantPalette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: ParticipantPalette.secondary.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: ParticipantPalette.secondary.withOpacity(0.18),
              ),
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  color: ParticipantPalette.secondary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'PERSATUAN MAHASISWA SAINS KOMPUTER',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ParticipantPalette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'UNIVERSITI TEKNOLOGI MALAYSIA (PERSAKA)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ParticipantPalette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
