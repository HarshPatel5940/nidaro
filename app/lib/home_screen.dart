import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'constants.dart';
import 'search_business_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'color_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showNotificationPanel = false;

  // Mock notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'N1001',
      'title': 'Report Verified',
      'message': 'Your report against Tech Solutions has been verified.',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'id': 'N1002',
      'title': 'New Report',
      'message': 'A new report has been filed against your business.',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'id': 'N1003',
      'title': 'GSTIN Update',
      'message': 'The GSTIN details for your business have been updated.',
      'time': '3 days ago',
      'isRead': true,
    },
    {
      'id': 'N1004',
      'title': 'System Maintenance',
      'message': 'The application will be under maintenance on May 15, 2025.',
      'time': '1 week ago',
      'isRead': true,
    },
  ];

  final List<Widget> _screens = [
    const SearchBusinessScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  final List<String> _screenTitles = ['Search Business', 'Reports', 'Profile'];

  void _toggleNotificationPanel() {
    setState(() {
      _showNotificationPanel = !_showNotificationPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Nidaro' : _screenTitles[_currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                ),
                onPressed: _toggleNotificationPanel,
              ),
              if (_notifications.any((n) => !n['isRead']))
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.googleRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],

          // Semi-transparent overlay when notification panel is open
          if (_showNotificationPanel)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleNotificationPanel,
                child: Container(
                  color: Colors.black.withAlpha(ColorUtils.alpha30Percent),
                ), // Using ColorUtils.alpha30Percent
              ),
            ),

          // Notification panel
          if (_showNotificationPanel)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: MediaQuery.of(context).size.width * 0.85,
              child: Material(
                elevation: 8,
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      _toggleNotificationPanel();
                    }
                  },
                  child: FadeInRight(
                    duration: AppDurations.fast,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _toggleNotificationPanel,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child:
                                _notifications.isEmpty
                                    ? const Center(
                                      child: Text('No notifications'),
                                    )
                                    : ListView.builder(
                                      itemCount: _notifications.length,
                                      itemBuilder: (context, index) {
                                        final notification =
                                            _notifications[index];
                                        return _buildNotificationItem(
                                          notification,
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_showNotificationPanel) {
              _showNotificationPanel = false;
            }
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.googleBlue,
        unselectedItemColor: AppColors.mediumGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color:
              notification['isRead']
                  ? Colors.white
                  : AppColors.googleBlue.withAlpha(ColorUtils.alpha5Percent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      notification['isRead']
                          ? Colors.transparent
                          : AppColors.googleBlue,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(notification['message']),
                    const SizedBox(height: 8),
                    Text(
                      notification['time'],
                      style: const TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
