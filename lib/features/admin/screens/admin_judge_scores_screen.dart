import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminJudgeScoresScreen extends StatefulWidget {
  final String hackathonId;
  final String hackathonName;

  const AdminJudgeScoresScreen({
    super.key,
    required this.hackathonId,
    required this.hackathonName,
  });

  @override
  State<AdminJudgeScoresScreen> createState() => _AdminJudgeScoresScreenState();
}

class _AdminJudgeScoresScreenState extends State<AdminJudgeScoresScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Judge Scores - ${widget.hackathonName}'),
        backgroundColor: const Color(0xFFFF0A1F),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('hackathons')
            .doc(widget.hackathonId)
            .collection('judgingResults')
            .orderBy('averageScore', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No score results found.'));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            children: snapshot.data!.docs.map((teamDoc) {
              final team = teamDoc.data();
              final teamName = team['teamName'] as String? ?? 'Team ${teamDoc.id}';
              final totalScore = team['totalScore'];
              final averageScore = team['averageScore'];
              final teamId = teamDoc.id;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ExpansionTile(
                  title: Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Average: ${averageScore ?? 'N/A'}  Total: ${totalScore ?? 'N/A'}'),
                  children: [
                    _buildTeamHeader(team),
                    const SizedBox(height: 12),
                    _buildJudgeScoreList(teamId),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTeamHeader(Map<String, dynamic> team) {
    final submittedCount = team['submittedCount'] ?? 0;
    final judgeCount = team['totalJudges'] ?? team['judgeCount'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Text('Judges counted: $judgeCount')),
          Expanded(child: Text('Submitted: $submittedCount')),
        ],
      ),
    );
  }

  Widget _buildJudgeScoreList(String teamId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('hackathons')
          .doc(widget.hackathonId)
          .collection('judgingResults')
          .doc(teamId)
          .collection('judgeScores')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No judge scores yet.'),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((judgeDoc) {
            final judgeScore = judgeDoc.data();
            final judgeName = judgeScore['judgeName'] as String? ?? 'Judge';
            final totalScore = judgeScore['totalScore'];
            final submitted = judgeScore['submitted'] as bool? ?? false;
            final comment = judgeScore['comment'] as String? ?? '';

            return ListTile(
              title: Text(judgeName),
              subtitle: Text('Score: ${totalScore ?? 'N/A'} • ${submitted ? 'Submitted' : 'Pending'}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                _showJudgeScoreDetails(judgeScore);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showJudgeScoreDetails(Map<String, dynamic> scoreData) {
    final criteriaScores = scoreData['criteriaScores'] as List<dynamic>? ?? [];
    final totalScore = scoreData['totalScore']?.toString() ?? 'N/A';
    final comment = scoreData['comment'] as String? ?? 'No comment.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${scoreData['judgeName'] ?? 'Judge'} Score Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total score: $totalScore'),
                const SizedBox(height: 12),
                const Text('Criteria Scores:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...criteriaScores.map((raw) {
                  final item = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('${item['name'] ?? 'Criterion'}: ${item['score'] ?? 'N/A'} / ${item['maxScore'] ?? 'N/A'}'),
                  );
                }).toList(),
                const SizedBox(height: 12),
                const Text('Comment:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(comment),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
