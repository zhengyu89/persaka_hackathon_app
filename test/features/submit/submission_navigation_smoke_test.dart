import 'package:flutter_test/flutter_test.dart';
import 'package:persaka_hackathon_app/features/admin/screens/admin_dashboard.dart';
import 'package:persaka_hackathon_app/features/admin/screens/admin_manage_hackathons_screen.dart';
import 'package:persaka_hackathon_app/features/judge/screens/judge_dashboard.dart';
import 'package:persaka_hackathon_app/features/submit/screens/submissions_review_screen.dart';

void main() {
  test('submission-related screens construct successfully', () {
    expect(
      const SubmissionsReviewScreen.admin(),
      isA<SubmissionsReviewScreen>(),
    );
    expect(
      const SubmissionsReviewScreen.judge(),
      isA<SubmissionsReviewScreen>(),
    );
    expect(
      const AdminManageHackathonsScreen(),
      isA<AdminManageHackathonsScreen>(),
    );
    expect(const AdminAddHackathonScreen(), isA<AdminAddHackathonScreen>());
    expect(const JudgeDashboard(), isA<JudgeDashboard>());
    expect(const AdminDashboard(), isA<AdminDashboard>());
  });
}
