import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../board/screens/board_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../submit/screens/submissions_review_screen.dart';
import '../../team/screens/team_screen.dart';
import '../../admin/screens/admin_manage_judges_screen.dart';
import '../../admin/screens/admin_manage_hackathons_screen.dart';
import '../../schedule/screens/manage_schedule_screen.dart';
import '../../../shared/widgets/global_bottom_nav_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const TeamScreen.viewer(),
    const AdminManageHackathonsScreen(),
    const BoardScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex =
        widget.initialIndex >= 0 && widget.initialIndex < _pages.length
            ? widget.initialIndex
            : 0;
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      body: IndexedStack(
        sizing: StackFit.expand,
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: GlobalBottomNavBar(
        items: adminBottomNavItems,
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Widget _buildCollectionCountCard({
    required String title,
    required String collection,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length;
        return StatCard(
          title: title,
          value: count?.toString() ?? '--',
          increase: 'Live',
          icon: icon,
          gradient: gradient,
        );
      },
    );
  }

  Widget _buildRoleCountCard({
    required String title,
    required String role,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: role)
              .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length;
        return StatCard(
          title: title,
          value: count?.toString() ?? '--',
          increase: 'Live',
          icon: icon,
          gradient: gradient,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// STATUS BAR
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF3F4F6),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),

        child: Column(
          children: [
            /// PURPLE HEADER
            Container(
              width: double.infinity,

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4F39F6),
                    Color(0xFF9810FA),
                    Color(0xFF432DD7),
                  ],
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),

              child: SafeArea(
                bottom: false,

                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),

                  child: Column(
                    children: [
                      /// HEADER ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Admin Dashboard 👨‍💼",
                                style: TextStyle(
                                  color: Color(0xFFC6D2FF),
                                  fontSize: 14,
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                "Spring Hack 2026",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          Container(
                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// STATUS CARD
                      Container(
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.18),
                              Colors.white.withOpacity(0.08),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(24),
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,

                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),

                              child: const Center(
                                child: Text(
                                  "👑",
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Your Role",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.admin_panel_settings,
                                        size: 14,
                                        color: Color(0xFFE0E7FF),
                                      ),

                                      SizedBox(width: 4),

                                      Text(
                                        "Administrator",
                                        style: TextStyle(
                                          color: Color(0xFFE0E7FF),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Text(
                                  "Day 1 of 2",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  "36h remaining",
                                  style: TextStyle(
                                    color: Color(0xFFE0E7FF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [
                  /// STATS GRID
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,

                    children: [
                      const StatCard(
                        title: "Participants",
                        value: "156",
                        increase: "+12",
                        icon: Icons.people_alt_rounded,
                        gradient: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),

                      _buildCollectionCountCard(
                        title: "Teams",
                        collection: 'teams',
                        icon: Icons.groups_rounded,
                        gradient: [Color(0xFF9333EA), Color(0xFFC026D3)],
                      ),

                      _buildCollectionCountCard(
                        title: "Submissions",
                        collection: 'submissions',
                        icon: Icons.description_rounded,
                        gradient: [Color(0xFF16A34A), Color(0xFF22C55E)],
                      ),

                      _buildRoleCountCard(
                        title: "Judges",
                        role: 'judge',
                        icon: Icons.emoji_events_rounded,
                        gradient: [Color(0xFFD97706), Color(0xFFF59E0B)],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// QUICK ACTIONS
                  sectionTitle("Quick Actions"),

                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.08,

                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const AdminAddHackathonScreen(),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const ActionCard(
                          title: "Add\nHackathon",
                          icon: Icons.rocket_launch_rounded,
                          gradient: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminManageJudgesScreen(),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,

                        child: const ActionCard(
                          title: "Manage Judges",
                          icon: Icons.groups_rounded,

                          gradient: [Color(0xFFA21CAF), Color(0xFFD946EF)],
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const SubmissionsReviewScreen.admin(),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const ActionCard(
                          title: "View Submissions",
                          icon: Icons.description_outlined,
                          gradient: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageScheduleScreen(),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const ActionCard(
                          title: "Schedule Event",
                          icon: Icons.calendar_month_rounded,
                          gradient: [Color(0xFF16A34A), Color(0xFF22C55E)],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// TASKS
                  sectionTitle("Pending Tasks"),

                  const SizedBox(height: 16),

                  TaskCard(
                    title: "Team Registration",
                    subtitle: "Code Warriors needs approval",
                    time: "5 min ago",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TeamScreen.viewer(
                            title: "Registered Teams",
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  TaskCard(
                    title: "Submission Review",
                    subtitle: "AI Innovators submitted project",
                    time: "12 min ago",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubmissionsReviewScreen.admin(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  TaskCard(
                    title: "Judge Assignment",
                    subtitle: "2 teams need judges assigned",
                    time: "30 min ago",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminManageJudgesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String increase;
  final IconData icon;
  final List<Color> gradient;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.increase,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: Colors.white, size: 22),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Text(
                  increase,
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: Colors.white),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
              ),

              child: const Icon(
                Icons.pending_actions_rounded,
                color: Color(0xFFD97706),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Text(
                "Review",
                style: TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
