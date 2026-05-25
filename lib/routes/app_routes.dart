import 'package:flutter/material.dart';
import '../auth_wrapper.dart';
import '../features/auth/password_auth/screens/login_screen.dart';
import '../features/auth/password_auth/screens/register_screen.dart';
import '../features/auth/email_verification/screens/email_verification_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/admin/screens/admin_dashboard.dart';
import '../features/admin/screens/admin_hackathon_settings_screen.dart';
import '../features/judge/screens/judge_dashboard.dart';
import '../features/judge/screens/judge_rubric_screen.dart';
import '../features/judge/screens/judge_score_screen.dart';
import '../features/participant/screens/participant_dashboard.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const verify = '/verify';
  static const home = '/home';
  static const profile = '/profile';
  static const admin = '/admin';
  static const judge = '/judge';
  static const participant = '/participant';
  static const adminHackathonSettingsPrefix = '/app/admin/hackathon/';
  static const judgeHackathonPrefix = '/app/judge/hackathon/';
  static const judgeTeamPrefix = '/app/judge/team/';
  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    verify: (_) => const EmailVerificationScreen(),
    home: (_) => const AuthWrapper(),
    profile: (_) => const ProfileScreen(),
    admin: (_) => const AdminDashboard(),
    judge: (_) => const JudgeDashboard(),
    participant: (_) => const ParticipantDashboard(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    const suffix = '/settings';

    if (name.startsWith(adminHackathonSettingsPrefix) &&
        name.endsWith(suffix)) {
      final hackathonId = Uri.decodeComponent(
        name
            .substring(
              adminHackathonSettingsPrefix.length,
              name.length - suffix.length,
            )
            .trim(),
      );

      if (hackathonId.isNotEmpty) {
        return MaterialPageRoute(
          settings: settings,
          builder:
              (_) => AdminHackathonSettingsScreen(hackathonId: hackathonId),
        );
      }
    }

    const rubricSuffix = '/rubric';
    if (name.startsWith(judgeHackathonPrefix) &&
        name.endsWith(rubricSuffix)) {
      final hackathonId = Uri.decodeComponent(
        name
            .substring(
              judgeHackathonPrefix.length,
              name.length - rubricSuffix.length,
            )
            .trim(),
      );
      final args = settings.arguments as Map<String, dynamic>?;
      final assignedTeams = List<String>.from(
        args?['assignedTeams'] ?? const <String>[],
      );

      if (hackathonId.isNotEmpty) {
        return MaterialPageRoute(
          settings: settings,
          builder:
              (_) => JudgeRubricScreen(
                hackathonId: hackathonId,
                assignedTeamIds: assignedTeams,
              ),
        );
      }
    }

    const scoreSuffix = '/score';
    if (name.startsWith(judgeTeamPrefix) && name.endsWith(scoreSuffix)) {
      final teamId = Uri.decodeComponent(
        name
            .substring(judgeTeamPrefix.length, name.length - scoreSuffix.length)
            .trim(),
      );
      final args = settings.arguments as Map<String, dynamic>?;
      final hackathonId = args?['hackathonId']?.toString();

      if (teamId.isNotEmpty) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JudgeScoreScreen(
            teamId: teamId,
            hackathonId: hackathonId,
          ),
        );
      }
    }

    return null;
  }
}
