import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/buttons.dart';
import '../providers/group_provider.dart';
import '../../domain/entities/group.dart';

/// Écran pour modifier un groupe
class EditGroupScreen extends StatefulWidget {
  final Group group;

  const EditGroupScreen({super.key, required this.group});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  File? _imageFile;
  String? _photoUrl;
  bool _isPrivate = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(
      text: widget.group.description,
    );
    _photoUrl = widget.group.photoUrl;
    _isPrivate = widget.group.settings.isPrivate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Choisir une image depuis la galerie
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection: $e')),
      );
    }
  }

  /// Uploader l'image sur Firebase Storage
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _photoUrl;

    setState(() => _isUploading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('groups')
          .child(
            '${widget.group.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

      await ref.putFile(_imageFile!);
      final url = await ref.getDownloadURL();

      setState(() => _isUploading = false);
      return url;
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur d\'upload: $e')));
      return _photoUrl;
    }
  }

  /// Sauvegarder les modifications
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    // Upload de l'image si nécessaire
    final photoUrl = await _uploadImage();

    final groupProvider = context.read<GroupProvider>();
    final updatedGroup = widget.group.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      photoUrl: photoUrl,
      settings: widget.group.settings.copyWith(isPrivate: _isPrivate),
    );

    final success = await groupProvider.updateGroup(updatedGroup);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Groupe modifié avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le groupe'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _saveChanges,
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo du groupe
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              )
                            : _photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageFile == null && _photoUrl == null
                          ? Icon(
                              Icons.groups,
                              size: 48,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Touchez pour changer la photo',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Nom du groupe
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du groupe',
                hintText: 'Ex: Amis de promo',
                prefixIcon: Icon(Icons.groups),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Décrivez votre groupe...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16),

            // Groupe privé
            SwitchListTile(
              title: const Text('Groupe privé'),
              subtitle: const Text('Seuls les membres peuvent voir le groupe'),
              value: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Indicateur de chargement
            if (_isUploading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Upload de l\'image en cours...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
