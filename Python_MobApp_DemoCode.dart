import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => DirectoryProvider()),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class ScheduleItem {
  final String title;
  final String time;
  final String location;
  ScheduleItem({required this.title, required this.time, required this.location});
}

class Announcement {
  final String title;
  final String content;
  final bool isRead;
  Announcement({required this.title, required this.content, required this.isRead});
}

class DirectoryEntry {
  final String name;
  final String office;
  DirectoryEntry({required this.name, required this.office});
}

class ScheduleProvider extends ChangeNotifier {
  final List<ScheduleItem> _todaySchedule = [
    ScheduleItem(title: 'Class Schedule', time: '10:00 AM', location: 'Lab A'),
    ScheduleItem(title: 'Meeting', time: '02:00 PM', location: 'Hall 4'),
  ];
  List<ScheduleItem> get todaySchedule => _todaySchedule;
}

class AnnouncementProvider extends ChangeNotifier {
  final List<Announcement> _announcements = [
    Announcement(title: 'Library Maintenance', content: 'Closed this weekend.', isRead: false),
  ];
  List<Announcement> get announcements => _announcements;
  int get unreadCount => _announcements.where((a) => !a.isRead).length;
}

class DirectoryProvider extends ChangeNotifier {
  final List<DirectoryEntry> _directory = [
    DirectoryEntry(name: 'Registrar', office: 'Admin Bldg 136'),
    DirectoryEntry(name: 'CSE Deparment office', office: 'Block 508'),
  ];
  List<DirectoryEntry> get directory => _directory;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  Future<void> _handleNavigation(int index) async {
    setState(() => _selectedNavIndex = index);
    if (index == 1) {
      final Uri url = Uri.parse('https://calendar.google.com');
      if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astu Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _GreetingSection(),
            _ScheduleSection(),
            const SizedBox(height: 20),
            _MapAndDirectorySection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        onTap: _handleNavigation,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Welcome!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      );
}

class _ScheduleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(builder: (context, provider, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...provider.todaySchedule.map<Widget>((item) => Card(
                child: ListTile(title: Text(item.title), subtitle: Text('${item.time} | ${item.location}')),
              )),
        ],
      );
    });
  }
}

class _MapAndDirectorySection extends StatelessWidget {
  final String mapUrl = "https://www.google.com/maps/place/8%C2%B033'49.2%22N+39%C2%B017'03.3%22E/@8.563672,39.284258,6559m/data=!3m1!1e3!4m4!3m3!8m2!3d8.5636718!4d39.284258?hl=en-US&entry=ttu&g_ep=EgoyMDI2MDUxMi4wIKXMDSoASAFQAw%3D%3D";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Campus Resources', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.map, color: Colors.blue),
          title: const Text('View Campus Map'),
          onTap: () async {
            final Uri url = Uri.parse(mapUrl);
            if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
          },
        ),
        const Divider(),
        const Text('Office Directory', style: TextStyle(fontWeight: FontWeight.bold)),
        Consumer<DirectoryProvider>(builder: (context, provider, _) {
          return Column(
            children: provider.directory.map<Widget>((e) => ListTile(title: Text(e.name), subtitle: Text(e.office))).toList(),
          );
        }),
      ],
    );
  }
} 
