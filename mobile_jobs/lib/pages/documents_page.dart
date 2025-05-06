import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('saved_documents') ?? [];

    final loadedDocs = <Map<String, dynamic>>[];

    for (var entry in rawList) {
      final parts = entry.split('||');
      if (parts.length != 4) continue;

      try {
        loadedDocs.add({
          'name': parts[0],
          'path': parts[1],
          'type': parts[2],
          'date': DateTime.parse(parts[3]),
        });
      } catch (_) {
        // Skip malformed or corrupted entries
        continue;
      }
    }

    setState(() {
      _documents = loadedDocs;
      _isLoading = false;
    });
  }

  Future<void> _addDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileExt = fileName.split('.').last.toLowerCase();

        final appDir = await getApplicationDocumentsDirectory();
        final savedFile = await file.copy('${appDir.path}/$fileName');

        final prefs = await SharedPreferences.getInstance();
        final documents = prefs.getStringList('saved_documents') ?? [];

        final newEntry =
            '$fileName||${savedFile.path}||$fileExt||${DateTime.now().toIso8601String()}';

        documents.add(newEntry);
        await prefs.setStringList('saved_documents', documents);

        await _loadDocuments(); // Refresh
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding document: ${e.toString()}')),
      );
    }
  }

  Future<void> _openDocument(String path) async {
    try {
      await OpenFilex.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open file: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteDocument(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documents = prefs.getStringList('saved_documents') ?? [];

      final path = _documents[index]['path'];
      if (await File(path).exists()) {
        await File(path).delete();
      }

      documents.removeAt(index);
      await prefs.setStringList('saved_documents', documents);

      await _loadDocuments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting document: ${e.toString()}')),
      );
    }
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No documents saved',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your resumes and certificates',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(_getFileIcon(doc['type']), color: Colors.blue),
                        title: Text(doc['name']),
                        subtitle: Text(
                          'Added: ${DateFormat('MMM d, y').format(doc['date'])}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'open') {
                              _openDocument(doc['path']);
                            } else if (value == 'delete') {
                              _deleteDocument(index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'open', child: Text('Open')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                        onTap: () => _openDocument(doc['path']),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDocument,
        tooltip: 'Add Document',
        child: const Icon(Icons.add),
      ),
    );
  }
}
