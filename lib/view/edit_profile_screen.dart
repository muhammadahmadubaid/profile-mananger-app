import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profile_manager_app/providers/auth_provider.dart';
import 'package:profile_manager_app/providers/profile_provider.dart';
import 'package:profile_manager_app/utils/file_helper.dart';
import 'package:profile_manager_app/utils/validators.dart';
import 'package:profile_manager_app/view/widgets/custom_text_field.dart';
import 'package:profile_manager_app/view/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();

  File? _selectedProfileImage;
  File? _selectedDocument;
  String? _documentName;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadExistingProfile() {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final profile = profileProvider.profile;
    
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _ageController.text = profile.age.toString();
      _documentName = profile.documentName;
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        // Update controllers if profile changes
        if (profileProvider.profile != null && !_isEditing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadExistingProfile();
          });
        }

        return LoadingOverlay(
          isLoading: profileProvider.isLoading,
          loadingText: profileProvider.uploadProgress > 0 
              ? 'Uploading... ${(profileProvider.uploadProgress * 100).toInt()}%'
              : 'Saving profile...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileImageSection(context, profileProvider),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(context),
                  const SizedBox(height: 24),
                  _buildDocumentSection(context, profileProvider),
                  const SizedBox(height: 32),
                  _buildSaveButton(context, authProvider, profileProvider),
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    _buildCancelButton(context),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImageSection(BuildContext context, ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Picture',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => _selectProfileImage(context),
            child: Stack(
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
                    child: _buildProfileImageContent(context, profileProvider),
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
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => _selectProfileImage(context),
            child: Text(
              _selectedProfileImage != null || profileProvider.profile?.profileImageUrl != null
                  ? 'Change Picture'
                  : 'Add Picture',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageContent(BuildContext context, ProfileProvider profileProvider) {
    if (_selectedProfileImage != null) {
      return Image.file(
        _selectedProfileImage!,
        fit: BoxFit.cover,
      );
    } else if (profileProvider.profile?.profileImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: profileProvider.profile!.profileImageUrl!,
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
      );
    } else {
      return Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.add_a_photo,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          prefixIcon: Icons.person_outline,
          validator: Validators.validateName,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ageController,
          label: 'Age',
          prefixIcon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
          validator: Validators.validateAge,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildDocumentSection(BuildContext context, ProfileProvider profileProvider) {
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedDocument != null || profileProvider.profile?.documentUrl != null) ...[
                  _buildDocumentPreview(context, profileProvider),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDocument(context),
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      _selectedDocument != null || profileProvider.profile?.documentUrl != null
                          ? 'Change Document'
                          : 'Upload Document',
                          style: GoogleFonts.poppins(color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Supported formats: PDF, JPG, PNG (Max 5MB)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPreview(BuildContext context, ProfileProvider profileProvider) {
    String documentName = _documentName ?? 'Document';
    if (_selectedDocument != null) {
      documentName = _selectedDocument!.path.split('/').last;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getDocumentIcon(documentName),
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedDocument != null ? 'Ready to upload' : 'Currently uploaded',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeDocument(context, profileProvider),
            icon: const Icon(Icons.close),
            color: Colors.red,
            tooltip: 'Remove Document',
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AuthProvider authProvider, ProfileProvider profileProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: profileProvider.isLoading ? null : () => _handleSave(context, authProvider, profileProvider),
        icon: const Icon(Icons.save),
        label: Text(_isEditing ? 'Update Profile' : 'Create Profile'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handleCancel,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: const Text('Cancel'),
      ),
    );
  }

  void _selectProfileImage(BuildContext context) {
    FileHelper.showImagePickerOptions(context, (File? image) {
      if (image != null) {
        setState(() {
          _selectedProfileImage = image;
        });
      }
    });
  }

  Future<void> _selectDocument(BuildContext context) async {
    final document = await FileHelper.pickDocument(context);
    if (document != null) {
      setState(() {
        _selectedDocument = document;
        _documentName = document.path.split('/').last;
      });
    }
  }

  void _removeDocument(BuildContext context, ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Document'),
        content: Text('Are you sure you want to remove this document?',style: GoogleFonts.poppins(color: Colors.black87),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87),),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDocument = null;
                _documentName = null;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, AuthProvider authProvider, ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await profileProvider.saveProfile(
        userId: authProvider.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        age: int.parse(_ageController.text),
        profileImage: _selectedProfileImage,
        document: _selectedDocument,
        documentName: _documentName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Profile updated successfully!' : 'Profile created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear selected files after successful save
        setState(() {
          _selectedProfileImage = null;
          _selectedDocument = null;
          _isEditing = true;
        });
      }
    } catch (e) {
      if (mounted) {
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

  void _handleCancel() {
    setState(() {
      _selectedProfileImage = null;
      _selectedDocument = null;
      _loadExistingProfile();
    });
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
}