// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobile_jobs/models/job.dart';
// import 'package:mobile_jobs/pages/job_details.dart';
// import 'package:mobile_jobs/pages/documents_page.dart';
// import 'package:mobile_jobs/pages/profile.dart';
// import 'package:mobile_jobs/pages/applied_jobs_page.dart';
// import 'package:mobile_jobs/pages/drafts_page.dart';
// import 'package:mobile_jobs/services/local_storage_service.dart';

// class JobSeekerHomePage extends StatefulWidget {
//   const JobSeekerHomePage({super.key});

//   @override
//   State<JobSeekerHomePage> createState() => _JobSeekerHomePageState();
// }

// class _JobSeekerHomePageState extends State<JobSeekerHomePage> {
//   static const _baseUrl = 'https://api-qkosqkekfq-uc.a.run.app';
//   final List<Job> _jobs = [];
//   List<Job> _appliedJobs = [];
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';
//   Timer? _refreshTimer;

//   // Text styles
//   final TextStyle _titleStyle = const TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.bold,
//     color: Colors.blueGrey,
//   );

//   final TextStyle _subtitleStyle = TextStyle(
//     fontSize: 16,
//     color: Colors.grey[600],
//   );

//   final TextStyle _errorStyle = const TextStyle(
//     fontSize: 16,
//     color: Colors.redAccent,
//   );

//   final TextStyle _emptyTitleStyle = const TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.w500,
//     color: Colors.blueGrey,
//   );

//   final TextStyle _emptySubtitleStyle = TextStyle(
//     fontSize: 14,
//     color: Colors.grey[600],
//   );

//   final TextStyle _drawerHeaderStyle = const TextStyle(
//     color: Colors.white,
//     fontSize: 20,
//     fontWeight: FontWeight.bold,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   // Future<void> _initializeData() async {
//   //   await _loadAppliedJobs();
//   //   await _fetchJobs();
//   //   _startAutoRefresh();
//   // }
//   Future<void> _initializeData() async {
//     // Run both operations in parallel
//     await Future.wait([
//       _loadAppliedJobs(),
//       _fetchJobs(),
//     ]);
//     _startAutoRefresh();
//   }

//   void _startAutoRefresh() {
//     _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (!_isLoading) _fetchJobs();
//     });
//   }

//   // Future<void> _loadAppliedJobs() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final appliedJobsJson = prefs.getStringList('appliedJobs') ?? [];
//   //   setState(() {
//   //     _appliedJobs.addAll(
//   //         appliedJobsJson.map((json) => Job.fromJson(jsonDecode(json))));
//   //   });
//   // }
//   Future<void> _loadAppliedJobs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final appliedJobsJson = prefs.getStringList('appliedJobs') ?? [];

//       // Single setState call
//       if (mounted) {
//         setState(() {
//           _appliedJobs = appliedJobsJson
//               .map((json) => Job.fromJson(jsonDecode(json)))
//               .toList();
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading applied jobs: $e');
//     }
//   }

//   Future<void> _logout(BuildContext context) async {
//     try {
//       // Show loading indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );

//       // Clear all stored data
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.clear();

//       // Close any open dialogs
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       // Navigate to login screen with clean stack
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         '/signin', // or '/login' depending on your route name
//         (route) => false, // This removes all routes
//       );
//     } catch (e) {
//       // Handle any errors
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context); // Close loading dialog
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Logout failed: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _saveAppliedJob(Job job) async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() => _appliedJobs.add(job));
//     await prefs.setStringList(
//       'appliedJobs',
//       _appliedJobs.map((job) => jsonEncode(job.toJson())).toList(),
//     );
//   }

//   Future<void> _fetchJobs() async {
//     if (!mounted) return;

//     // Try loading cached jobs first
//     final prefs = await SharedPreferences.getInstance();
//     final cachedJobs = prefs.getString('cached_jobs');
//     if (cachedJobs != null) {
//       setState(() {
//         _jobs.clear();
//         _jobs.addAll(
//             (jsonDecode(cachedJobs) as List).map((e) => Job.fromMap(e)));
//       });
//     }

//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _errorMessage = '';
//     });

//     try {
//       final response = await http
//           .get(Uri.parse('${_baseUrl}/jobs'))
//           .timeout(const Duration(seconds: 15)); // Increased timeout

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final responseBody = response.body;
//         await prefs.setString('cached_jobs', responseBody); // Cache new data
//         final List<dynamic> responseData = jsonDecode(responseBody);
//         setState(() {
//           _jobs.clear();
//           _jobs.addAll(responseData.map((e) => Job.fromMap(e)));
//           _isLoading = false;
//         });
//       } else {
//         throw _parseError(response);
//       }
//     } catch (e) {
//       _handleError(e);
//     }
//   }

//   String _parseError(http.Response response) {
//     return response.body.isNotEmpty
//         ? jsonDecode(response.body)['error'] ?? 'Failed to load jobs'
//         : 'Failed to load jobs (Status: ${response.statusCode})';
//   }

//   void _handleError(dynamic error) {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = false;
//       _hasError = true;
//       _errorMessage = error is http.ClientException
//           ? 'Network error: ${error.message}'
//           : error is TimeoutException
//               ? 'Request timed out. Please try again.'
//               : error.toString().replaceAll('Exception: ', '');
//     });
//   }

//   void _navigateToJobDetails(Job job) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => JobDetailsPage(
//           job: job,
//           isApplied: _appliedJobs.any((j) => j.id == job.id),
//           onApply: () => _applyForJob(job),
//         ),
//       ),
//     );
//   }

//   Future<void> _applyForJob(Job job) async {
//     try {
//       await _saveAppliedJob(job);
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Successfully applied for ${job.title}'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to apply: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     }
//   }
//   // Future<void> _applyForJob(Job job) async {
//   //   try {
//   //     await _saveAppliedJob(job);
//   //     if (!mounted) return;

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('Successfully applied for ${job.title}'),
//   //         backgroundColor: Colors.green,
//   //         behavior: SnackBarBehavior.floating,
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(10),
//   //         ),
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     if (!mounted) return;
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('Failed to apply: ${e.toString()}'),
//   //         backgroundColor: Colors.red,
//   //         behavior: SnackBarBehavior.floating,
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(10),
//   //         ),
//   //       ),
//   //     );
//   //   }
//   // }

//   Widget _buildJobCard(Job job) {
//     final isApplied = _appliedJobs.any((j) => j.id == job.id);

//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => _navigateToJobDetails(job),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildJobHeader(job, isApplied),
//               const SizedBox(height: 8),
//               Text(job.company, style: _subtitleStyle),
//               const SizedBox(height: 12),
//               Text(
//                 job.description,
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(color: Colors.grey[700]),
//               ),
//               const SizedBox(height: 12),
//               _buildJobTags(job),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildJobHeader(Job job, bool isApplied) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             job.title,
//             style: _titleStyle.copyWith(fontWeight: FontWeight.w600),
//           ),
//         ),
//         IconButton(
//           icon: FutureBuilder<bool>(
//             future: LocalStorageService.isFavorite(job.id),
//             builder: (context, snapshot) {
//               return Icon(
//                 snapshot.data == true ? Icons.favorite : Icons.favorite_border,
//                 color: Colors.red,
//               );
//             },
//           ),
//           onPressed: () async {
//             await LocalStorageService.toggleFavorite(job.id);
//             setState(() {});
//           },
//         ),
//         if (isApplied)
//           const Icon(Icons.check_circle, color: Colors.green, size: 24),
//       ],
//     );
//   }

//   Widget _buildJobTags(Job job) {
//     return Wrap(
//       spacing: 12,
//       runSpacing: 8,
//       children: [
//         if (job.location != null && job.location!.isNotEmpty)
//           _buildInfoChip(icon: Icons.location_on, text: job.location!),
//         if (job.salary != null && job.salary!.isNotEmpty)
//           _buildInfoChip(icon: Icons.attach_money, text: job.salary!),
//       ],
//     );
//   }

//   Widget _buildInfoChip({required IconData icon, required String text}) {
//     return Chip(
//       avatar: Icon(icon, size: 16, color: Colors.blueGrey),
//       label: Text(text, style: const TextStyle(fontSize: 12)),
//       visualDensity: VisualDensity.compact,
//       backgroundColor: Colors.grey[100],
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//     );
//   }

//   Widget _buildDrawer() {
//     return Drawer(
//       child: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               children: [
//                 DrawerHeader(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blue[700]!, Colors.blue[500]!],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.white,
//                         child: Icon(Icons.person, size: 40, color: Colors.blue),
//                       ),
//                       const SizedBox(height: 10),
//                       Text('Hello, Candidate', style: _drawerHeaderStyle),
//                     ],
//                   ),
//                 ),
//                 ListTile(
//                   title: const Text('Documents'),
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const DocumentsPage()),
//                   ),
//                 ),
//                 ListTile(
//                   title: const Text('Profile'),
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const ProfilePage()),
//                   ),
//                 ),
//                 ListTile(
//                   title: const Text('Applied Jobs'),
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const AppliedJobsPage(
//                               appliedJobs: [],
//                             )),
//                   ),
//                 ),
//                 ListTile(
//                   title: const Text('Drafts'),
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const DraftsPage()),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.exit_to_app),
//             title: const Text('Logout'),
//             onTap: () {
//               Navigator.pop(context); // Close the drawer
//               _logout(context);
//             },
//           ),
//           // ElevatedButton.icon(
//           //   onPressed: () => _logout(context),
//           //   icon: const Icon(Icons.exit_to_app),
//           //   label: const Text('Logout'),
//           //   style: ElevatedButton.styleFrom(
//           //     backgroundColor: Colors.red,
//           //     shape: RoundedRectangleBorder(
//           //       borderRadius: BorderRadius.circular(8),
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmpty() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text('No Jobs Available', style: _emptyTitleStyle),
//             const SizedBox(height: 8),
//             Text('We couldn’t find any jobs at the moment, try again later.',
//                 textAlign: TextAlign.center, style: _emptySubtitleStyle),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Job Seeker'),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue[800]!, Colors.blue[600]!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       drawer: _buildDrawer(),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue[50]!, Colors.white],
//           ),
//         ),
//         child: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                 ),
//               )
//             : _hasError
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.error_outline,
//                             size: 48, color: Colors.red),
//                         const SizedBox(height: 16),
//                         Text(
//                           _errorMessage,
//                           style: _errorStyle.copyWith(fontSize: 18),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: _fetchJobs,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 24, vertical: 12),
//                           ),
//                           child: const Text('Retry',
//                               style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                   )
//                 : _buildJobList(),
//       ),
//     );
//   }

//   Widget _buildDrawer() {
//     return Drawer(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.blue[800]!, Colors.blue[600]!],
//           ),
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   DrawerHeader(
//                     decoration: BoxDecoration(
//                       color: Colors.blue[700],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const CircleAvatar(
//                           radius: 30,
//                           backgroundColor: Colors.white,
//                           child:
//                               Icon(Icons.person, size: 40, color: Colors.blue),
//                         ),
//                         const SizedBox(height: 16),
//                         Text('Hello, Candidate',
//                             style: _drawerHeaderStyle.copyWith(fontSize: 22)),
//                       ],
//                     ),
//                   ),
//                   _buildDrawerItem(
//                     icon: Icons.description,
//                     title: 'Documents',
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const DocumentsPage()),
//                     ),
//                   ),
//                   _buildDrawerItem(
//                     icon: Icons.person,
//                     title: 'Profile',
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ProfilePage()),
//                     ),
//                   ),
//                   _buildDrawerItem(
//                     icon: Icons.work,
//                     title: 'Applied Jobs',
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) =>
//                               const AppliedJobsPage(appliedJobs: [])),
//                     ),
//                   ),
//                   _buildDrawerItem(
//                     icon: Icons.drafts,
//                     title: 'Drafts',
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const DraftsPage()),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _buildDrawerItem(
//               icon: Icons.logout,
//               title: 'Logout',
//               color: Colors.red[400],
//               onTap: () {
//                 Navigator.pop(context);
//                 _logout(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDrawerItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     Color? color,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: color ?? Colors.white70),
//       title: Text(title,
//           style: TextStyle(
//               color: color ?? Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w500)),
//       onTap: onTap,
//     );
//   }

//   Widget _buildJobCard(Job job) {
//     final isApplied = _appliedJobs.any((j) => j.id == job.id);

//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () => _navigateToJobDetails(job),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.white, Colors.grey[50]!],
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildJobHeader(job, isApplied),
//                 const SizedBox(height: 8),
//                 Text(job.company,
//                     style: _subtitleStyle.copyWith(
//                         color: Colors.blueGrey[700],
//                         fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 12),
//                 Text(
//                   job.description,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(color: Colors.grey[700], fontSize: 14),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildJobTags(job),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildJobHeader(Job job, bool isApplied) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             job.title,
//             style: _titleStyle.copyWith(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 20,
//                 color: Colors.blue[900]),
//           ),
//         ),
//         Row(
//           children: [
//             IconButton(
//               icon: FutureBuilder<bool>(
//                 future: LocalStorageService.isFavorite(job.id),
//                 builder: (context, snapshot) {
//                   return Icon(
//                     snapshot.data == true
//                         ? Icons.favorite
//                         : Icons.favorite_border,
//                     color: Colors.red[400],
//                   );
//                 },
//               ),
//               onPressed: () async {
//                 await LocalStorageService.toggleFavorite(job.id);
//                 setState(() {});
//               },
//             ),
//             if (isApplied)
//               const Icon(Icons.check_circle, color: Colors.green, size: 24),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildJobTags(Job job) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: [
//         if (job.location != null && job.location!.isNotEmpty)
//           _buildInfoChip(icon: Icons.location_on, text: job.location!),
//         if (job.salary != null && job.salary!.isNotEmpty)
//           _buildInfoChip(icon: Icons.attach_money, text: job.salary!),
//       ],
//     );
//   }

//   Widget _buildEmpty() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset('assets/images/no_jobs.png', height: 150),
//             const SizedBox(height: 24),
//             Text('No Jobs Available',
//                 style: _emptyTitleStyle.copyWith(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue[800])),
//             const SizedBox(height: 12),
//             Text(
//               'We couldn\'t find any jobs at the moment. Please check back later or try refreshing.',
//               textAlign: TextAlign.center,
//               style: _emptySubtitleStyle.copyWith(fontSize: 16),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _fetchJobs,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child:
//                   const Text('Refresh', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildJobList() {
//     if (_jobs.isEmpty) {
//       return _buildEmpty();
//     }
//     return RefreshIndicator(
//       color: Colors.blue,
//       backgroundColor: Colors.white,
//       onRefresh: _fetchJobs,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         itemCount: _jobs.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 8),
//         itemBuilder: (context, index) {
//           return _buildJobCard(_jobs[index]);
//         },
//       ),
//     );
//   }
// }
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Job Seeker'),
// //       ),
// //       drawer: _buildDrawer(),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _hasError
// //               ? Center(child: Text(_errorMessage, style: _errorStyle))
// //               : _buildJobList(),
// //     );
// //   }

// //   Widget _buildJobList() {
// //     if (_jobs.isEmpty) {
// //       return _buildEmpty();
// //     }
// //     return RefreshIndicator(
// //       color: Colors.blue,
// //       onRefresh: _fetchJobs,
// //       child: ListView.separated(
// //         padding: const EdgeInsets.symmetric(vertical: 16),
// //         itemCount: _jobs.length,
// //         separatorBuilder: (_, __) => const Divider(),
// //         itemBuilder: (context, index) {
// //           return _buildJobCard(_jobs[index]);
// //         },
// //       ),
// //     );
// //   }
// // }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_jobs/models/job.dart';
import 'package:mobile_jobs/pages/job_details.dart';
import 'package:mobile_jobs/pages/documents_page.dart';
import 'package:mobile_jobs/pages/profile.dart';
import 'package:mobile_jobs/pages/applied_jobs_page.dart';
import 'package:mobile_jobs/pages/drafts_page.dart';
import 'package:mobile_jobs/services/local_storage_service.dart';

class JobSeekerHomePage extends StatefulWidget {
  const JobSeekerHomePage({super.key});

  @override
  State<JobSeekerHomePage> createState() => _JobSeekerHomePageState();
}

class _JobSeekerHomePageState extends State<JobSeekerHomePage> {
  static const _baseUrl = 'https://api-qkosqkekfq-uc.a.run.app';
  final List<Job> _jobs = [];
  List<Job> _appliedJobs = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _refreshTimer;

  // Text styles
  final TextStyle _titleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey,
  );

  final TextStyle _subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey[600],
  );

  final TextStyle _errorStyle = const TextStyle(
    fontSize: 16,
    color: Colors.redAccent,
  );

  final TextStyle _emptyTitleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.blueGrey,
  );

  final TextStyle _emptySubtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  );

  final TextStyle _drawerHeaderStyle = const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadAppliedJobs(),
      _fetchJobs(),
    ]);
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isLoading) _fetchJobs();
    });
  }

  Future<void> _loadAppliedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appliedJobsJson = prefs.getStringList('appliedJobs') ?? [];

      if (mounted) {
        setState(() {
          _appliedJobs = appliedJobsJson
              .map((json) => Job.fromJson(jsonDecode(json)))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading applied jobs: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (route) => false,
      );
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveAppliedJob(Job job) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing applied job IDs
    List<String> appliedJobIds = prefs.getStringList('appliedJobIds') ?? [];

    // Add new job ID if not already there
    if (!appliedJobIds.contains(job.id)) {
      appliedJobIds.add(job.id);
      await prefs.setStringList('appliedJobIds', appliedJobIds);
    }

    setState(() {
      _appliedJobs.add(job);
    });

    print('Saved applied job ID: ${job.id}');
  }

  Future<void> _fetchJobs() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final cachedJobs = prefs.getString('cached_jobs');
    if (cachedJobs != null) {
      setState(() {
        _jobs.clear();
        _jobs.addAll(
            (jsonDecode(cachedJobs) as List).map((e) => Job.fromMap(e)));
      });
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final response = await http
          .get(Uri.parse('${_baseUrl}/jobs'))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseBody = response.body;
        await prefs.setString('cached_jobs', responseBody);
        final List<dynamic> responseData = jsonDecode(responseBody);
        setState(() {
          _jobs.clear();
          _jobs.addAll(responseData.map((e) => Job.fromMap(e)));
          _isLoading = false;
        });
      } else {
        throw _parseError(response);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  String _parseError(http.Response response) {
    return response.body.isNotEmpty
        ? jsonDecode(response.body)['error'] ?? 'Failed to load jobs'
        : 'Failed to load jobs (Status: ${response.statusCode})';
  }

  void _handleError(dynamic error) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error is http.ClientException
          ? 'Network error: ${error.message}'
          : error is TimeoutException
              ? 'Request timed out. Please try again.'
              : error.toString().replaceAll('Exception: ', '');
    });
  }

  void _navigateToJobDetails(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsPage(
          job: job,
          isApplied: _appliedJobs.any((j) => j.id == job.id),
          onApply: () => _applyForJob(job),
        ),
      ),
    );
  }

  Future<void> _applyForJob(Job job) async {
    try {
      await _saveAppliedJob(job);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully applied for ${job.title}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildJobCard(Job job) {
    final isApplied = _appliedJobs.any((j) => j.id == job.id);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToJobDetails(job),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobHeader(job, isApplied),
                const SizedBox(height: 8),
                Text(job.company,
                    style: _subtitleStyle.copyWith(
                        color: Colors.blueGrey[700],
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Text(
                  job.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildJobTags(job),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobHeader(Job job, bool isApplied) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            job.title,
            style: _titleStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.blue[900]),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: FutureBuilder<bool>(
                future: LocalStorageService.isFavorite(job.id),
                builder: (context, snapshot) {
                  return Icon(
                    snapshot.data == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red[400],
                  );
                },
              ),
              onPressed: () async {
                await LocalStorageService.toggleFavorite(job.id);
                setState(() {});
              },
            ),
            if (isApplied)
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildJobTags(Job job) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (job.location != null && job.location!.isNotEmpty)
          _buildInfoChip(icon: Icons.location_on, text: job.location!),
        if (job.salary != null && job.salary!.isNotEmpty)
          _buildInfoChip(icon: Icons.attach_money, text: job.salary!),
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.blue[800]),
      label:
          Text(text, style: TextStyle(fontSize: 12, color: Colors.blue[800])),
      visualDensity: VisualDensity.compact,
      backgroundColor: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blue[100]!),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[800]!, Colors.blue[600]!],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child:
                              Icon(Icons.person, size: 40, color: Colors.blue),
                        ),
                        const SizedBox(height: 16),
                        Text('Hello, Candidate',
                            style: _drawerHeaderStyle.copyWith(fontSize: 22)),
                      ],
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.description,
                    title: 'Documents',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DocumentsPage()),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.work,
                    title: 'Applied Jobs',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AppliedJobsPage(
                                appliedJobs: [],
                                userId: '',
                              )),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.drafts,
                    title: 'Drafts',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DraftsPage()),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red[400],
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white70),
      title: Text(title,
          style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 100, color: Colors.blue[300]),
            const SizedBox(height: 24),
            Text('No Jobs Available',
                style: _emptyTitleStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800])),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any jobs at the moment. Please check back later or try refreshing.',
              textAlign: TextAlign.center,
              style: _emptySubtitleStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child:
                  const Text('Refresh', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Seeker'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: _errorStyle.copyWith(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchJobs,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Retry',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : _buildJobList(),
      ),
    );
  }

  Widget _buildJobList() {
    if (_jobs.isEmpty) {
      return _buildEmpty();
    }
    return RefreshIndicator(
      color: Colors.blue,
      backgroundColor: Colors.white,
      onRefresh: _fetchJobs,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _jobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _buildJobCard(_jobs[index]);
        },
      ),
    );
  }
}
