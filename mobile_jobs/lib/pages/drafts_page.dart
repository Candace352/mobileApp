import 'package:flutter/material.dart';
import 'package:mobile_jobs/services/local_storage_service.dart';

class DraftsPage extends StatelessWidget {
  const DraftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draft Applications')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: LocalStorageService.getDrafts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final drafts = snapshot.data!;
          if (drafts.isEmpty) {
            return const Center(child: Text('No draft applications'));
          }
          
          return ListView.builder(
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return ListTile(
                title: Text(draft['jobTitle'] ?? 'Untitled Draft'),
                subtitle: Text('Last saved: ${draft['timestamp']}'),
                onTap: () {
                  // Navigate to application form with draft data
                },
              );
            },
          );
        },
      ),
    );
  }
}