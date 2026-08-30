import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).updateProfile(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated locally.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Reset fields on cancel
                  _nameController.text = user?.fullName ?? '';
                  _phoneController.text = user?.phone ?? '';
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar & Name Card
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryRed, AppTheme.accentOrange],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRed.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (user?.fullName.isNotEmpty == true)
                              ? user!.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Roadsos+ User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Local Offline Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phonelink_setup_rounded,
                          color: AppTheme.successGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'On-Device Local Database Active',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successGreen,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '100% Offline & Private Security Mode',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form for Editable and Read-Only details
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal Details', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Full Name (Editable)
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'Name must be at least 3 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Number (Editable)
                    TextFormField(
                      controller: _phoneController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || !RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                          return 'Must be a 10-digit phone number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Address (Read-Only)
                    TextFormField(
                      initialValue: user?.email ?? '',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email Address (Read-Only)',
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User ID (Read-Only)
                    TextFormField(
                      initialValue: user?.id ?? '',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'User Local ID (Read-Only)',
                        prefixIcon: Icon(Icons.fingerprint_rounded, color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          child: const Text('Save Changes'),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _handleLogout,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryRed, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, color: AppTheme.primaryRed),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
