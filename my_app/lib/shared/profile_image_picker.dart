import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_setup_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({super.key});

  Future<void> _showImageSourceDialog(BuildContext context) async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).selectProfilePhoto,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      context,
                      icon: Icons.photo_library,
                      label: AppLocalizations.of(context).gallery,
                      onTap: () async {
                        Navigator.of(context).pop();
                        try {
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 800,
                            maxHeight: 800,
                            imageQuality: 90,
                          );
                          if (image != null && context.mounted) {
                            context.read<ProfileSetupProvider>().setProfileImageUrl(image.path);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                            );
                          }
                        }
                      },
                    ),
                    _buildSourceOption(
                      context,
                      icon: Icons.camera_alt,
                      label: AppLocalizations.of(context).camera,
                      onTap: () async {
                        Navigator.of(context).pop();
                        try {
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 800,
                            maxHeight: 800,
                            imageQuality: 90,
                          );
                          if (image != null && context.mounted) {
                            context.read<ProfileSetupProvider>().setProfileImageUrl(image.path);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, child) {
        final profileImageUrl = provider.profileImageUrl;
        final hasImage = profileImageUrl != null && profileImageUrl.isNotEmpty;
        
        return Center(
          child: GestureDetector(
            onTap: () => _showImageSourceDialog(context),
            child: Stack(
              children: [
                // Main circle container
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                    color: hasImage 
                        ? Colors.transparent 
                        : (isDark ? Colors.grey[800] : Colors.grey[100]),
                  ),
                  child: hasImage
                      ? ClipOval(
                          child: Image.file(
                            File(profileImageUrl),
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultContent(context, theme, isDark);
                            },
                          ),
                        )
                      : _buildDefaultContent(context, theme, isDark),
                ),
                // Plus icon - positioned at bottom right
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultContent(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).profile,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.grey[300] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
