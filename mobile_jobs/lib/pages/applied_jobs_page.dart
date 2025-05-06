import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_jobs/models/job.dart';
import 'package:mobile_jobs/pages/job_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppliedJobsPage extends StatefulWidget {
  final String userId;

  const AppliedJobsPage(
      {super.key, required this.userId, required List appliedJobs});

  @override
  State<AppliedJobsPage> createState() => _AppliedJobsPageState();
}

class _AppliedJobsPageState extends State<AppliedJobsPage> {
  static const _baseUrl =
      'https://api-qkosqkekfq-uc.a.run.app'; // Replace with your actual URL
  List<Job> _appliedJobs = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Hardcoded jobs for demo/recording purposes
    _appliedJobs = [
      Job(
        id: 'demo-job-1',
        title: 'Flutter Developer',
        company: 'Tech Startup Inc.',
        description: 'Develop mobile apps using Flutter for Android and iOS.',
        location: 'Accra, Ghana',
        salary: '\$1000/month',
        createdAt: DateTime.now(),
      ),
      // Job(
      //   id: 'demo-job-2',
      //   title: 'Backend Developer',
      //   company: 'Web Solutions Ltd.',
      //   description: 'Build scalable backend services and databases.',
      //   location: 'Harare, Zimbabwe',
      //   salary: '\$1200/month',
      //   createdAt: DateTime.now().subtract(Duration(days: 3)),
      // ),
      // Job(
      //   id: 'demo-job-3',
      //   title: 'UI/UX Designer',
      //   company: 'Design Studio',
      //   description: 'Design user interfaces and enhance user experience.',
      //   location: 'Lagos, Nigeria',
      //   salary: '\$900/month',
      //   createdAt: DateTime.now().subtract(Duration(days: 5)),
      // ),
    ];

    // Stop the loading spinner immediately after setting hardcoded data
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteApplication(int index) async {
    final jobToRemove = _appliedJobs[index];

    try {
      final prefs = await SharedPreferences.getInstance();
      final appliedJobIds =
          prefs.getStringList('appliedJobs_${widget.userId}') ?? [];

      // Remove from local storage
      appliedJobIds.remove(jobToRemove.id);
      await prefs.setStringList('appliedJobs_${widget.userId}', appliedJobIds);

      // Update UI
      setState(() => _appliedJobs.removeAt(index));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${jobToRemove.title} application'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _undoDelete(index, jobToRemove),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove application: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _undoDelete(int index, Job job) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appliedJobIds =
          prefs.getStringList('appliedJobs_${widget.userId}') ?? [];

      // Add back to local storage
      appliedJobIds.add(job.id);
      await prefs.setStringList('appliedJobs_${widget.userId}', appliedJobIds);

      // Update UI
      setState(() => _appliedJobs.insert(index, job));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to undo removal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatApplicationDate(dynamic timestamp) {
    try {
      if (timestamp == null) return 'Date not available';

      if (timestamp is DateTime) {
        return DateFormat('MMM dd, yyyy').format(timestamp);
      }

      if (timestamp is Map<String, dynamic>) {
        if (timestamp['_seconds'] != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(
            timestamp['_seconds'] * 1000,
          );
          return DateFormat('MMM dd, yyyy').format(date);
        }
        if (timestamp['timestamp'] != null) {
          return DateFormat('MMM dd, yyyy').format(
            DateTime.parse(timestamp['timestamp'].toString()),
          );
        }
      }

      if (timestamp is String) {
        return DateFormat('MMM dd, yyyy').format(DateTime.parse(timestamp));
      }

      return 'Unknown date format';
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Invalid date';
    }
  }

  void _navigateToJobDetails(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsPage(
          job: job,
          isApplied: true,
          onApply: () async {}, // No action needed since already applied
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Applications Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Apply to jobs from the home page',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Browse Jobs',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToJobDetails(job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteApplication(index),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.company,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              if (job.location != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(job.location!),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Applied on ${_formatApplicationDate(job.createdAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (job.salary != null)
                    Text(
                      job.salary!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Jobs'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text(_errorMessage))
              : _appliedJobs.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _appliedJobs.length,
                        itemBuilder: (context, index) =>
                            _buildJobCard(_appliedJobs[index], index),
                      ),
                    ),
    );
  }
}
