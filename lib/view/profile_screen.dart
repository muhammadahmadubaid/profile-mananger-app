import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profile_manager_app/providers/auth_provider.dart';
import 'package:profile_manager_app/providers/profile_provider.dart';
import 'package:profile_manager_app/view/widgets/empty_state.dart';
import 'package:profile_manager_app/view/widgets/loading_overlay.dart';
import 'package:profile_manager_app/view/widgets/profile_info_card.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart' ;
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        return LoadingOverlay(
          isLoading: profileProvider.isLoading,
          child: RefreshIndicator(
            onRefresh: () async {
              if (authProvider.user != null) {
                await profileProvider.loadProfile(authProvider.user!.uid);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (profileProvider.profile != null) ...[
                    _buildProfileHeader(context, profileProvider.profile!),
                    const SizedBox(height: 24),
                    _buildProfileInfo(context, profileProvider.profile!),
                    const SizedBox(height: 24),
                    _buildDocumentSection(context, profileProvider.profile!),
                    const SizedBox(height: 24),
                    _buildActionsSection(context, authProvider, profileProvider),
                  ] else ...[
                    EmptyState(
                      icon: Icons.person_outline,
                      title: 'No Profile Found',
                      subtitle: 'Create your profile to get started',
                      actionText: 'Create Profile',
                      onActionPressed: () {
                        // This would navigate to edit tab in the parent widget
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navigate to Edit tab to create your profile'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: profile.profileImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: profile.profileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : Container(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Active User',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ProfileInfoCard(
          icon: Icons.person_outline,
          label: 'Full Name',
          value: profile.name,
        ),
        const SizedBox(height: 12),
        ProfileInfoCard(
          icon: Icons.email_outlined,
          label: 'Email Address',
          value: profile.email,
        ),
        const SizedBox(height: 12),
        ProfileInfoCard(
          icon: Icons.cake_outlined,
          label: 'Age',
          value: '${profile.age} years old',
        ),
        const SizedBox(height: 12),
        ProfileInfoCard(
          icon: Icons.access_time,
          label: 'Member Since',
          value: _formatDate(profile.createdAt),
        ),
        const SizedBox(height: 12),
        ProfileInfoCard(
          icon: Icons.update,
          label: 'Last Updated',
          value: _formatDate(profile.updatedAt),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(BuildContext context, profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (profile.documentUrl != null) ...[
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDocumentIcon(profile.documentName ?? ''),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: Text(
                profile.documentName ?? 'Document',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Tap to view or download'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
              onTap: () => _openDocument(context, profile.documentUrl!),
            ),
          ),
        ] else ...[
          const EmptyState(
            icon: Icons.description_outlined,
            title: 'No Documents',
            subtitle: 'Upload documents in the edit section',
          ),
        ],
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthProvider authProvider, ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Edit Profile'),
                subtitle: const Text('Update your profile information'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigate to Edit tab to update your profile'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
                title: const Text('Delete Profile'),
                subtitle: const Text('Permanently delete your profile'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDeleteConfirmation(context, authProvider, profileProvider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getDocumentIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _openDocument(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open document'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening document'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, AuthProvider authProvider, ProfileProvider profileProvider) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Profile',  style: GoogleFonts.poppins(color: Colors.black87,),),
        content: Text(
          'Are you sure you want to delete your profile? This action cannot be undone and will remove all your data including uploaded images and documents.',
        style: GoogleFonts.poppins(color: Colors.black87,),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await profileProvider.deleteProfile(authProvider.user!.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

