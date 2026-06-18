// create_team_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'create_team_success_screen.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() =>
      _CreateTeamScreenState();
}

class _CreateTeamScreenState
    extends State<CreateTeamScreen> {

  ////////////////////////////////////////////////////////////
  /// CONTROLLERS
  ////////////////////////////////////////////////////////////

  final TextEditingController
      teamNameController =
      TextEditingController();

  final TextEditingController
      teamDescriptionController =
      TextEditingController();

  ////////////////////////////////////////////////////////////
  /// LOADING
  ////////////////////////////////////////////////////////////

  bool isLoading = false;

  ////////////////////////////////////////////////////////////
  /// CREATE TEAM FUNCTION
  ////////////////////////////////////////////////////////////

  Future<void> createTeam() async {

    //////////////////////////////////////////////////////////
    /// VALIDATION
    //////////////////////////////////////////////////////////

    if (teamNameController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Please enter team name'),
        ),
      );

      return;
    }

    //////////////////////////////////////////////////////////
    /// START LOADING
    //////////////////////////////////////////////////////////

    setState(() {
      isLoading = true;
    });

    try {

      ////////////////////////////////////////////////////////
      /// CURRENT USER
      ////////////////////////////////////////////////////////

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      ////////////////////////////////////////////////////////
      /// GENERATE TEAM CODE
      ////////////////////////////////////////////////////////

      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

      final random = Random();

      final teamCode = List.generate(
        8,
        (index) =>
            chars[random.nextInt(chars.length)],
      ).join();

      ////////////////////////////////////////////////////////
      /// SAVE TEAM TO FIRESTORE
      ////////////////////////////////////////////////////////

      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamCode)
          .set({

        //////////////////////////////////////////////////////
        /// TEAM INFO
        //////////////////////////////////////////////////////

        'teamName':
            teamNameController.text.trim(),

        'teamDescription':
            teamDescriptionController.text
                .trim(),

        'teamCode': teamCode,

        //////////////////////////////////////////////////////
        /// LEADER
        //////////////////////////////////////////////////////

        'leader': user.email,

        //////////////////////////////////////////////////////
        /// MEMBERS
        //////////////////////////////////////////////////////

        'members': [
          user.email,
        ],

        //////////////////////////////////////////////////////
        /// CREATED DATE
        //////////////////////////////////////////////////////

        'createdAt': Timestamp.now(),
      });

      ////////////////////////////////////////////////////////
      /// SUCCESS PAGE
      ////////////////////////////////////////////////////////

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CreateTeamSuccessScreen(
                teamName:
                    teamNameController.text.trim(),
                teamCode: teamCode,
              ),
        ),
      );

    } catch (e) {

      ////////////////////////////////////////////////////////
      /// ERROR
      ////////////////////////////////////////////////////////

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      ////////////////////////////////////////////////////////
      /// STOP LOADING
      ////////////////////////////////////////////////////////

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
                    Color(0xFFFF0A1F),
                    Color(0xFF5A189A),
                    Color(0xFF3D0075),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(28),
                  bottomRight:
                      Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  //////////////////////////////////////////////////
                  /// BACK BUTTON
                  //////////////////////////////////////////////////

                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: const Icon(
                      Icons
                          .arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  //////////////////////////////////////////////////
                  /// TITLE
                  //////////////////////////////////////////////////

                  const Text(
                    "Create Your Team",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  //////////////////////////////////////////////////
                  /// SUBTITLE
                  //////////////////////////////////////////////////

                  const Text(
                    "Start a new team and invite members",
                    style: TextStyle(
                      color:
                          Color(0xFFD6D6FF),
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
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                children: [

                  //////////////////////////////////////////////////
                  /// TEAM NAME
                  //////////////////////////////////////////////////

                  _inputCard(
                    title: "Team Name *",
                    child: TextField(
                      controller:
                          teamNameController,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Code Ninjas",

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

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //////////////////////////////////////////////////
                  /// DESCRIPTION
                  //////////////////////////////////////////////////

                  _inputCard(
                    title:
                        "Team Description (Optional)",
                    child: TextField(
                      controller:
                          teamDescriptionController,

                      maxLines: 4,

                      decoration:
                          InputDecoration(
                        hintText:
                            "Tell us about your team...",

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

                        contentPadding:
                            const EdgeInsets
                                .all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //////////////////////////////////////////////////
                  /// NOTE CARD
                  //////////////////////////////////////////////////

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(
                            18),
                    decoration: BoxDecoration(
                      color:
                          const Color(
                              0xFFEEF2FF),

                      borderRadius:
                          BorderRadius
                              .circular(16),

                      border: Border.all(
                        color:
                            const Color(
                                0xFFE0E7FF),
                      ),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        children: [

                          //////////////////////////////////////////////////
                          /// NOTE TITLE
                          //////////////////////////////////////////////////

                          TextSpan(
                            text: '💡 Note: ',

                            style: TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,

                              color:
                                  Color(
                                      0xFF372AAC),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          /// NOTE TEXT
                          //////////////////////////////////////////////////

                          TextSpan(
                            text:
                                'You\'ll be the team leader. A unique team code will be generated that you can share with your members.',

                            style: TextStyle(
                              color:
                                  Color(
                                      0xFF372AAC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  //////////////////////////////////////////////////
                  /// CREATE BUTTON
                  //////////////////////////////////////////////////

                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : createTeam,

                    child: Container(
                      width: double.infinity,
                      height: 58,

                      decoration:
                          BoxDecoration(

                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(
                                0xFFFF0A1F),

                            Color(
                                0xFF5A189A),
                          ],
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                                    16),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                                    0.1),

                            blurRadius: 10,

                            offset:
                                const Offset(
                                    0, 5),
                          ),
                        ],
                      ),

                      child: Center(

                        //////////////////////////////////////////////////
                        /// LOADING
                        //////////////////////////////////////////////////

                        child: isLoading

                            ? const SizedBox(
                                width: 22,
                                height: 22,

                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors
                                          .white,

                                  strokeWidth:
                                      2,
                                ),
                              )

                            //////////////////////////////////////////////////
                            /// TEXT
                            //////////////////////////////////////////////////

                            : const Text(
                                "Create Team",

                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .white,

                                  fontSize:
                                      16,

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

  ////////////////////////////////////////////////////////////
  /// INPUT CARD
  ////////////////////////////////////////////////////////////

  Widget _inputCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
                    0.04),

            blurRadius: 12,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          //////////////////////////////////////////////////////
          /// TITLE
          //////////////////////////////////////////////////////

          Text(
            title,

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,

              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          //////////////////////////////////////////////////////
          /// CHILD
          //////////////////////////////////////////////////////

          child,
        ],
      ),
    );
  }
}
