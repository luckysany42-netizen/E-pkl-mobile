import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nimController;
  late final TextEditingController _schoolController;
  File? _photo;
  bool _removePhoto = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _nimController = TextEditingController(text: user?.nimNis ?? '');
    _schoolController = TextEditingController(text: user?.asalInstansi ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nimController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _photo = File(picked.path);
      _removePhoto = false;
    });
  }

  void _submit() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated ||
        !_formKey.currentState!.validate()) {
      return;
    }
    context.read<ProfileBloc>().add(ProfileUpdateRequested(
          currentUser: authState.user,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          nimNis: _nimController.text.trim(),
          asalInstansi: _schoolController.text.trim(),
          photo: _photo,
          removePhoto: _removePhoto,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.user;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.submitSuccess && state.updatedUser != null) {
          context.read<AuthBloc>().add(const AuthCheckRequested());
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profil')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundImage: _photo != null
                        ? FileImage(_photo!)
                        : user.photoUrl == null
                            ? null
                            : NetworkImage(user.photoUrl!),
                    child: _photo == null && user.photoUrl == null
                        ? const Icon(Icons.person, size: 52)
                        : null,
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _pickPhoto,
                  child: const Text('Ganti Foto'),
                ),
              ),
              if (user.photoUrl != null)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _photo = null;
                      _removePhoto = true;
                    }),
                    child: const Text('Hapus Foto'),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user.email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'No Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nomor telepon wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(
                  labelText: 'NIS',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'NIS wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(
                  labelText: 'Asal Sekolah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Asal sekolah wajib diisi'
                    : null,
              ),
              const SizedBox(height: 24),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) => SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : _submit,
                    child: state.isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Simpan Perubahan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
