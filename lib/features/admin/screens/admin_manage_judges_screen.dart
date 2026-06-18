import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import 'admin_add_judges_screen.dart';
import 'admin_judge_detail_screen.dart';

List<Map<String, dynamic>> _hackathonJudgeAssignments(Object? rawAssignments) {
  Map<String, dynamic> withTeamKey(Map assignment, String teamKey) {
    final normalized = Map<String, dynamic>.from(assignment);
    normalized.putIfAbsent("teamId", () => teamKey);
    normalized.putIfAbsent("teamCode", () => teamKey);
    return normalized;
  }

  if (rawAssignments is Map) {
    final normalized = <Map<String, dynamic>>[];

    rawAssignments.forEach((key, value) {
      final teamKey = key.toString();

      if (value is List) {
        for (final assignment in value.whereType<Map>()) {
          normalized.add(withTeamKey(assignment, teamKey));
        }
      } else if (value is Map) {
        normalized.add(withTeamKey(value, teamKey));
      }
    });

    return normalized;
  }

  if (rawAssignments is List) {
    return rawAssignments
        .whereType<Map>()
        .map((assignment) => Map<String, dynamic>.from(assignment))
        .toList();
  }

  return const <Map<String, dynamic>>[];
}

class AdminManageJudgesScreen extends StatefulWidget {
  const AdminManageJudgesScreen({super.key});

  @override
  State<AdminManageJudgesScreen> createState() =>
      _AdminManageJudgesScreenState();
}

class _AdminManageJudgesScreenState extends State<AdminManageJudgesScreen> {
  ////////////////////////////////////////////////////////////
  /// SEARCH
  ////////////////////////////////////////////////////////////

  final TextEditingController searchController = TextEditingController();

  ////////////////////////////////////////////////////////////
  /// FIREBASE JUDGES
  ////////////////////////////////////////////////////////////

  List<Map<String, dynamic>> judges = [];

  bool isLoading = true;

  ////////////////////////////////////////////////////////////
  /// LOAD JUDGES
  ////////////////////////////////////////////////////////////

  Future<void> loadJudges() async {
    try {
      //////////////////////////////////////////////////////////
      /// LOAD JUDGES
      //////////////////////////////////////////////////////////

      final snapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .where("role", isEqualTo: "judge")
              .get();

      //////////////////////////////////////////////////////////
      /// LOAD HACKATHONS
      //////////////////////////////////////////////////////////

      final hackathonSnapshot =
          await FirebaseFirestore.instance.collection("hackathons").get();

      //////////////////////////////////////////////////////////
      /// MAP FOR TEAM COUNT
      //////////////////////////////////////////////////////////

      final Map<String, Set<String>> judgeAssignedTeams = {};
      final Map<String, List<String>> judgeAssignmentLabels = {};

      //////////////////////////////////////////////////////////
      /// LOOP HACKATHONS
      //////////////////////////////////////////////////////////

      for (var hackathon in hackathonSnapshot.docs) {
        final data = hackathon.data();

        final assignments = _hackathonJudgeAssignments(
          data["judgeAssignments"],
        );

        ////////////////////////////////////////////////////////
        /// COUNT ASSIGNED TEAMS
        ////////////////////////////////////////////////////////

        for (var assignment in assignments) {
          final String judgeId = (assignment["judgeId"] ?? "").toString();

          if (judgeId.isEmpty) {
            continue;
          }

          final teamId =
              (assignment["teamId"] ??
                      assignment["teamCode"] ??
                      assignment["teamName"] ??
                      "")
                  .toString();
          final assignmentKey =
              teamId.isEmpty ? "${hackathon.id}-${assignment.hashCode}" : teamId;

          judgeAssignedTeams.putIfAbsent(judgeId, () => <String>{});
          judgeAssignedTeams[judgeId]!.add("${hackathon.id}:$assignmentKey");

          final teamName =
              (assignment["teamName"] ?? assignment["teamCode"] ?? teamId)
                  .toString();
          final hackathonName =
              (assignment["hackathonName"] ?? data["title"] ?? "Hackathon")
                  .toString();
          final label =
              teamName.isEmpty ? hackathonName : "$teamName - $hackathonName";

          judgeAssignmentLabels.putIfAbsent(judgeId, () => <String>[]);
          if (!judgeAssignmentLabels[judgeId]!.contains(label)) {
            judgeAssignmentLabels[judgeId]!.add(label);
          }
        }
      }

      //////////////////////////////////////////////////////////
      /// BUILD JUDGES LIST
      //////////////////////////////////////////////////////////

      judges =
          snapshot.docs.map((doc) {
            final data = doc.data();

            ////////////////////////////////////////////////////////
            /// TEAM COUNT
            ////////////////////////////////////////////////////////

            final int assignedCount = judgeAssignedTeams[doc.id]?.length ?? 0;

            ////////////////////////////////////////////////////////
            /// ASSIGNMENTS
            ////////////////////////////////////////////////////////

            List assignments = data["assignments"] ?? [];

            ////////////////////////////////////////////////////////
            /// STATUS
            ////////////////////////////////////////////////////////

            final String status = assignedCount > 0 ? "Active" : "Available";

            return {
              "id": doc.id,

              "name": data["name"] ?? "",

              "email": data["email"] ?? "",

              "specialization": data["specialty"] ?? "General",

              //////////////////////////////////////////////////////
              /// DYNAMIC TEAM COUNT
              //////////////////////////////////////////////////////
              "teamsAssigned": assignedCount,

              "status": status,

              "assignments": assignments,

              "assignmentLabels": judgeAssignmentLabels[doc.id] ?? [],

              "color": const Color(0xFF5A189A),
            };
          }).toList();
    } catch (e) {
      debugPrint("LOAD JUDGES ERROR: $e");
    }

    isLoading = false;

    setState(() {});
  }

  ////////////////////////////////////////////////////////////
  /// INIT
  ////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    loadJudges();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final filteredJudges =
        judges.where((judge) {
          final query = searchController.text.toLowerCase();

          return judge["name"].toString().toLowerCase().contains(query);
        }).toList();

    ////////////////////////////////////////////////////////////
    /// TOTAL ASSIGNED
    ////////////////////////////////////////////////////////////

    final int totalAssigned = judges.fold(
      0,
      (total, judge) => total + ((judge["teamsAssigned"] as int?) ?? 0),
    );

    ////////////////////////////////////////////////////////////
    /// ACTIVE JUDGES
    ////////////////////////////////////////////////////////////

    final int activeJudges =
        judges.where((judge) => judge["teamsAssigned"] > 0).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      body: SafeArea(
        child: Column(
          children: [
            //////////////////////////////////////////////////////
            /// HEADER
            //////////////////////////////////////////////////////
            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.persakaRed,
                    AppColors.accentPurple,
                    AppColors.darkPurple,
                    AppColors.navy,
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.12)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.persakaRed.withOpacity(0.20),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),

                  bottomRight: Radius.circular(32),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  if (Navigator.canPop(context)) ...[
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.16),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                  //////////////////////////////////////////////////
                  /// TITLE
                  //////////////////////////////////////////////////
                  const Text(
                    "Judges Management",

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 28,

                      fontWeight: FontWeight.bold,

                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 6),

                  //////////////////////////////////////////////////
                  /// SUBTITLE
                  //////////////////////////////////////////////////
                  Text(
                    "${judges.length} examiners registered",

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  //////////////////////////////////////////////////
                  /// STATS
                  //////////////////////////////////////////////////
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "${judges.length}",

                          "Total Judges",
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildStatCard(
                          totalAssigned.toString(),

                          "Assigned",
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildStatCard(
                          activeJudges.toString(),

                          "Active",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //////////////////////////////////////////////////////
            /// SEARCH + ACTIONS
            //////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),

              child: Row(
                children: [
                  //////////////////////////////////////////////////
                  /// SEARCH BAR
                  //////////////////////////////////////////////////
                  Expanded(
                    child: Container(
                      height: 56,

                      decoration: BoxDecoration(
                        color: AppColors.panel,

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(color: AppColors.glassBorder),

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.persakaRed.withOpacity(.10),

                            blurRadius: 10,

                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: TextField(
                        controller: searchController,

                        decoration: InputDecoration(
                          hintText: "Search judges...",

                          hintStyle: const TextStyle(color: AppColors.subtleText),

                          prefixIcon: const Icon(
                            Icons.search,

                            color: AppColors.persakaRed,
                          ),

                          border: InputBorder.none,

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),

                        style: const TextStyle(color: AppColors.textPrimary),

                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  //////////////////////////////////////////////////
                  /// REFRESH
                  //////////////////////////////////////////////////
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });

                      await loadJudges();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Judges list refreshed")),
                      );
                    },
                    behavior: HitTestBehavior.opaque,

                    child: Container(
                      height: 56,

                      width: 56,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.panel.withOpacity(0.90),
                            AppColors.navy.withOpacity(0.88),
                          ],
                        ),

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(color: Colors.white.withOpacity(0.10)),

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.persakaRed.withOpacity(.10),

                            blurRadius: 10,

                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child:
                          isLoading
                              ? const Padding(
                                padding: EdgeInsets.all(14),

                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(
                                Icons.refresh_rounded,

                                color: Color(0xFFFF0A1F),
                              ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  //////////////////////////////////////////////////
                  /// ADD BUTTON
                  //////////////////////////////////////////////////
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const AdminAddJudgesScreen(),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          isLoading = true;
                        });

                        await loadJudges();
                      }
                    },
                    behavior: HitTestBehavior.opaque,

                    child: Container(
                      height: 56,

                      width: 56,

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.persakaRed,
                            AppColors.accentPurple,
                          ],
                        ),

                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.persakaRed.withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.add,

                        color: Colors.white,

                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //////////////////////////////////////////////////////
            /// JUDGES LIST
            //////////////////////////////////////////////////////
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredJudges.isEmpty
                      ? const Center(
                        child: Text(
                          "No judges found",
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),

                        itemCount: filteredJudges.length,

                        itemBuilder: (context, index) {
                          final judge = filteredJudges[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          AdminJudgesDetailScreen(judge: judge),
                                ),
                              ).then((_) async {
                                //////////////////////////////////////////////////
                                /// RELOAD AFTER BACK
                                //////////////////////////////////////////////////

                                setState(() {
                                  isLoading = true;
                                });

                                await loadJudges();
                              });
                            },
                            behavior: HitTestBehavior.opaque,

                            child: Container(
                              margin: const EdgeInsets.only(bottom: 18),

                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: AppColors.panel,

                                borderRadius: BorderRadius.circular(22),

                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.softShadow,

                                    blurRadius: 22,

                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),

                              child: Row(
                                children: [
                                  //////////////////////////////////////////////////
                                  /// AVATAR
                                  //////////////////////////////////////////////////
                                  Container(
                                    width: 58,

                                    height: 58,

                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.persakaRed,

                                          AppColors.accentPurple,
                                        ],
                                      ),

                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.persakaRed
                                              .withOpacity(0.24),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),

                                    alignment: Alignment.center,

                                    child: Text(
                                      _judgeInitials(judge["name"].toString()),

                                      style: const TextStyle(
                                        color: Colors.white,

                                        fontWeight: FontWeight.bold,

                                        fontSize: 18,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  //////////////////////////////////////////////////
                                  /// INFO
                                  //////////////////////////////////////////////////
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          judge["name"],

                                          style: const TextStyle(
                                            color: AppColors.textPrimary,

                                            fontWeight: FontWeight.bold,

                                            fontSize: 16,

                                            fontFamily: 'Poppins',
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        _JudgeAssignmentSummary(
                                          assignedCount:
                                              (judge["teamsAssigned"] as int?) ??
                                              0,
                                          labels: List<String>.from(
                                            judge["assignmentLabels"] ?? [],
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Text(
                                          judge["email"],

                                          style: const TextStyle(
                                            color: AppColors.subtleText,

                                            fontSize: 13,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,

                                            vertical: 6,
                                          ),

                                          decoration: BoxDecoration(
                                            color: AppColors.accentPurple
                                                .withOpacity(0.10),

                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: AppColors.accentPurple
                                                  .withOpacity(0.18),
                                            ),
                                          ),

                                          child: Text(
                                            judge["specialization"],

                                            style: const TextStyle(
                                              color: AppColors.darkPurple,

                                              fontWeight: FontWeight.w600,

                                              fontSize: 11,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        //////////////////////////////////////////////////
                                        /// TEAM ASSIGNED
                                        //////////////////////////////////////////////////
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.groups_rounded,

                                              size: 15,

                                              color: AppColors.persakaRed,
                                            ),

                                            const SizedBox(width: 5),

                                            Text(
                                              "${judge["teamsAssigned"]} teams assigned",

                                              style: TextStyle(
                                                color: AppColors.mutedText,

                                                fontSize: 12,
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            //////////////////////////////////////////////////
                                            /// STATUS
                                            //////////////////////////////////////////////////
                                            Container(
                                              width: 8,

                                              height: 8,

                                              decoration: BoxDecoration(
                                                color:
                                                    judge["teamsAssigned"] > 0
                                                        ? const Color(
                                                          0xFF00C950,
                                                        )
                                                        : AppColors.warning,

                                                shape: BoxShape.circle,
                                              ),
                                            ),

                                            const SizedBox(width: 6),

                                            Text(
                                              judge["status"],

                                              style: TextStyle(
                                                color: AppColors.mutedText,

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
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// STAT CARD
  ////////////////////////////////////////////////////////////

  Widget _buildStatCard(String number, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
      ),

      child: Column(
        children: [
          Text(
            number,

            style: const TextStyle(
              color: AppColors.textPrimary,

              fontWeight: FontWeight.bold,

              fontSize: 24,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,

            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _judgeInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r"\s+"))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return "?";
  }

  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

class _JudgeAssignmentSummary extends StatelessWidget {
  const _JudgeAssignmentSummary({
    required this.assignedCount,
    required this.labels,
  });

  final int assignedCount;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final hasAssignments = assignedCount > 0;
    final preview =
        labels.isEmpty ? "No teams assigned yet" : labels.take(2).join(" / ");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: hasAssignments ? AppColors.purpleTint : AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              hasAssignments
                  ? AppColors.darkPurple.withOpacity(0.14)
                  : AppColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasAssignments
                ? Icons.assignment_turned_in_rounded
                : Icons.assignment_outlined,
            size: 16,
            color: hasAssignments ? AppColors.darkPurple : AppColors.darkGray,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasAssignments
                  ? "$assignedCount assigned - $preview"
                  : "0 assigned - $preview",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    hasAssignments ? AppColors.textPrimary : AppColors.darkGray,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
