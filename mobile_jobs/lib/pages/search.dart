// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:mobile_jobs/pages/job_details.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({Key? key}) : super(key: key);

//   @override
//   _SearchPageState createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   String _selectedSalaryRange = 'Any';
//   late Future<List<Map<String, String>>> searchResults;

//   Future<List<Map<String, String>>> searchJobs(String title, String location, String salary) async {
//     final response = await http.get(Uri.parse('https://yourapi.com/api/jobs/search?title=$title&location=$location&salary=$salary'));

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return List<Map<String, String>>.from(data.map((item) => Map<String, String>.from(item)));
//     } else {
//       throw Exception('Failed to load jobs');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Search Jobs'),
//         backgroundColor: const Color(0xFFdc2f02),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 labelText: 'Job Title',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _locationController,
//               decoration: const InputDecoration(
//                 labelText: 'Location',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _selectedSalaryRange,
//               items: ['Any', 'USD 1000-2000', 'USD 2000-3000', 'USD 3000+']
//                   .map((salaryRange) {
//                 return DropdownMenuItem<String>(
//                   value: salaryRange,
//                   child: Text(salaryRange),
//                 );
//               }).toList(),
//               onChanged: (newValue) {
//                 setState(() {
//                   _selectedSalaryRange = newValue!;
//                 });
//               },
//               decoration: const InputDecoration(
//                 labelText: 'Salary Range',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   searchResults = searchJobs(
//                     _titleController.text,
//                     _locationController.text,
//                     _selectedSalaryRange,
//                   );
//                 });
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFdc2f02)),
//               child: const Text('Search Jobs'),
//             ),
//             const SizedBox(height: 16),
//             FutureBuilder<List<Map<String, String>>>(
//               future: searchResults,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No jobs found'));
//                 }

//                 final jobs = snapshot.data!;
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: jobs.length,
//                   itemBuilder: (context, index) {
//                     final job = jobs[index];
//                     return ListTile(
//                       title: Text(job['title']!),
//                       subtitle: Text(job['company']!),
//                       onTap: () {
//                         // Navigate to job details page
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => JobDetailPage(jobId: job['id']!),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
