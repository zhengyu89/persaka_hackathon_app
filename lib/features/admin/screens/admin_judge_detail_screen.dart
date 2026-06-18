import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Map<String, List<Map<String, dynamic>>> _hackathonJudgeAssignmentMap(
  Object? rawAssignments,
) {
  if (rawAssignments is Map) {
    final normalized = <String, List<Map<String, dynamic>>>{};

    rawAssignments.forEach((key, value) {
      final teamKey = key.toString();

      if (value is List) {
        normalized[teamKey] = value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else if (value is Map) {
        normalized[teamKey] = [Map<String, dynamic>.from(value)];
      }
    });

    return normalized;
  }

  if (rawAssignments is List) {
    final normalized = <String, List<Map<String, dynamic>>>{};

    for (final assignment in rawAssignments.whereType<Map>()) {
      final data = Map<String, dynamic>.from(assignment);
      final teamCode = (data["teamCode"] ?? data["teamId"] ?? "").toString();
      if (teamCode.isNotEmpty) {
        normalized.putIfAbsent(teamCode, () => []).add(data);
      }
    }

    return normalized;
  }

  return const <String, List<Map<String, dynamic>>>{};
}

class AdminJudgesDetailScreen extends StatefulWidget {
  final Map<String, dynamic> judge;

  const AdminJudgesDetailScreen({super.key, required this.judge});

  @override
  State<AdminJudgesDetailScreen> createState() =>
      _AdminJudgesDetailScreenState();
}

class _AdminJudgesDetailScreenState extends State<AdminJudgesDetailScreen> {
  ////////////////////////////////////////////////////////////
  /// VARIABLES
  ////////////////////////////////////////////////////////////

  List<Map<String, dynamic>> hackathons = [];

  bool isLoading = true;

  ////////////////////////////////////////////////////////////
  /// INIT
  ////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    loadHackathons();
  }

  ////////////////////////////////////////////////////////////
  /// LOAD HACKATHONS
  ////////////////////////////////////////////////////////////

  Future<void> loadHackathons() async {
    try {
      final hackathonSnapshot =
          await FirebaseFirestore.instance.collection("hackathons").get();

      List<Map<String, dynamic>> loadedHackathons = [];

      for (var hackathonDoc in hackathonSnapshot.docs) {
        final data = hackathonDoc.data();

        List registeredTeams = data["registeredTeams"] ?? [];
        final judgeAssignments = _hackathonJudgeAssignmentMap(
          data["judgeAssignments"],
        );
        
        // Read judgesPerTeam from hackathon settings
        final judgesPerTeam = 
            (data["judgingRules"]?["judgesPerTeam"] as num?)?.toInt() ?? 1;

        List<Map<String, dynamic>> teams = [];

        for (String teamCode in registeredTeams) {
          final teamDoc =
              await FirebaseFirestore.instance
                  .collection("teams")
                  .doc(teamCode)
                  .get();

          if (teamDoc.exists) {
            final teamData = teamDoc.data()!;

            final assignmentList =
                judgeAssignments[teamDoc.id] ??
                judgeAssignments[(teamData["teamCode"] ?? teamDoc.id)
                    .toString()] ?? [];
            
            final int judgeCount = assignmentList.length;
            final bool hasJudges = judgeCount > 0;
            final bool isFull = judgeCount >= judgesPerTeam;

            teams.add({
              "id": teamDoc.id,
              "name": teamData["teamName"] ?? "",
              "teamCode": teamData["teamCode"] ?? "",
              "judgeAssigned": hasJudges,
              "judgeCount": judgeCount,
              "judgesPerTeam": judgesPerTeam,
              "isFull": isFull,
              "judges": assignmentList,
            });
          }
        }

        loadedHackathons.add({
          "id": hackathonDoc.id,
          "name": data["title"] ?? "Hackathon",
          "judgesPerTeam": judgesPerTeam,
          "teams": teams,
        });
      }

      hackathons = loadedHackathons;
    } catch (e) {
      debugPrint("LOAD HACKATHON ERROR: $e");
    }

    isLoading = false;

    setState(() {});
  }

  ////////////////////////////////////////////////////////////
  /// REMOVE ASSIGNMENT
  ////////////////////////////////////////////////////////////

  Future<void> removeAssignment(int assignmentIndex) async {
    try {
      final assignments = List.from(widget.judge["assignments"] ?? []);

      final assignment = assignments[assignmentIndex];

      ////////////////////////////////////////////////////////
      /// REMOVE HACKATHON ASSIGNMENT
      ////////////////////////////////////////////////////////

      final hackathonRef = FirebaseFirestore.instance
          .collection("hackathons")
          .doc(assignment["hackathonId"]);

      final hackathonDoc = await hackathonRef.get();

      final hackathonData = hackathonDoc.data() ?? {};

      Map<String, List<Map<String, dynamic>>> judgeAssignments =
          _hackathonJudgeAssignmentMap(hackathonData["judgeAssignments"]);

      // Remove this judge from all teams for this hackathon
      judgeAssignments.forEach((teamCode, assignments) {
        final filtered = assignments
            .where((a) =>
                a["judgeId"] != widget.judge["id"] ||
                (a["hackathonId"] ?? assignment["hackathonId"]) !=
                    assignment["hackathonId"])
            .toList();
        judgeAssignments[teamCode] = filtered;
      });
      
      // Remove teams with no judges
      judgeAssignments.removeWhere((_, assignments) => assignments.isEmpty);

      await hackathonRef.update({"judgeAssignments": judgeAssignments});

      ////////////////////////////////////////////////////////
      /// REMOVE USER ASSIGNMENT
      ////////////////////////////////////////////////////////

      assignments.removeAt(assignmentIndex);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.judge["id"])
          .update({"assignments": assignments});

      widget.judge["assignments"] = assignments;

      setState(() {});
    } catch (e) {
      debugPrint("REMOVE ERROR: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  /// EDIT ASSIGNMENT
  ////////////////////////////////////////////////////////////

  void editAssignment(int assignmentIndex) {
    final assignment = widget.judge["assignments"][assignmentIndex];

    List<dynamic> editableTeams = List.from(assignment["teams"]);

    final currentHackathon = hackathons.firstWhere(
      (h) => h["id"] == assignment["hackathonId"],

      orElse: () => {},
    );

    final List availableTeams = currentHackathon["teams"] ?? [];

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Edit Assignment",

                          style: TextStyle(
                            fontSize: 24,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      children: [
                        ...availableTeams.map((team) {
                          final bool alreadySelected = editableTeams.any(
                            (e) => e["teamId"] == team["id"],
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),

                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7FA),

                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        team["name"],

                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        team["teamCode"],

                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Checkbox(
                                  value: alreadySelected,

                                  onChanged: (_) {
                                    setModalState(() {
                                      if (alreadySelected) {
                                        editableTeams.removeWhere(
                                          (e) => e["teamId"] == team["id"],
                                        );
                                      } else {
                                        editableTeams.add({
                                          "teamId": team["id"],

                                          "teamName": team["name"],
                                        });
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    height: 56,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0A1F),
                      ),

                      onPressed: () async {
                        //////////////////////////////////////////////////////
                        /// REMOVE OLD ASSIGNMENTS
                        //////////////////////////////////////////////////////

                        final hackathonRef = FirebaseFirestore.instance
                            .collection("hackathons")
                            .doc(assignment["hackathonId"]);

                        final hackathonDoc = await hackathonRef.get();

                        final hackathonData = hackathonDoc.data() ?? {};

                        Map<String, List<Map<String, dynamic>>> judgeAssignments =
                            _hackathonJudgeAssignmentMap(
                              hackathonData["judgeAssignments"],
                            );

                        // Remove this judge from all teams
                        judgeAssignments.forEach((teamCode, assignments) {
                          final filtered = assignments
                              .where((a) => a["judgeId"] != widget.judge["id"])
                              .toList();
                          judgeAssignments[teamCode] = filtered;
                        });
                        
                        judgeAssignments.removeWhere((_, assignments) => assignments.isEmpty);

                        //////////////////////////////////////////////////////
                        /// ADD NEW TEAM ASSIGNMENT
                        //////////////////////////////////////////////////////

                        for (var team in editableTeams) {
                          final teamCode = team["teamId"].toString();
                          
                          // Initialize or get existing judges for this team
                          judgeAssignments.putIfAbsent(teamCode, () => []);

                          judgeAssignments[teamCode]!.add({
                            "judgeId": widget.judge["id"],
                            "judgeName": widget.judge["name"],
                            "teamId": teamCode,
                            "teamName": team["teamName"],
                            "hackathonId": assignment["hackathonId"],
                            "hackathonName": assignment["hackathon"],
                            "assignedAt": Timestamp.now(),
                          });
                        }

                        //////////////////////////////////////////////////////
                        /// UPDATE HACKATHON
                        //////////////////////////////////////////////////////

                        await hackathonRef.update({
                          "judgeAssignments": judgeAssignments,
                        });

                        //////////////////////////////////////////////////////
                        /// UPDATE USER
                        //////////////////////////////////////////////////////

                        widget.judge["assignments"][assignmentIndex]["teams"] =
                            editableTeams;

                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.judge["id"])
                            .update({
                              "assignments": widget.judge["assignments"],
                            });

                        Navigator.pop(context);

                        await loadHackathons();

                        setState(() {});
                      },

                      child: const Text(
                        "Save Changes",

                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////
  /// ASSIGN HACKATHON
  ////////////////////////////////////////////////////////////

  void showAssignHackathonSheet() {
    String? selectedHackathonId;
    String? selectedHackathonName;

    List<Map<String, dynamic>> selectedTeams = [];

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * .88,

              padding: const EdgeInsets.all(20),

              decoration: const BoxDecoration(
                color: Color(0xFFF7F7FA),

                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Assign Judge",

                          style: TextStyle(
                            fontSize: 26,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      children: [
                        ...hackathons.map((hackathon) {
                          final bool isSelected =
                              selectedHackathonId == hackathon["id"];

                          final List teams = hackathon["teams"] ?? [];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(24),

                              border: Border.all(
                                color:
                                    isSelected
                                        ? const Color(0xFFFF0A1F)
                                        : Colors.transparent,

                                width: 2,
                              ),
                            ),

                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        selectedHackathonId = null;

                                        selectedHackathonName = null;

                                        selectedTeams = [];
                                      } else {
                                        selectedHackathonId = hackathon["id"];

                                        selectedHackathonName =
                                            hackathon["name"];

                                        selectedTeams = [];
                                      }
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,

                                  child: Padding(
                                    padding: const EdgeInsets.all(18),

                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,

                                          height: 50,

                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F0FF),

                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),

                                          child: const Icon(
                                            Icons.emoji_events_outlined,

                                            color: Color(0xFF5A189A),
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              Text(
                                                hackathon["name"],

                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,

                                                  fontSize: 16,
                                                ),
                                              ),

                                              const SizedBox(height: 6),

                                              Text(
                                                "${teams.length} Teams",

                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      18,
                                      0,
                                      18,
                                      18,
                                    ),

                                    child: Column(
                                      children: [
                                        const Divider(),

                                        ...teams.map<Widget>((team) {
                                          final bool alreadySelected =
                                              selectedTeams.any(
                                                (e) =>
                                                    e["teamId"] == team["id"],
                                              );

                                          final int judgeCount = 
                                              team["judgeCount"] as int? ?? 0;
                                          final int judgesPerTeam = 
                                              team["judgesPerTeam"] as int? ?? 1;
                                          final bool isFull = judgeCount >= judgesPerTeam;

                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),

                                            padding: const EdgeInsets.all(14),

                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8F8FC),

                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),

                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,

                                                    children: [
                                                      Text(
                                                        team["name"],

                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 6),

                                                      Text(
                                                        team["teamCode"],

                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 10,
                                                      ),

                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,

                                                                  vertical: 5,
                                                                ),

                                                            decoration: BoxDecoration(
                                                              color:
                                                                  isFull
                                                                      ? const Color(
                                                                        0xFFFFEBEE,
                                                                      )
                                                                      : judgeCount > 0
                                                                        ? const Color(
                                                                          0xFFDCFCE7,
                                                                        )
                                                                        : const Color(
                                                                          0xFFEDE9FE,
                                                                        ),

                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                            ),

                                                            child: Text(
                                                              isFull
                                                                  ? "Max judges reached"
                                                                  : judgeCount > 0
                                                                    ? "$judgeCount/$judgesPerTeam"
                                                                    : "Available",

                                                              style: TextStyle(
                                                                color:
                                                                    isFull
                                                                        ? const Color(
                                                                          0xFFC62828,
                                                                        )
                                                                        : judgeCount > 0
                                                                          ? const Color(
                                                                            0xFF166534,
                                                                          )
                                                                          : const Color(
                                                                            0xFFFF0A1F,
                                                                          ),

                                                                fontSize: 11,

                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                //////////////////////////////////////////////////
                                                /// CHECKBOX
                                                //////////////////////////////////////////////////
                                                Checkbox(
                                                  value: alreadySelected,

                                                  activeColor: const Color(
                                                    0xFFFF0A1F,
                                                  ),

                                                  onChanged: (_) {
                                                    if (isFull && !alreadySelected) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Maximum judges reached for this team",
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    setModalState(() {
                                                      if (alreadySelected) {
                                                        selectedTeams
                                                            .removeWhere(
                                                              (e) =>
                                                                  e["teamId"] ==
                                                                  team["id"],
                                                            );
                                                      } else {
                                                        selectedTeams.add({
                                                          "teamId": team["id"],
                                                          "teamName": team["name"],
                                                        });
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,

                    height: 56,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0A1F),
                      ),

                      onPressed: () async {
                        if (selectedHackathonId == null) return;

                        if (selectedTeams.isEmpty) return;

                        //////////////////////////////////////////////////////
                        /// VALIDATE judgesPerTeam LIMIT
                        //////////////////////////////////////////////////////

                        final hackathonRef = FirebaseFirestore.instance
                            .collection("hackathons")
                            .doc(selectedHackathonId);

                        final hackathonDoc = await hackathonRef.get();

                        final hackathonData = hackathonDoc.data() ?? {};
                        final judgesPerTeam = 
                            (hackathonData["judgingRules"]?["judgesPerTeam"] as num?)?.toInt() ?? 1;

                        Map<String, List<Map<String, dynamic>>> judgeAssignments =
                            _hackathonJudgeAssignmentMap(
                              hackathonData["judgeAssignments"],
                            );

                        // Check if any team would exceed the limit
                        for (var team in selectedTeams) {
                          final teamCode = team["teamId"].toString();
                          final currentJudges = judgeAssignments[teamCode] ?? [];
                          final countWithoutThisJudge = currentJudges
                              .where((a) => a["judgeId"] != widget.judge["id"])
                              .length;
                          
                          if (countWithoutThisJudge >= judgesPerTeam) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Team ${team["teamName"]} has reached the maximum of $judgesPerTeam judges',
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        //////////////////////////////////////////////////////
                        /// UPDATE HACKATHON JUDGE ASSIGNMENTS
                        //////////////////////////////////////////////////////

                        // Remove this judge from all teams
                        judgeAssignments.forEach((teamCode, assignments) {
                          final filtered = assignments
                              .where((a) => a["judgeId"] != widget.judge["id"])
                              .toList();
                          judgeAssignments[teamCode] = filtered;
                        });
                        
                        judgeAssignments.removeWhere((_, assignments) => assignments.isEmpty);

                        // Add this judge to selected teams
                        for (var team in selectedTeams) {
                          final teamCode = team["teamId"].toString();
                          judgeAssignments.putIfAbsent(teamCode, () => []);

                          judgeAssignments[teamCode]!.add({
                            "judgeId": widget.judge["id"],
                            "judgeName": widget.judge["name"],
                            "teamId": teamCode,
                            "teamName": team["teamName"],
                            "hackathonId": selectedHackathonId,
                            "hackathonName": selectedHackathonName,
                            "assignedAt": Timestamp.now(),
                          });
                        }

                        await hackathonRef.update({
                          "judgeAssignments": judgeAssignments,
                        });

                        //////////////////////////////////////////////////////
                        /// UPDATE USER
                        //////////////////////////////////////////////////////

                        List assignments = List.from(
                          widget.judge["assignments"] ?? [],
                        );

                        assignments.add({
                          "hackathon": selectedHackathonName,

                          "hackathonId": selectedHackathonId,

                          "teams": selectedTeams,
                        });

                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.judge["id"])
                            .update({"assignments": assignments});

                        widget.judge["assignments"] = assignments;

                        Navigator.pop(context);

                        await loadHackathons();

                        setState(() {});
                      },

                      child: const Text(
                        "Assign Judge",

                        style: TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final judge = widget.judge;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF0A1F),

        onPressed: showAssignHackathonSheet,

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          "Add Hackathon",

          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),

        child: Column(
          children: [
            Container(
              width: double.infinity,

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF0A1F),

                    Color(0xFF5A189A),

                    Color(0xFF3D0075),
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
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            icon: const Icon(
                              Icons.arrow_back,

                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: 100,

                        height: 100,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(30),
                        ),

                        alignment: Alignment.center,

                        child: Text(
                          judge["name"]
                              .split(" ")
                              .take(2)
                              .map((e) => e[0])
                              .join(),

                          style: const TextStyle(
                            color: Color(0xFFFF0A1F),

                            fontSize: 30,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        judge["name"],

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 28,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        judge["email"],

                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Assigned Hackathons",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 18),

                  ...(judge["assignments"] ?? []).asMap().entries.map((entry) {
                    final int assignmentIndex = entry.key;

                    final assignment = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      assignment["hackathon"],

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,

                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "${assignment["teams"].length} Teams Assigned",
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  editAssignment(assignmentIndex);
                                },

                                icon: const Icon(
                                  Icons.edit,

                                  color: Color(0xFFFF0A1F),
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  removeAssignment(assignmentIndex);
                                },

                                icon: const Icon(
                                  Icons.delete_outline,

                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Wrap(
                            spacing: 10,

                            runSpacing: 10,

                            children:
                                (assignment["teams"] as List).map<Widget>((
                                  team,
                                ) {
                                  final String teamName = team["teamName"];

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,

                                      vertical: 8,
                                    ),

                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F0FF),

                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Text(
                                      teamName,

                                      style: const TextStyle(
                                        color: Color(0xFF3D0075),

                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
