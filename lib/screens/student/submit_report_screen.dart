import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_style.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class SubmitReportScreen extends StatefulWidget {
  final String? initialCategory;

  /// When set, the screen edits this report instead of creating a new one.
  final Incident? existing;

  const SubmitReportScreen({super.key, this.initialCategory, this.existing});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  String? _category;
  bool _categoryError = false;
  bool _anonymous = false;
  File? _image;
  bool _keepExistingPhoto = true;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _category = e?.category ?? widget.initialCategory;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, imageQuality: 70, maxWidth: 1280);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _chooseSource() {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(sheetCtx);
              _pick(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(sheetCtx);
              _pick(ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _categoryError = _category == null);
    if (!formOk || _category == null) return;

    final provider = context.read<IncidentProvider>();
    final bool ok;

    if (_editing) {
      final existing = widget.existing!;
      ok = await provider.updateDetails(
        id: existing.id,
        title: _title.text,
        description: _description.text,
        category: _category!,
        location: _location.text,
        newImage: _image,
        removePhoto:
            existing.photoUrl != null && !_keepExistingPhoto && _image == null,
      );
    } else {
      final user = context.read<AuthProvider>().appUser;
      if (user == null) return;
      ok = await provider.submit(
        user: user,
        title: _title.text,
        description: _description.text,
        category: _category!,
        location: _location.text,
        anonymous: _anonymous,
        image: _image,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? (_editing ? 'Report updated' : 'Report submitted')
            : provider.error ?? 'Something went wrong')));
    if (ok) Navigator.pop(context);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
      );

  Widget _categoryTile(String c) {
    final selected = _category == c;
    return GestureDetector(
      onTap: () => setState(() {
        _category = c;
        _categoryError = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(categoryIcon(c),
                color: selected ? Colors.white : AppColors.primary),
            const SizedBox(height: 6),
            Text(c,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.ink)),
          ],
        ),
      ),
    );
  }

  Widget _removable(Widget image, VoidCallback onRemove) => Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: image),
          IconButton(
            style: IconButton.styleFrom(
                backgroundColor: Colors.black54, foregroundColor: Colors.white),
            icon: const Icon(Icons.close),
            onPressed: onRemove,
          ),
        ],
      );

  Widget _photoSection() {
    if (!AppConstants.photoUploadEnabled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(children: [
          Icon(Icons.image_not_supported_outlined, color: AppColors.muted),
          SizedBox(width: 12),
          Expanded(
              child: Text('Photo upload is temporarily unavailable.',
                  style: TextStyle(color: AppColors.muted))),
        ]),
      );
    }
    if (_image != null) {
      return _removable(
        Image.file(_image!,
            height: 180, width: double.infinity, fit: BoxFit.cover),
        () => setState(() => _image = null),
      );
    }
    final existingUrl = widget.existing?.photoUrl;
    if (existingUrl != null && _keepExistingPhoto) {
      return _removable(
        Image.network(existingUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
                height: 120, child: Center(child: Icon(Icons.broken_image)))),
        () => setState(() => _keepExistingPhoto = false),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _chooseSource,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 30, color: AppColors.primary),
            SizedBox(height: 6),
            Text('Tap to add photos', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<IncidentProvider>().submitting;
    return Scaffold(
      appBar: AppBar(
          title: Text(_editing ? 'Edit Report' : 'Report an Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Select a category'),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.35,
                children: AppConstants.categories.map(_categoryTile).toList(),
              ),
              if (_categoryError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text('Please select a category',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12)),
                ),
              _label('Title'),
              TextFormField(
                controller: _title,
                decoration:
                    const InputDecoration(hintText: 'Briefly describe the issue'),
                validator: (v) => Validators.required(v, 'Title'),
              ),
              _label('Description'),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText:
                        'Provide more details: what happened, when, impact, etc.'),
                validator: (v) {
                  if (v == null || v.trim().length < 10) {
                    return 'Describe the issue (at least 10 characters)';
                  }
                  return null;
                },
              ),
              _label('Location'),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                    hintText: 'e.g. Block B, Room 204',
                    prefixIcon: Icon(Icons.place_outlined)),
                validator: (v) => Validators.required(v, 'Location'),
              ),
              _label('Add a photo (optional)'),
              _photoSection(),
              if (!_editing) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    title: const Text('Report anonymously'),
                    subtitle:
                        const Text('Your name will be hidden from other users'),
                    value: _anonymous,
                    onChanged: (v) => setState(() => _anonymous = v),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: submitting ? null : _submit,
                  child: submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_editing ? 'Save changes' : 'Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
