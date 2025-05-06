import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_jobs/pages/login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_jobs/pages/home.dart';
import 'package:intl/intl.dart';

enum ProfileState { loading, savingImage, savingData, loaded, editing }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  User? _currentUser;
  String? _profileImageUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  ProfileState _profileState = ProfileState.loading;
  final ImagePicker _picker = ImagePicker();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    });
  }

  Future<void> _checkAuthState() async {
    setState(() => _profileState = ProfileState.loading);
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JobSeekerHomePage()),
        );
      }
      return;
    }

    await _loadUserData();
    if (mounted) {
      setState(() => _profileState = ProfileState.loaded);
    }
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      _nameController.text = _currentUser!.displayName ?? '';
      _emailController.text = _currentUser!.email ?? '';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _phoneController.text = data['phone'] ?? '';
          _locationController.text = data['location'] ?? '';
          _birthdayController.text = data['birthday'] ?? '';
          _positionController.text = data['position'] ?? '';
          _experienceController.text = data['experience'] ?? '';
          _educationController.text = data['education'] ?? '';
          _profileImageUrl =
              data['profilePictureUrl'] ?? _currentUser!.photoURL;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      PermissionStatus status;
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        status = androidInfo.version.sdkInt >= 33
            ? await Permission.photos.request()
            : await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
      }

      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission denied')),
          );
        }
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _profileState = ProfileState.savingImage;
        });

        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${_currentUser!.uid}.jpg');

        final UploadTask uploadTask = storageRef.putFile(_profileImage!);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        await _currentUser!.updatePhotoURL(downloadUrl);
        await _currentUser!.reload();
        _currentUser = FirebaseAuth.instance.currentUser;

        // try {
        //   await _currentUser!.updatePhotoURL(downloadUrl);
        //   await _currentUser!.reload();
        //   _currentUser = FirebaseAuth.instance.currentUser;
        // } catch (e) {
        //   debugPrint('Error updating auth photoURL: $e');
        // }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set({
          'profilePictureUrl': downloadUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating picture: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _profileState = ProfileState.loaded);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    try {
      setState(() {
        _profileState = ProfileState.savingData;
        _isEditing = false;
      });

      await _currentUser!.updateDisplayName(_nameController.text);
      await _currentUser!.reload();
      _currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
        'displayName': _nameController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'birthday': _birthdayController.text,
        'position': _positionController.text,
        'experience': _experienceController.text,
        'education': _educationController.text,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _profileState = ProfileState.loaded);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _loadUserData();
      }
    });
  }

  double get _completionPercentage {
    int filledFields = 0;
    if (_nameController.text.isNotEmpty) filledFields++;
    if (_emailController.text.isNotEmpty) filledFields++;
    if (_phoneController.text.isNotEmpty) filledFields++;
    if (_locationController.text.isNotEmpty) filledFields++;
    if (_birthdayController.text.isNotEmpty) filledFields++;
    if (_positionController.text.isNotEmpty) filledFields++;
    if (_experienceController.text.isNotEmpty) filledFields++;
    if (_educationController.text.isNotEmpty) filledFields++;
    return filledFields / 8;
  }

  @override
  Widget build(BuildContext context) {
    if (_profileState == ProfileState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed:
                  _profileState != ProfileState.loaded ? null : _saveProfile,
              tooltip: 'Save Profile',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEditMode,
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _completionPercentage,
                backgroundColor: Colors.grey[200],
                minHeight: 4,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : _profileImageUrl != null
                              ? CachedNetworkImageProvider(_profileImageUrl!)
                              : null,
                      child: _profileImage == null && _profileImageUrl == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                    if (_isEditing)
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_emailController, 'Email', enabled: false),
              _buildTextField(_phoneController, 'Phone'),
              _buildTextField(_locationController, 'Location'),
              GestureDetector(
                onTap: _isEditing ? _selectDate : null,
                child: AbsorbPointer(
                  child: _buildTextField(_birthdayController, 'Birthday'),
                ),
              ),
              _buildTextField(_positionController, 'Position'),
              _buildTextField(_experienceController, 'Experience'),
              _buildTextField(_educationController, 'Education'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        enabled: _isEditing && enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
