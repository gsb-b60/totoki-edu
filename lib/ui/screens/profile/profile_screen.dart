import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/features/user/user_notifier.dart';
import 'package:totoki_extract/theme/app_theme.dart';

final _emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _didPrefill = false;
  bool _dirty = false;
  Timer? _saveDebounce;
  UserNotifier? _notifierRef;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifierRef = context.read<UserNotifier>();
    final user = _notifierRef?.user;
    if (!_didPrefill && user != null) {
      _didPrefill = true;
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    if (_dirty && _isValid) {
      _notifierRef?.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
    }
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar(UserNotifier notifier) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _sheetOption(
              icon: Icons.photo_camera_outlined,
              label: 'Take Photo',
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            _sheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final path = await notifier.takePictureAndSaveAvatar(source: source);
    if (path == null) return;

    await notifier.updateAvatar(path);
    if (mounted) _showMessage('Avatar updated');
  }

  void _scheduleSave() {
    _dirty = true;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), () => _save());
  }

  String? get _nameError {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;
    if (name.length <= 3) return 'Name must be at least 4 characters';
    return null;
  }

  String? get _emailError {
    final email = _emailController.text.trim();
    if (email.isEmpty) return null;
    if (!email.contains('@')) return 'Email must contain @';
    if (!_emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? get _phoneError {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return null;
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  bool get _isValid =>
      _nameError == null && _emailError == null && _phoneError == null;

  Future<void> _save() async {
    final notifier = _notifierRef;
    if (notifier == null) return;
    if (!_isValid) {
      if (mounted) {
        setState(() {});
        _showMessage('Invalid input \u2014 not saved', isError: true);
      }
      return;
    }
    _dirty = false;
    await notifier.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );
    if (mounted) {
      setState(() {});
      _showMessage('Changes saved');
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppTheme.redPrimary : AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<UserNotifier>();
    final user = notifier.user;

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryTeal),
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildAvatar(notifier),
                      const SizedBox(height: 32),
                      _buildField(
                        controller: _nameController,
                        icon: Icons.person_outline,
                        label: 'Name',
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _scheduleSave(),
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        errorText: _nameError,
                      ),
                      _buildField(
                        controller: _emailController,
                        icon: Icons.mail_outline,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _scheduleSave(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9@._\-+]'),
                          ),
                        ],
                        errorText: _emailError,
                      ),
                      _buildField(
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => _scheduleSave(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        errorText: _phoneError,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar(UserNotifier notifier) {
    final url = notifier.user?.avatarUrl;
    final hasImage = url != null && url.isNotEmpty && File(url).existsSync();

    return GestureDetector(
      onTap: () => _changeAvatar(notifier),
      child: CircleAvatar(
        radius: 125,
        backgroundColor: AppTheme.darkSurface,
        backgroundImage: hasImage ? FileImage(File(url)) : null,
        child: hasImage
            ? null
            : const Icon(
                Icons.person_outline,
                size: 44,
                color: AppTheme.lightText,
              ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.greenPrimary, size: 20),
          errorText: errorText,
          errorStyle: const TextStyle(color: AppTheme.redPrimary, fontSize: 12),
          filled: true,
          fillColor: AppTheme.darkSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.redPrimary, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.redPrimary, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.greenPrimary),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
