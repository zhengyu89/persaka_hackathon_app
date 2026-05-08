// team_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/widgets/participant_ui.dart';
import 'create_team_screen.dart';
import 'join_team_screen.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {

    ////////////////////////////////////////////////////////////
    /// CURRENT USER EMAIL
    ////////////////////////////////////////////////////////////

    final String email =
        FirebaseAuth.instance.currentUser?.email ?? '';

    ////////////////////////////////////////////////////////////
    /// CHECK TEAM FROM FIRESTORE
    ////////////////////////////////////////////////////////////

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('teams')
          .where(
            'members',
            arrayContains: email,
          )
          .get(),

      builder: (context, snapshot) {

        ////////////////////////////////////////////////////////
        /// LOADING
        ////////////////////////////////////////////////////////

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        ////////////////////////////////////////////////////////
        /// USER HAS TEAM
        ////////////////////////////////////////////////////////

        if (snapshot.hasData &&
            snapshot.data!.docs.isNotEmpty) {

          final teamData =
              snapshot.data!.docs.first;

          return _HaveTeamView(
            teamData: teamData,
          );
        }

        ////////////////////////////////////////////////////////
        /// USER NO TEAM
        ////////////////////////////////////////////////////////

        return const _NoTeamView();
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// NO TEAM VIEW
////////////////////////////////////////////////////////////

class _NoTeamView extends StatelessWidget {
  const _NoTeamView();

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

            _headerSection(),

            //////////////////////////////////////////////////////
            /// BODY
            //////////////////////////////////////////////////////

            Transform.translate(
              offset: const Offset(0, -30),

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: Column(
                  children: [

                    //////////////////////////////////////////////////
                    /// ACTIONS
                    //////////////////////////////////////////////////

                    _actionCards(context),

                    const SizedBox(height: 20),

                    //////////////////////////////////////////////////
                    /// WHY TEAM
                    //////////////////////////////////////////////////

                    _whyTeamCard(),

                    const SizedBox(height: 20),

                    //////////////////////////////////////////////////
                    /// GUIDELINES
                    //////////////////////////////////////////////////

                    _guidelineCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// HEADER
  ////////////////////////////////////////////////////////////

  Widget _headerSection() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.only(
        top: 60,
        left: 20,
        right: 20,
        bottom: 60,
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
        children: [

          ////////////////////////////////////////////////////////
          /// TITLE
          ////////////////////////////////////////////////////////

          Row(
            children: [

              const Icon(
                Icons.groups_rounded,
                color: Colors.white,
              ),

              const SizedBox(width: 12),

              const Text(
                "Team Formation",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              )
            ],
          ),

          const SizedBox(height: 40),

          ////////////////////////////////////////////////////////
          /// ICON
          ////////////////////////////////////////////////////////

          Container(
            width: 90,
            height: 90,

            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.2),

              borderRadius:
                  BorderRadius.circular(24),
            ),

            child: const Icon(
              Icons.groups_2_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),

          const SizedBox(height: 24),

          ////////////////////////////////////////////////////////
          /// HEADING
          ////////////////////////////////////////////////////////

          const Text(
            "Join or Create a Team",

            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ////////////////////////////////////////////////////////
          /// SUBTITLE
          ////////////////////////////////////////////////////////

          const Text(
            "Collaborate with others to build amazing projects",

            textAlign: TextAlign.center,

            style: TextStyle(
              color: Color(0xFFD6D6FF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// ACTION CARDS
  ////////////////////////////////////////////////////////////

  Widget _actionCards(BuildContext context) {
    return Row(
      children: [

        ////////////////////////////////////////////////////////
        /// CREATE TEAM
        ////////////////////////////////////////////////////////

        Expanded(
          child: _gradientCard(
            title: "Create Team",
            subtitle: "Start a new team",
            icon: Icons.add,

            colors: const [
              Color(0xFF615FFF),
              Color(0xFF9810FA),
            ],

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CreateTeamScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 16),

        ////////////////////////////////////////////////////////
        /// JOIN TEAM
        ////////////////////////////////////////////////////////

        Expanded(
          child: _gradientCard(
            title: "Join Team",
            subtitle: "Use team code",
            icon:
                Icons.group_add_rounded,

            colors: const [
              Color(0xFFAD46FF),
              Color(0xFFE60076),
            ],

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const JoinTeamScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////
  /// CARD
  ////////////////////////////////////////////////////////////

  Widget _gradientCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 170,

        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: colors),

          borderRadius:
              BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.08),

              blurRadius: 10,

              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            //////////////////////////////////////////////////////
            /// ICON
            //////////////////////////////////////////////////////

            Container(
              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.2),

                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Icon(
                icon,
                color: Colors.white,
                size: 34,
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            /// TITLE
            //////////////////////////////////////////////////////

            Text(
              title,

              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 6),

            //////////////////////////////////////////////////////
            /// SUBTITLE
            //////////////////////////////////////////////////////

            Text(
              subtitle,

              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// WHY TEAM CARD
  ////////////////////////////////////////////////////////////

  Widget _whyTeamCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: const [

          Text(
            "Why form a team?",

            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 20),

          _InfoTile(
            emoji: "🤝",
            title: "Collaborate",
            subtitle:
                "Work together on projects",
          ),

          SizedBox(height: 16),

          _InfoTile(
            emoji: "💡",
            title: "Share Ideas",
            subtitle:
                "Brainstorm and innovate",
          ),

          SizedBox(height: 16),

          _InfoTile(
            emoji: "🏆",
            title: "Win Together",
            subtitle:
                "Compete as a unified team",
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// GUIDELINE CARD
  ////////////////////////////////////////////////////////////

  Widget _guidelineCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFFAF5FF),
          ],
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFE0E7FF),
        ),
      ),

      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            "Team Guidelines",

            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 18),

          _BulletText(
            "Maximum 4 members per team",
          ),

          SizedBox(height: 10),

          _BulletText(
            "You can only be part of one team",
          ),

          SizedBox(height: 10),

          _BulletText(
            "Team leader manages submissions",
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// WHITE CARD
  ////////////////////////////////////////////////////////////

  Widget _whiteCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: child,
    );
  }
}

////////////////////////////////////////////////////////////
/// HAVE TEAM VIEW
////////////////////////////////////////////////////////////

class _HaveTeamView extends StatelessWidget {
  const _HaveTeamView({
    required this.teamData,
  });

  final QueryDocumentSnapshot teamData;

  @override
  Widget build(BuildContext context) {

    ////////////////////////////////////////////////////////////
    /// DATA
    ////////////////////////////////////////////////////////////

    final data =
        teamData.data() as Map<String, dynamic>;

    final String teamName =
        data['teamName'] ?? 'No Team';

    final String teamCode =
        data['teamCode'] ?? '';

    final List members =
        data['members'] ?? [];

    final String description =
        data['teamDescription'] ?? '';

    return ParticipantPageScaffold(
      title: teamName,

      subtitle:
          'Manage your team and project progress',

      icon: Icons.groups_2_rounded,

      trailing: ParticipantInfoChip(
        label:
            '${members.length} Members',

        color: Colors.white,
      ),

      children: [

        ////////////////////////////////////////////////////////
        /// TEAM HEADER
        ////////////////////////////////////////////////////////

        ParticipantCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              ////////////////////////////////////////////////////
              /// TOP ROW
              ////////////////////////////////////////////////////

              Row(
                children: [

                  Container(
                    width: 56,
                    height: 56,

                    decoration:
                        const BoxDecoration(
                      gradient:
                          LinearGradient(
                        colors: [
                          Color(0xFF615FFF),
                          Color(0xFF9810FA),
                        ],
                      ),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.groups_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(
                          teamName,

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,

                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Team Code: $teamCode",

                          style:
                              const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              ////////////////////////////////////////////////////
              /// DESCRIPTION
              ////////////////////////////////////////////////////

              ParticipantBulletRow(
                text: description.isEmpty
                    ? 'No team description'
                    : description,

                icon:
                    Icons.lightbulb_rounded,

                color:
                    ParticipantPalette.primary,
              ),
            ],
          ),
        ),

        ////////////////////////////////////////////////////////
        /// MEMBERS
        ////////////////////////////////////////////////////////

        ParticipantCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const ParticipantSectionHeader(
                title: 'Members',
                subtitle:
                    'Current active team members',
              ),

              const SizedBox(height: 12),

              ...members.map((member) {

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: Container(
                    padding:
                        const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color:
                          const Color(
                              0xFFF8F8FD),

                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),

                    child: Row(
                      children: [

                        //////////////////////////////////////////////////
                        /// AVATAR
                        //////////////////////////////////////////////////

                        CircleAvatar(
                          radius: 24,

                          backgroundColor:
                              const Color(
                                  0xFF6C63FF),

                          child: Text(
                            member
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 14),

                        //////////////////////////////////////////////////
                        /// EMAIL
                        //////////////////////////////////////////////////

                        Expanded(
                          child: Text(
                            member,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// INFO TILE
////////////////////////////////////////////////////////////

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Container(
          width: 46,
          height: 46,

          decoration: BoxDecoration(
            color:
                const Color(0xFFF3F4F6),

            borderRadius:
                BorderRadius.circular(14),
          ),

          alignment: Alignment.center,

          child: Text(
            emoji,
            style:
                const TextStyle(fontSize: 22),
          ),
        ),

        const SizedBox(width: 14),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              title,

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              subtitle,

              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        )
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// BULLET TEXT
////////////////////////////////////////////////////////////

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        const Text(
          "• ",

          style: TextStyle(
            color: Color(0xFF4F39F6),
            fontWeight:
                FontWeight.bold,
          ),
        ),

        Expanded(
          child: Text(
            text,

            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}