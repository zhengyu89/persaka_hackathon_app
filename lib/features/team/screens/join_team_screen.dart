import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'join_team_success_screen.dart';

class JoinTeamScreen extends StatefulWidget {
  const JoinTeamScreen({super.key});

  @override
  State<JoinTeamScreen> createState() =>
      _JoinTeamScreenState();
}

class _JoinTeamScreenState
    extends State<JoinTeamScreen> {

  final TextEditingController
      teamCodeController =
      TextEditingController();

  bool isLoading = false;

  ////////////////////////////////////////////////////////////
  /// JOIN TEAM
  ////////////////////////////////////////////////////////////

  Future<void> joinTeam() async {

    if (teamCodeController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Please enter team code'),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      ////////////////////////////////////////////////////////
      /// CURRENT USER
      ////////////////////////////////////////////////////////

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      ////////////////////////////////////////////////////////
      /// TEAM CODE
      ////////////////////////////////////////////////////////

      final teamCode =
          teamCodeController.text
              .trim()
              .toUpperCase();

      ////////////////////////////////////////////////////////
      /// FIND TEAM
      ////////////////////////////////////////////////////////

      final doc = await FirebaseFirestore
          .instance
          .collection('teams')
          .doc(teamCode)
          .get();

      final teamData = doc.data() ?? {};
      final teamName =
          teamData['teamName'] ?? 'Team';
      final members = List<String>.from(
        teamData['members'] ?? const [],
      );

      if (members.contains(user.email)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('You are already in this team.'),
          ),
        );
        return;
      }

      ////////////////////////////////////////////////////////
      /// INVALID CODE
      ////////////////////////////////////////////////////////

      if (!doc.exists) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('Invalid Team Code'),
          ),
        );

        return;
      }

      ////////////////////////////////////////////////////////
      /// ADD MEMBER
      ////////////////////////////////////////////////////////

      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamCode)
          .update({

        'members':
            FieldValue.arrayUnion([
          user.email,
        ]),
      });

      ////////////////////////////////////////////////////////
      /// SUCCESS PAGE
      ////////////////////////////////////////////////////////

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              JoinTeamSuccessScreen(
                teamName: teamName,
                teamCode: teamCode,
              ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9FAFB),

      body: SingleChildScrollView(
        child: Column(
          children: [

            //////////////////////////////////////////////////////
            /// HEADER
            //////////////////////////////////////////////////////

            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4F39F6),
                    Color(0xFF9810FA),
                    Color(0xFF432DD7),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Join a Team",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Enter the team code shared by your leader",
                    style: TextStyle(
                      color: Color(0xFFD6D6FF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            //////////////////////////////////////////////////////
            /// BODY
            //////////////////////////////////////////////////////

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  //////////////////////////////////////////////////
                  /// TEAM CODE
                  //////////////////////////////////////////////////

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        const Text(
                          "Team Code",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller:
                              teamCodeController,
                          textCapitalization:
                              TextCapitalization
                                  .characters,
                          decoration:
                              InputDecoration(
                            hintText:
                                "HACK2026",
                            filled: true,
                            fillColor:
                                const Color(
                                    0xFFF9FAFB),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          14),
                              borderSide:
                                  BorderSide
                                      .none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  //////////////////////////////////////////////////
                  /// TIP
                  //////////////////////////////////////////////////

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFEEF2FF),
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                    child: const Text(
                      "💡 Ask your leader for the team code.",
                      style: TextStyle(
                        color: Color(0xFF372AAC),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  //////////////////////////////////////////////////
                  /// BUTTON
                  //////////////////////////////////////////////////

                  GestureDetector(
                    onTap:
                        isLoading ? null : joinTeam,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF4F39F6),
                            Color(0xFF9810FA),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                                16),
                      ),
                      child: Center(
                        child: isLoading

                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth: 2,
                                ),
                              )

                            : const Text(
                                "Join Team",
                                style: TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
