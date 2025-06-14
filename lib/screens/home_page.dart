import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'folder_page.dart';
import 'approved_page.dart';
import 'flagged_page.dart';
import 'pending_page.dart';
import 'comment_page.dart';
import 'approved_video_detail_page.dart';
import '../models/video_model.dart';
import 'video_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<VideoProvider>(context);

    final allVideos = [
      ...provider.pendingVideos,
      ...provider.approvedVideos,
      ...provider.flaggedVideos,
    ];

    return Scaffold(
      drawer: _buildDrawer(context, allVideos),
      appBar: AppBar(
        title: Text("Doctor Dashboard",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Theme toggle not implemented")),
              );
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _gradientBackground(),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              Text("Folders",
                  style: GoogleFonts.montserrat(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildAnimatedFolderTile(
                  "Approved", provider.approvedVideos.length, Colors.green.shade100,
                  Icons.check_circle_outline, const ApprovedPage(), 0),
              const SizedBox(height: 16),
              _buildAnimatedFolderTile(
                  "Flagged", provider.flaggedVideos.length, Colors.red.shade100,
                  Icons.flag_outlined, const FlaggedPage(), 1),
              const SizedBox(height: 16),
              _buildAnimatedFolderTile(
                  "Pending", provider.pendingVideos.length, Colors.amber.shade100,
                  Icons.hourglass_empty, const PendingPage(), 2),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _gradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFF2F6FF), Color(0xFFDBEAFE), Color(0xFFE0F7FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, size: 30, color: Colors.blue.shade800),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Welcome back, Doctor!',
                textStyle: GoogleFonts.lato(
                    fontSize: 24, fontWeight: FontWeight.bold),
                speed: const Duration(milliseconds: 80),
              ),
            ],
            totalRepeatCount: 1,
            pause: const Duration(milliseconds: 1000),
            displayFullTextOnTap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedFolderTile(String title, int count, Color color,
      IconData icon, Widget page, int index) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.1 * (index + 1)),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 * index, 0.7, curve: Curves.easeOut),
        )),
        child: GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => page)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Colors.black87),
                const SizedBox(height: 10),
                Text(
                  count.toString(),
                  style: GoogleFonts.montserrat(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.lato(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, List<Video> allVideos) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade400],
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/doctor_avatar.png'),
                ),
                const SizedBox(height: 8),
                Text("Dr. Smith",
                    style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text("Cardiologist",
                    style: GoogleFonts.lato(
                        color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),
          if (allVideos.isNotEmpty) ...[
            ListTile(
              leading: const Icon(Icons.video_collection),
              title: const Text("Videos"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ApprovedVideoDetailPage(video: allVideos.first)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.comment),
              title: const Text("Comments"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        CommentPage(videoId: allVideos.first.id)),
              ),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
