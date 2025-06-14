import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // for video playback
import 'api_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StatusPage(),
      routes: {
        '/pending': (context) =>
            VideoListPage(title: 'Pending Videos', status: 'pending'),
        '/flagged': (context) =>
            VideoListPage(title: 'Flagged Videos', status: 'flagged'),
        '/approved': (context) =>
            VideoListPage(title: 'Approved Videos', status: 'approved'),
      },
    );
  }
}

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatusButton(
              label: 'Pending',
              color: Colors.orange,
              icon: Icons.hourglass_bottom,
              onTap: () => Navigator.pushNamed(context, '/pending'),
            ),
            const SizedBox(height: 20),
            StatusButton(
              label: 'Flagged',
              color: Colors.red,
              icon: Icons.flag,
              onTap: () => Navigator.pushNamed(context, '/flagged'),
            ),
            const SizedBox(height: 20),
            StatusButton(
              label: 'Approved',
              color: Colors.green,
              icon: Icons.check_circle,
              onTap: () => Navigator.pushNamed(context, '/approved'),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const StatusButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: const Color.fromARGB(255, 33, 12, 12),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}

class VideoListPage extends StatelessWidget {
  final String title;
  final String status;

  VideoListPage({super.key, required this.title, required this.status});

  // Create an instance of ApiService
  final ApiService apiService = ApiService();

  Future<List<Map<String, dynamic>>> fetchVideos() {
    return ApiService.fetchVideos(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final videos = snapshot.data!;
          if (videos.isEmpty) return const Center(child: Text('No videos'));

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                leading: const Icon(Icons.play_arrow),
                title: Text(video['title']),
                subtitle: Text(video['url']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoDetailsPage(videoData: video),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class VideoDetailsPage extends StatefulWidget {
  final Map<String, dynamic> videoData;

  const VideoDetailsPage({super.key, required this.videoData});

  @override
  State<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    // Initialize the video player with the video URL
    controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoData['url']))
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Dummy baby info and technical details - replace with real data as needed
  final babyInfo = {
    'Baby Name': 'John Doe',
    'Date of Birth': '2024-02-20',
    'Location': 'New York, USA',
    'Uploaded By': 'Patient XYZ',
  };

  final technicalDetails = {
    'Video Title': '',
    'Status': '',
    'Upload Date': '2025-05-30',
    'Video Length': '2:30',
    'Phone Model': 'Pixel 4a',
  };

  @override
  Widget build(BuildContext context) {
    technicalDetails['Video Title'] = widget.videoData['title'] ?? 'N/A';
    technicalDetails['Status'] = widget.videoData['status'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: Text(widget.videoData['title'] ?? 'Video Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Section
            if (controller.value.isInitialized)
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 12),

            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    setState(() {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    // Optional: Implement fullscreen if you want
                  },
                ),
              ],
            ),
            const Divider(),

            // Baby Information Section
            const Text(
              'Baby Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...babyInfo.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${e.key}: ${e.value}'),
              ),
            ),

            const Divider(),

            // Technical Details Section
            const Text(
              'Technical Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...technicalDetails.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${e.key}: ${e.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
