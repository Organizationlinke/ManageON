import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:manageon/constants.dart';
import 'package:manageon/global.dart';
import 'package:manageon/taskes/models/user_model.dart';
import 'package:manageon/taskes/providers/app_state_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String? _imageUrl;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    // Get user from provider
    final user = ref.read(loggedInUserProvider);
    if (user == null) {
      // Handle case where user is not logged in
      Navigator.of(context).pop();
      return;
    }

    _currentUser = user;
    _nameController.text = _currentUser!.fullName;
    _imageUrl = _currentUser!.photoUrl;

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      try {
        final imageResponse = await http.get(Uri.parse(_imageUrl!));
        if (imageResponse.statusCode == 200) {
          if (!mounted) return;
          setState(() {
            _imageBytes = imageResponse.bodyBytes;
          });
        }
      } catch (e) {
        // Ignore image loading errors
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      showSnackBar(context, 'الاسم لا يمكن أن يكون فارغاً', isError: true);
      return;
    }
    setState(() => _isLoading = true);

    try {
      String? newImageUrl = _imageUrl;

if (_imageBytes != null) {
  final bucket = supabase.storage.from('userphoto');

  // احذف الصورة القديمة
  final oldUrl = _currentUser!.photoUrl;
  if (oldUrl != null && oldUrl.isNotEmpty && !oldUrl.endsWith('default_avatar.png')) {
    try {
      final oldPath = oldUrl.split('/').last;
      await bucket.remove([oldPath]);
    } catch (_) {}
  }

  // ارفع الصورة الجديدة
  final fileName = const Uuid().v4();
  final filePath = "$fileName.png";

  await bucket.uploadBinary(
    filePath,
    _imageBytes!,
    fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
  );

  newImageUrl = bucket.getPublicUrl(filePath);
}

      // String? newImageUrl = _imageUrl;
      // if (_imageBytes != null && _imageUrl != null && !Uri.parse(_imageUrl!).hasAuthority) {
      //   final bucket = supabase.storage.from('userphoto');
      //   final oldUrl = _currentUser!.photoUrl;
        
      //   if (oldUrl != null && oldUrl.isNotEmpty && !oldUrl.endsWith('default_avatar.png')) {
      //     try {
      //       final oldPath = oldUrl.split('/').last;
      //       await bucket.remove([oldPath]);
      //     } catch (e) {
      //       // Ignore error if old file doesn't exist
      //     }
      //   }
        
      //   final randomFileName = const Uuid().v4();
      //   final filePath = '$randomFileName.png';
      //   await bucket.uploadBinary(filePath, _imageBytes!,
      //       fileOptions: const FileOptions(cacheControl: '3600', upsert: false));
      //   newImageUrl = bucket.getPublicUrl(filePath);
      // }
      
      final Map<String, dynamic> updates = {
        'full_name': _nameController.text,
        'photo_url': newImageUrl,
      };

      if (_passController.text.isNotEmpty) {
        updates['pass'] = _passController.text;
      }

      final response = await supabase
          .from('usersin')
          .update(updates)
          .eq('id', _currentUser!.id)
          .select('*, departments:department(*)')
          .single();
      
      // Update the user state in the provider
      ref.read(loggedInUserProvider.notifier).state = AppUser.fromJson(response);

      if(mounted) showSnackBar(context, 'تم تحديث البيانات بنجاح');

    } catch (e) {
      if(mounted) showSnackBar(context, 'فشل تحديث البيانات: $e', isError: true);
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بيانات المستخدم')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (_imageUrl != null && _imageUrl!.isNotEmpty
                              ? NetworkImage(_imageUrl!) as ImageProvider
                              : const AssetImage('assets/default_avatar.png')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'الاسم كامل'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    
                    controller: _passController,
                    decoration: const InputDecoration(labelText: 'كلمة السر الجديدة (اتركه فارغاً لعدم التغيير)'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorbar,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _updateProfile,
                    child: const Text('تحديث-البيانات'),
                  ),
                ],
              ),
            ),
    );
  }
}