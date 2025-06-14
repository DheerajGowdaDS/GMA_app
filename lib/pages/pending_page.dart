import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PendingPage extends StatefulWidget {
  const PendingPage({super.key});

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  final List<Map<String, dynamic>> _allVideos = [
    {'title': 'Pending Video 1', 'date': DateTime(2025, 5, 21)},
    {'title': 'Pending Clip 2', 'date': DateTime(2025, 5, 24)},
    {'title': 'Test Pending', 'date': DateTime(2025, 5, 29)},
  ];

  List<Map<String, dynamic>> _filteredVideos = [];
  String _searchText = '';
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

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

  void _clearSearch() {
    _searchController.clear();
    _searchText = '';
    _filterVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _filteredVideos.isEmpty ? 'No Videos Found' : 'Pending Videos',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
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
