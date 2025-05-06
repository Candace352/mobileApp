// import 'package:flutter/material.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   void _loadUserData() {
//     // TODO: Load actual user data from your backend
//     _nameController.text = 'John Doe';
//     _emailController.text = 'john.doe@example.com';
//     _bioController.text = 'Mobile Developer';
//   }

//   void _saveProfile() {
//     // TODO: Save profile data to your backend
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Profile updated successfully!')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveProfile,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 // TODO: Implement image picking when you add the package
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Image picker will be implemented')),
//                 );
//               },
//               child: const CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.grey,
//                 child: Icon(Icons.person, size: 50, color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildProfileTextField(
//               controller: _nameController,
//               label: 'Full Name',
//               icon: Icons.person,
//             ),
//             _buildProfileTextField(
//               controller: _emailController,
//               label: 'Email',
//               icon: Icons.email,
//               enabled: false,
//             ),
//             _buildProfileTextField(
//               controller: _bioController,
//               label: 'Bio',
//               icon: Icons.info,
//               maxLines: 3,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Implement logout
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text('Logout'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool enabled = true,
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextField(
//         controller: controller,
//         enabled: enabled,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }
// }
