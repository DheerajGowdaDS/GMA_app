import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlaggedPage extends StatefulWidget {
  const FlaggedPage({super.key});

  @override
  State<FlaggedPage> createState() => _FlaggedPageState();
}

class _FlaggedPageState extends State<FlaggedPage> {
  final List<Map<String, dynamic>> _allVideos = [
    {'title': 'Flagged Video A', 'date': DateTime(2025, 5, 20)},
    {'title': 'Flagged Video B', 'date': DateTime(2025, 5, 25)},
    {'title': 'Test Clip', 'date': DateTime(2025, 5, 29)},
    {'title': 'Another Video', 'date': DateTime(2025, 5, 29)},
  ];

  List<Map<String, dynamic>> _filteredVideos = [];
  String _searchText = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _filteredVideos = List.from(_allVideos);
  }

  void _filterVideos() {
    setState(() {
      _filteredVideos = _allVideos.where((video) {
        final matchTitle = video['title'].toString().toLowerCase().contains(
          _searchText.toLowerCase(),
        );

        final matchDate =
            _selectedDate == null ||
            DateUtils.isSameDay(video['date'], _selectedDate);

        return matchTitle && matchDate;
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _filterVideos();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _filterVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flagged Videos')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by title',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchText = value;
                _filterVideos();
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'No date selected'
                      : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        onPressed: _clearDateFilter,
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredVideos.isEmpty
                  ? const Center(child: Text('No videos found.'))
                  : ListView.builder(
                      itemCount: _filteredVideos.length,
                      itemBuilder: (context, index) {
                        final video = _filteredVideos[index];
                        return ListTile(
                          leading: const Icon(Icons.video_library),
                          title: Text(video['title']),
                          subtitle: Text(
                            DateFormat('yyyy-MM-dd').format(video['date']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
