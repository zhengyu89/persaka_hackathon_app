import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/widgets/global_bottom_nav_bar.dart';

import 'admin_dashboard.dart';
import 'admin_add_judges_screen.dart';

class AssignJudgesScreen extends StatefulWidget {
  const AssignJudgesScreen({super.key});

  @override
  State<AssignJudgesScreen> createState() =>
      _AssignJudgesScreenState();
}

class _AssignJudgesScreenState
    extends State<AssignJudgesScreen> {

  final int _currentIndex = 0;

  /// FIREBASE JUDGES
  List<Map<String, dynamic>> judges = [];

  /// LOAD JUDGES
  Future<void> loadJudges() async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .where(
              "role",
              isEqualTo: "judge",
            )
            .get();

    judges =
        snapshot.docs.map((doc) {
      final data =
          doc.data();

      return {

        "name":
            data["name"] ?? "",

        "email":
            data["email"] ?? "",

        "specialty":
            data["specialty"] ?? "General",

        "teams":
            data["teams"] ?? 0,
      };

    }).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadJudges();
  }

  void _onBottomTap(int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboard(
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.light,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          const Color(0xFFF9FAFB),

      /// =========================
      /// BOTTOM NAV
      /// =========================
      bottomNavigationBar: GlobalBottomNavBar(
        items: adminBottomNavItems,
        currentIndex: _currentIndex,
        onTap: _onBottomTap,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(bottom: 120),

        child: Column(
          children: [

            /// =========================
            /// HEADER
            /// =========================
            Container(
              width: double.infinity,

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:
                      Alignment.bottomRight,

                  colors: [
                    Color(0xFFFE9A00),
                    Color(0xFFFF6900),
                    Color(0xFFE17100),
                  ],
                ),

                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(30),
                  bottomRight:
                      Radius.circular(30),
                ),
              ),

              child: SafeArea(
                bottom: false,

                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      Row(
                        children: [

                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                  context);
                            },

                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .all(10),

                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .white
                                    .withOpacity(
                                        0.15),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            14),
                              ),

                              child: const Icon(
                                Icons
                                    .arrow_back_ios_new,
                                color:
                                    Colors.white,
                                size: 18,
                              ),
                            ),
                          ),

                          const SizedBox(
                              width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [

                                const Text(
                                  "Judges Management",

                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,

                                    fontSize:
                                        24,

                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),

                                const SizedBox(
                                    height: 4),

                                Text(
                                  "${judges.length} judges registered",

                                  style:
                                      const TextStyle(
                                    color: Color(
                                        0xFFFFF1D6),

                                    fontSize:
                                        14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 28),

                      Row(
                        children: [

                          Expanded(
                            child: statsCard(
                              judges.length
                                  .toString(),
                              "Total Judges",
                            ),
                          ),

                          const SizedBox(
                              width: 12),

                          Expanded(
                            child: statsCard(
                              "22",
                              "Assigned",
                            ),
                          ),

                          const SizedBox(
                              width: 12),

                          Expanded(
                            child: statsCard(
                              judges.length
                                  .toString(),
                              "Active",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// =========================
                  /// ADD BUTTON
                  /// =========================
                  SizedBox(
                    width: double.infinity,
                    height: 56,

                    child:
                        ElevatedButton.icon(
                      onPressed: () async {

                        final result =
                            await showGeneralDialog(
                          context: context,

                          barrierDismissible:
                              true,

                          barrierLabel:
                              "Add Judge",

                          barrierColor:
                              Colors.black
                                  .withOpacity(
                                      0.15),

                          transitionDuration:
                              const Duration(
                            milliseconds: 300,
                          ),

                          pageBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                          ) {

                            return const AdminAddJudgesScreen();
                          },

                          transitionBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {

                            return FadeTransition(
                              opacity:
                                  animation,

                              child:
                                  ScaleTransition(
                                scale:
                                    Tween<double>(
                                  begin:
                                      0.95,
                                  end: 1,
                                ).animate(
                                  CurvedAnimation(
                                    parent:
                                        animation,

                                    curve:
                                        Curves
                                            .easeOut,
                                  ),
                                ),

                                child:
                                    child,
                              ),
                            );
                          },
                        );

                        if (result != null) {

                          await loadJudges();

                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Judge added successfully",
                              ),
                            ),
                          );
                        }
                      },

                      style:
                          ElevatedButton.styleFrom(
                        elevation: 0,

                        backgroundColor:
                            const Color(
                                0xFF6D28D9),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(18),
                        ),
                      ),

                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),

                      label: const Text(
                        "Add New Judge",

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "All Judges",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// =========================
                  /// JUDGES LIST
                  /// =========================
                  ...List.generate(
                    judges.length,
                    (index) {

                      final judge =
                          judges[index];

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 16,
                        ),

                        child: judgeCard(
                          judge,
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

  Widget statsCard(
    String value,
    String label,
  ) {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 18,
      ),

      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.18),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Text(
            value,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,

            style: const TextStyle(
              color: Color(0xFFFFF1D6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget judgeCard(
    Map<String, dynamic> judge,
  ) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFFFE9A00),
                  Color(0xFFF54900),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(
                      16),
            ),

            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Text(
                  judge["name"],

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  judge["email"],

                  style:
                      const TextStyle(
                    fontSize: 13,
                    color:
                        Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF3E8FF),

                    borderRadius:
                        BorderRadius.circular(
                            12),
                  ),

                  child: Text(
                    judge["specialty"],

                    style: const TextStyle(
                      color:
                          Color(0xFF9810FA),
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
