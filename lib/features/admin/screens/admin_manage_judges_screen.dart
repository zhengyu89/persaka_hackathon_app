import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_add_judges_screen.dart';
import 'admin_judge_detail_screen.dart';

class AdminManageJudgesScreen extends StatefulWidget {
  const AdminManageJudgesScreen({super.key});

  @override
  State<AdminManageJudgesScreen> createState() =>
      _AdminManageJudgesScreenState();
}

class _AdminManageJudgesScreenState
    extends State<AdminManageJudgesScreen> {

  ////////////////////////////////////////////////////////////
  /// SEARCH
  ////////////////////////////////////////////////////////////

  final TextEditingController
      searchController =
      TextEditingController();

  ////////////////////////////////////////////////////////////
  /// FIREBASE JUDGES
  ////////////////////////////////////////////////////////////

  List<Map<String, dynamic>>
      judges = [];

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
          await FirebaseFirestore
              .instance
              .collection("users")
              .where(
                "role",
                isEqualTo: "judge",
              )
              .get();

      //////////////////////////////////////////////////////////
      /// LOAD HACKATHONS
      //////////////////////////////////////////////////////////

      final hackathonSnapshot =
          await FirebaseFirestore
              .instance
              .collection("hackathons")
              .get();

      //////////////////////////////////////////////////////////
      /// MAP FOR TEAM COUNT
      //////////////////////////////////////////////////////////

      Map<String, int>
          judgeTeamCounts = {};

      //////////////////////////////////////////////////////////
      /// LOOP HACKATHONS
      //////////////////////////////////////////////////////////

      for (var hackathon
          in hackathonSnapshot.docs) {

        final data =
            hackathon.data();

        List assignments =
            data["judgeAssignments"] ?? [];

        ////////////////////////////////////////////////////////
        /// COUNT ASSIGNED TEAMS
        ////////////////////////////////////////////////////////

        for (var assignment
            in assignments) {

          final String judgeId =
              assignment["judgeId"];

          judgeTeamCounts[judgeId] =
              (judgeTeamCounts[judgeId] ??
                      0) +
                  1;
        }
      }

      //////////////////////////////////////////////////////////
      /// BUILD JUDGES LIST
      //////////////////////////////////////////////////////////

      judges =
          snapshot.docs.map((doc) {

        final data =
            doc.data();

        ////////////////////////////////////////////////////////
        /// TEAM COUNT
        ////////////////////////////////////////////////////////

        final int assignedCount =
            judgeTeamCounts[doc.id] ??
                0;

        ////////////////////////////////////////////////////////
        /// ASSIGNMENTS
        ////////////////////////////////////////////////////////

        List assignments =
            data["assignments"] ??
                [];

        ////////////////////////////////////////////////////////
        /// STATUS
        ////////////////////////////////////////////////////////

        final String status =
            assignedCount > 0
                ? "Active"
                : "Available";

        return {

          "id":
              doc.id,

          "name":
              data["name"] ?? "",

          "email":
              data["email"] ?? "",

          "specialization":
              data["specialty"] ??
                  "General",

          //////////////////////////////////////////////////////
          /// DYNAMIC TEAM COUNT
          //////////////////////////////////////////////////////

          "teamsAssigned":
              assignedCount,

          "status":
              status,

          "assignments":
              assignments,

          "color":
              const Color(
                  0xFF7C3AED),
        };

      }).toList();

    } catch (e) {

      debugPrint(
        "LOAD JUDGES ERROR: $e",
      );
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

  ////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(
      BuildContext context) {

    final filteredJudges =
        judges.where(
      (
        judge,
      ) {

        final query =
            searchController
                .text
                .toLowerCase();

        return judge["name"]
            .toString()
            .toLowerCase()
            .contains(query);
      },
    ).toList();

    ////////////////////////////////////////////////////////////
    /// TOTAL ASSIGNED
    ////////////////////////////////////////////////////////////

    final int totalAssigned =
        judges.fold(
      0,
      (
        total,
        judge,
      ) =>
          total +
          ((judge["teamsAssigned"]
                  as int?) ??
              0),
    );

    ////////////////////////////////////////////////////////////
    /// ACTIVE JUDGES
    ////////////////////////////////////////////////////////////

    final int activeJudges =
        judges.where(
      (judge) =>
          judge["teamsAssigned"] >
          0,
    ).length;

    return Scaffold(

      backgroundColor:
          const Color(
              0xFFF9FAFB),

      body: SafeArea(

        child: Column(

          children: [

            //////////////////////////////////////////////////////
            /// HEADER
            //////////////////////////////////////////////////////

            Container(

              width:
                  double.infinity,

              padding:
                  const EdgeInsets
                      .fromLTRB(
                24,
                24,
                24,
                28,
              ),

              decoration:
                  const BoxDecoration(

                gradient:
                    LinearGradient(
                  colors: [

                    Color(
                        0xFFFE9A00),

                    Color(
                        0xFFFF6900),

                    Color(
                        0xFFE17100),
                  ],
                ),

                borderRadius:
                    BorderRadius.only(

                  bottomLeft:
                      Radius.circular(
                          32),

                  bottomRight:
                      Radius.circular(
                          32),
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  //////////////////////////////////////////////////
                  /// TITLE
                  //////////////////////////////////////////////////

                  const Text(

                    "Judges Management",

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontSize:
                          28,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 6),

                  //////////////////////////////////////////////////
                  /// SUBTITLE
                  //////////////////////////////////////////////////

                  Text(

                    "${judges.length} examiners registered",

                    style:
                        const TextStyle(

                      color:
                          Color(
                              0xFFFFF3C6),

                      fontSize:
                          14,
                    ),
                  ),

                  const SizedBox(
                      height: 24),

                  //////////////////////////////////////////////////
                  /// STATS
                  //////////////////////////////////////////////////

                  Row(

                    children: [

                      Expanded(
                        child:
                            _buildStatCard(

                          "${judges.length}",

                          "Total Judges",
                        ),
                      ),

                      const SizedBox(
                          width:
                              12),

                      Expanded(
                        child:
                            _buildStatCard(

                          totalAssigned
                              .toString(),

                          "Assigned",
                        ),
                      ),

                      const SizedBox(
                          width:
                              12),

                      Expanded(
                        child:
                            _buildStatCard(

                          activeJudges
                              .toString(),

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

              padding:
                  const EdgeInsets
                      .fromLTRB(
                16,
                18,
                16,
                8,
              ),

              child: Row(

                children: [

                  //////////////////////////////////////////////////
                  /// SEARCH BAR
                  //////////////////////////////////////////////////

                  Expanded(

                    child:
                        Container(

                      height:
                          56,

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                                18),

                        boxShadow: [

                          BoxShadow(

                            color: Colors
                                .black
                                .withOpacity(
                                    .04),

                            blurRadius:
                                10,

                            offset:
                                const Offset(
                                    0,
                                    4),
                          ),
                        ],
                      ),

                      child:
                          TextField(

                        controller:
                            searchController,

                        decoration:
                            InputDecoration(

                          hintText:
                              "Search judges...",

                          hintStyle:
                              TextStyle(

                            color: Colors
                                .grey
                                .shade500,
                          ),

                          prefixIcon:
                              Icon(

                            Icons.search,

                            color: Colors
                                .grey
                                .shade600,
                          ),

                          border:
                              InputBorder
                                  .none,

                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical:
                                16,
                          ),
                        ),

                        onChanged:
                            (_) {

                          setState(() {});
                        },
                      ),
                    ),
                  ),

                  const SizedBox(
                      width:
                          12),

                  //////////////////////////////////////////////////
                  /// REFRESH
                  //////////////////////////////////////////////////

                  GestureDetector(

                    onTap:
                        () async {

                      setState(() {

                        isLoading =
                            true;
                      });

                      await loadJudges();

                      if (!mounted)
                        return;

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(

                        const SnackBar(

                          content:
                              Text(
                            "Judges list refreshed",
                          ),
                        ),
                      );
                    },

                    child:
                        Container(

                      height:
                          56,

                      width:
                          56,

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                                18),

                        boxShadow: [

                          BoxShadow(

                            color: Colors
                                .black
                                .withOpacity(
                                    .04),

                            blurRadius:
                                10,

                            offset:
                                const Offset(
                                    0,
                                    4),
                          ),
                        ],
                      ),

                      child:
                          isLoading

                              ? const Padding(

                                  padding:
                                      EdgeInsets.all(
                                          14),

                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )

                              : const Icon(

                                  Icons
                                      .refresh_rounded,

                                  color:
                                      Color(
                                          0xFF5B3FFF),
                                ),
                    ),
                  ),

                  const SizedBox(
                      width:
                          12),

                  //////////////////////////////////////////////////
                  /// ADD BUTTON
                  //////////////////////////////////////////////////

                  GestureDetector(

                    onTap:
                        () async {

                      final result =
                          await Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (_) =>
                                  const AdminAddJudgesScreen(),
                        ),
                      );

                      if (result ==
                          true) {

                        setState(() {

                          isLoading =
                              true;
                        });

                        await loadJudges();
                      }
                    },

                    child:
                        Container(

                      height:
                          56,

                      width:
                          56,

                      decoration:
                          BoxDecoration(

                        gradient:
                            const LinearGradient(
                          colors: [

                            Color(
                                0xFF5B3FFF),

                            Color(
                                0xFF7C3AED),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),

                      child:
                          const Icon(

                        Icons.add,

                        color:
                            Colors.white,

                        size:
                            26,
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

                      ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )

                      : filteredJudges
                              .isEmpty

                          ? const Center(
                              child:
                                  Text(
                                "No judges found",
                              ),
                            )

                          : ListView.builder(

                              padding:
                                  const EdgeInsets.all(
                                      16),

                              itemCount:
                                  filteredJudges
                                      .length,

                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {

                                final judge =
                                    filteredJudges[
                                        index];

                                return GestureDetector(

                                  onTap:
                                      () {

                                    Navigator.push(

                                      context,

                                      MaterialPageRoute(

                                        builder:
                                            (_) =>
                                                AdminJudgesDetailScreen(

                                          judge:
                                              judge,
                                        ),
                                      ),
                                    ).then(
                                      (_) async {

                                        //////////////////////////////////////////////////
                                        /// RELOAD AFTER BACK
                                        //////////////////////////////////////////////////

                                        setState(() {

                                          isLoading =
                                              true;
                                        });

                                        await loadJudges();
                                      },
                                    );
                                  },

                                  child:
                                      Container(

                                    margin:
                                        const EdgeInsets.only(
                                      bottom:
                                          18,
                                    ),

                                    padding:
                                        const EdgeInsets.all(
                                            18),

                                    decoration:
                                        BoxDecoration(

                                      color:
                                          Colors.white,

                                      borderRadius:
                                          BorderRadius.circular(
                                              24),

                                      boxShadow: [

                                        BoxShadow(

                                          color: Colors
                                              .black
                                              .withOpacity(
                                                  .05),

                                          blurRadius:
                                              10,

                                          offset:
                                              const Offset(
                                                  0,
                                                  4),
                                        ),
                                      ],
                                    ),

                                    child:
                                        Row(

                                      children: [

                                        //////////////////////////////////////////////////
                                        /// AVATAR
                                        //////////////////////////////////////////////////

                                        Container(

                                          width:
                                              58,

                                          height:
                                              58,

                                          decoration:
                                              BoxDecoration(

                                            gradient:
                                                const LinearGradient(
                                              colors: [

                                                Color(
                                                    0xFF5B3FFF),

                                                Color(
                                                    0xFF7C3AED),
                                              ],
                                            ),

                                            borderRadius:
                                                BorderRadius.circular(
                                                    18),
                                          ),

                                          alignment:
                                              Alignment.center,

                                          child:
                                              Text(

                                            judge["name"]
                                                .split(
                                                    " ")
                                                .take(
                                                    2)
                                                .map(
                                                    (
                                                      e,
                                                    ) =>
                                                        e[0])
                                                .join(),

                                            style:
                                                const TextStyle(

                                              color:
                                                  Colors.white,

                                              fontWeight:
                                                  FontWeight.bold,

                                              fontSize:
                                                  18,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            width:
                                                16),

                                        //////////////////////////////////////////////////
                                        /// INFO
                                        //////////////////////////////////////////////////

                                        Expanded(

                                          child:
                                              Column(

                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,

                                            children: [

                                              Text(

                                                judge[
                                                    "name"],

                                                style:
                                                    const TextStyle(

                                                  fontWeight:
                                                      FontWeight.bold,

                                                  fontSize:
                                                      16,
                                                ),
                                              ),

                                              const SizedBox(
                                                  height:
                                                      6),

                                              Text(

                                                judge[
                                                    "email"],

                                                style:
                                                    TextStyle(

                                                  color: Colors
                                                      .grey
                                                      .shade600,

                                                  fontSize:
                                                      13,
                                                ),
                                              ),

                                              const SizedBox(
                                                  height:
                                                      8),

                                              Container(

                                                padding:
                                                    const EdgeInsets.symmetric(

                                                  horizontal:
                                                      10,

                                                  vertical:
                                                      6,
                                                ),

                                                decoration:
                                                    BoxDecoration(

                                                  color:
                                                      const Color(
                                                          0xFFF3F0FF),

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),

                                                child:
                                                    Text(

                                                  judge[
                                                      "specialization"],

                                                  style:
                                                      const TextStyle(

                                                    color:
                                                        Color(
                                                            0xFF7C3AED),

                                                    fontWeight:
                                                        FontWeight.w600,

                                                    fontSize:
                                                        11,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(
                                                  height:
                                                      12),

                                              //////////////////////////////////////////////////
                                              /// TEAM ASSIGNED
                                              //////////////////////////////////////////////////

                                              Row(

                                                children: [

                                                  Icon(

                                                    Icons
                                                        .groups_rounded,

                                                    size:
                                                        15,

                                                    color: Colors
                                                        .grey
                                                        .shade600,
                                                  ),

                                                  const SizedBox(
                                                      width:
                                                          5),

                                                  Text(

                                                    "${judge["teamsAssigned"]} teams assigned",

                                                    style:
                                                        TextStyle(

                                                      color: Colors
                                                          .grey
                                                          .shade700,

                                                      fontSize:
                                                          12,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      width:
                                                          12),

                                                  //////////////////////////////////////////////////
                                                  /// STATUS
                                                  //////////////////////////////////////////////////

                                                  Container(

                                                    width:
                                                        8,

                                                    height:
                                                        8,

                                                    decoration:
                                                        BoxDecoration(

                                                      color:
                                                          judge["teamsAssigned"] >
                                                                  0

                                                              ? const Color(
                                                                  0xFF00C950)

                                                              : Colors.orange,

                                                      shape:
                                                          BoxShape.circle,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      width:
                                                          6),

                                                  Text(

                                                    judge[
                                                        "status"],

                                                    style:
                                                        TextStyle(

                                                      color: Colors
                                                          .grey
                                                          .shade700,

                                                      fontSize:
                                                          12,
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

  Widget _buildStatCard(
    String number,
    String title,
  ) {

    return Container(

      padding:
          const EdgeInsets
              .symmetric(
        vertical:
            16,
      ),

      decoration:
          BoxDecoration(

        color: Colors.white
            .withOpacity(
                .18),

        borderRadius:
            BorderRadius.circular(
                18),
      ),

      child: Column(

        children: [

          Text(

            number,

            style:
                const TextStyle(

              color:
                  Colors.white,

              fontWeight:
                  FontWeight.bold,

              fontSize:
                  24,
            ),
          ),

          const SizedBox(
              height:
                  6),

          Text(

            title,

            style:
                const TextStyle(

              color:
                  Color(
                      0xFFFFF3C6),

              fontSize:
                  12,
            ),
          ),
        ],
      ),
    );
  }
}