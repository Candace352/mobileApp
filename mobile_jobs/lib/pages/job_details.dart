import 'package:flutter/material.dart';
import 'package:mobile_jobs/models/job.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;
  final bool isApplied;
  final Future<void> Function() onApply;

  const JobDetailsPage({
    super.key,
    required this.job,
    required this.isApplied,
    required this.onApply,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  bool _isApplying = false;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _isApplied = widget.isApplied;
  }

  Future<void> _handleApply() async {
    if (_isApplied) return;

    setState(() {
      _isApplying = true;
    });

    try {
      await widget.onApply();
      setState(() {
        _isApplied = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.title),
        actions: [
          if (_isApplied)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: null, // Disabled
              tooltip: 'Already applied',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.job.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.company,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Job Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (widget.job.location != null && widget.job.location!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.job.location!),
                  const SizedBox(height: 24),
                ],
              ),
            if (widget.job.salary != null && widget.job.salary!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Salary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.job.salary!),
                ],
              ),
            // Add more fields from your Job model as needed
            // For example, if you have qualifications or other fields:
            /*
            if (widget.job.qualifications != null && widget.job.qualifications!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Qualifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.job.qualifications!),
                ],
              ),
            */
          ],
        ),
      ),
      floatingActionButton: _isApplied
          ? FloatingActionButton.extended(
              onPressed: null,
              label: const Text('Applied'),
              icon: const Icon(Icons.check),
              backgroundColor: Colors.green,
            )
          : FloatingActionButton.extended(
              onPressed: _isApplying ? null : _handleApply,
              label: _isApplying
                  ? const Text('Applying...')
                  : const Text('Apply Now'),
              icon: _isApplying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
    );
  }
}
