# Persaka Hackathon OS
<p align="center">
  <img src="./assets/images/hackathon.png" alt="Persaka Hackathon OS cover" width="180" />
</p>
<p align="center">
  A Flutter + Firebase hackathon management app for participants, judges, and organisers.
  <br />
  It centralises authentication, team formation, hackathon registration, submission tracking,
  judging, schedule updates, and leaderboard publishing in one mobile-first app.
</p>

<p align="center">
  <a href="./docs/project-setup.md"><strong>Project Setup</strong></a> ·
  <a href="./docs/teammate-setup.md"><strong>Teammate Setup</strong></a> ·
  <a href="./docs/admin-account-setup.md"><strong>Admin Account Setup</strong></a> ·
  <a href="./firestore.rules"><strong>Firestore Rules</strong></a>
</p>

<p align="center">
  <img alt="Frontend Flutter" src="https://img.shields.io/badge/Frontend-Flutter-02569B?style=flat-square&logo=flutter&logoColor=white">
  <img alt="Language Dart" src="https://img.shields.io/badge/Language-Dart-0175C2?style=flat-square&logo=dart&logoColor=white">
  <img alt="Auth Firebase Authentication" src="https://img.shields.io/badge/Auth-Firebase%20Authentication-FFCA28?style=flat-square&logo=firebase&logoColor=black">
  <img alt="Database Cloud Firestore" src="https://img.shields.io/badge/Database-Cloud%20Firestore-FFCA28?style=flat-square&logo=firebase&logoColor=black">
  <img alt="Sign In Email and Google" src="https://img.shields.io/badge/Sign--In-Email%20%2B%20Google-4285F4?style=flat-square&logo=google&logoColor=white">
  <img alt="Platforms Android and iOS" src="https://img.shields.io/badge/Platforms-Android%20%2B%20iOS-34A853?style=flat-square">
  <img alt="Testing flutter test" src="https://img.shields.io/badge/Testing-flutter%20test-6DB33F?style=flat-square">
</p>

## Highlights

- Role-aware app flow for `participant`, `judge`, and `admin` users through a shared `AuthWrapper`.
- Email/password login, Google sign-in, email verification, and password recovery using Firebase Authentication.
- Team creation and joining with generated team codes stored in Firestore.
- Admin-managed hackathons with poster upload, status, schedule, rubric criteria, submission links, and judging rules.
- Judge assignment and scoring workflows with optional anonymous judging support.
- Participant submission workspace for repository and demo video links, plus organiser form handoff.
- Live leaderboard controls for organisers and published final-results snapshots for participants.
- Firestore-backed schedule and announcement feeds.
- Existing docs for shared Firebase onboarding and admin account setup.

## Overview

Persaka Hackathon OS is a Flutter application that keeps most product logic in the client and uses Firebase as the shared backend. There is no separate custom API server in this repository. Instead, the app relies on:

- Firebase Authentication for account creation, login session handling, email verification, password reset, and Google sign-in.
- Cloud Firestore for user roles, team records, hackathons, submissions, judge scoring, schedule data, announcements, and published results.
- Flutter UI and local app logic for navigation, validation, role-based dashboards, and user workflows.

At runtime, the app starts in [`lib/main.dart`](./lib/main.dart), initializes Firebase using [`lib/firebase_options.dart`](./lib/firebase_options.dart), and routes the authenticated user through [`lib/auth_wrapper.dart`](./lib/auth_wrapper.dart). From there, users land on the correct dashboard based on role:

- Participants use a tabbed dashboard with Home, Team, Schedule, Submit, Board, and Profile.
- Judges use a judging-focused dashboard with assigned hackathons, assigned teams, rubric viewing, live board access, and profile tools.
- Admins manage hackathons, judges, schedules, submissions, final standings, and overview metrics.

## What This Project Can Do

### Authentication and access

- Register with email and password.
- Sign in with email and password.
- Sign in with Google.
- Send email verification after registration and block unverified users behind the verification screen.
- Send password reset emails from the forgot-password flow.
- Load a Firestore user profile and update name / phone details from the profile page.

### Participant workflow

- Create a new team with a generated 8-character team code.
- Join an existing team with a shared team code.
- View team members, team ownership, and team-linked hackathons.
- Register leader-owned teams to published hackathons from the team workspace.
- Open the organiser-provided participant form for a selected hackathon.
- Save repository and demo video links per team + hackathon combination.
- Enforce leader-only submission editing.
- Respect submission deadlines stored on the hackathon document.
- View published final results for hackathons the participant's team actually joined.

### Judge workflow

- View only the hackathons assigned to the signed-in judge.
- See rubric readiness and assigned team counts for each assigned hackathon.
- Open a rubric screen backed by Firestore criteria.
- Open assigned teams and submit scorecards to nested judging collections.
- Review submitted project links and organiser review sheet links in the judging workspace.
- Use anonymous team labels like `Team #1` when anonymous judging is enabled.

### Admin / organiser workflow

- View a dashboard with live counts for teams, submissions, and judges.
- Create hackathons with title, description, status, dates, poster image, participant form URL, and review URL.
- Manage judging rules such as judges per team, score scale, score editing, anonymous judging, minimum judges required, scoring method, and submission deadline.
- Create and manage rubric criteria under each hackathon.
- Create judge accounts and manage judge assignment visibility.
- Add schedule items and announcements.
- Review submitted team links across hackathons.
- Publish, update, or hide live leaderboard standings.
- Reveal final results snapshots that only rank teams meeting the configured minimum judge threshold.

## How It Works

1. The app initializes Firebase and listens to auth state changes.
2. Once the user signs in, `AuthWrapper` checks verification status and resolves the user's role.
3. Participants create or join teams, then register those teams into published hackathons.
4. Team leaders submit repository and demo video links for joined hackathons.
5. Admins configure hackathon metadata, judging rules, criteria, deadlines, and judge assignments.
6. Judges open assigned teams, review the rubric, and submit scorecards.
7. Live standings are aggregated from Firestore judging results for judge/admin views.
8. Admins can publish or hide leaderboard visibility, and separately reveal final-results snapshots for participants.

## Data Model At A Glance

The app primarily works with these Firestore collections and subcollections:

- `users`: profile data and app roles such as `participant`, `judge`, and `admin`
- `teams`: team metadata, leader email, member emails, and generated team code
- `hackathons`: core event metadata, registration lists, deadlines, judging rules, and form links
- `hackathons/{hackathonId}/criteria`: rubric criteria used in scoring
- `hackathons/{hackathonId}/judgingResults`: aggregated live judging results by team
- `hackathons/{hackathonId}/judgingResults/{teamId}/judgeScores`: per-judge score submissions
- `hackathons/{hackathonId}/finalResults`: organiser-published final standings snapshots
- `submissions`: saved repository and video links by hackathon/team pair
- `schedule`: event schedule items
- `announcements`: organiser announcements

## Quick Start

### Prerequisites

- Flutter SDK with Dart `3.7.x`
- Android Studio or another Android runtime setup
- Optional iOS tooling if you are developing on macOS
- Node.js if you need Firebase CLI / FlutterFire CLI
- Access to the shared Firebase project used by the team

### Most common teammate setup

If the committed Firebase configuration already matches the shared project you should use, the shortest path is:

```bash
git clone <repository-url>
cd persaka_hackathon_app
flutter pub get
flutter run
```

If your team expects CLI-based Firebase access on your machine too:

```bash
firebase login
```

For fuller onboarding instructions, use:

- [`docs/project-setup.md`](./docs/project-setup.md)
- [`docs/teammate-setup.md`](./docs/teammate-setup.md)

### Current Firebase configuration

This repository already includes:

- [`lib/firebase_options.dart`](./lib/firebase_options.dart)
- [`firebase.json`](./firebase.json)
- `android/app/google-services.json`
- [`firestore.rules`](./firestore.rules)

The committed FlutterFire options currently include:

- Android
- iOS

In practice, Android is the most complete checked-in path in this repository because it already includes `android/app/google-services.json`. If you plan to run on iOS or any desktop / web target, expect some extra native Firebase setup and platform registration work before everything is fully functional.

### Running the app

From the project root:

```bash
flutter pub get
flutter run
```

Useful alternatives:

```bash
flutter run -d android
flutter devices
```

### If Google sign-in fails on Android

If Google sign-in shows a developer error or `ApiException: 10`, refresh the Android Firebase setup:

```powershell
cd android
.\gradlew signingReport
```

Then:

1. Add the debug and release SHA fingerprints in Firebase Console.
2. Confirm Google sign-in is enabled in Firebase Authentication.
3. Download a fresh `google-services.json`.
4. Replace `android/app/google-services.json`.
5. Rebuild the app with `flutter clean`, `flutter pub get`, and `flutter run`.

Detailed steps are already documented in:

- [`docs/project-setup.md`](./docs/project-setup.md)
- [`docs/teammate-setup.md`](./docs/teammate-setup.md)

## Admin And Judge Setup

### Admin access

Admin access is not fully driven by Firestore alone in the current implementation.

The app checks admin privileges using a hardcoded email allowlist inside [`lib/core/services/auth_service.dart`](./lib/core/services/auth_service.dart). If you want a new admin account to work, make sure the email is added there.

Use this guide:

- [`docs/admin-account-setup.md`](./docs/admin-account-setup.md)

### Judge accounts

Judge records are stored in Firestore with the role `judge`, and the admin area includes a judge-creation / judge-management flow. Judges then appear in the admin tools and can be assigned across hackathons and teams.

## Typical End-To-End Demo Flow

1. Run the app on an Android emulator or device.
2. Register a participant account and complete email verification.
3. Create a team, or join one using a shared team code.
4. As a team leader, register the team into a published hackathon.
5. Open the Submission Hub and save the repository URL and demo video URL.
6. Sign in with an admin email from the configured allowlist and create or update a hackathon.
7. Add judging criteria, configure judging rules, and assign judges.
8. Sign in as a judge, open assigned teams, and submit scorecards.
9. Return to the admin leaderboard controls to publish live standings or reveal final-results snapshots.

## Testing

Run the test suite from the repository root:

```bash
flutter test
```

Useful focused test files already in the repo:

- [`test/features/board/board_screen_test.dart`](./test/features/board/board_screen_test.dart)
- [`test/features/board/final_results_service_test.dart`](./test/features/board/final_results_service_test.dart)
- [`test/features/admin/final_results_summary_card_test.dart`](./test/features/admin/final_results_summary_card_test.dart)
- [`test/features/submit/submission_navigation_smoke_test.dart`](./test/features/submit/submission_navigation_smoke_test.dart)
- [`test/features/submit/submission_models_test.dart`](./test/features/submit/submission_models_test.dart)
- [`test/features/submit/submission_validators_test.dart`](./test/features/submit/submission_validators_test.dart)
- [`test/features/submit/submission_workspace_view_test.dart`](./test/features/submit/submission_workspace_view_test.dart)

These tests mainly cover leaderboard rendering, final-results ranking logic, and submission workspace behavior.

## Repository Structure

```text
lib/
  auth_wrapper.dart                Auth gate and role-based landing
  core/
    services/                      Auth, verification, password reset, schedule
    theme/                         Shared app theme
  features/
    admin/                         Admin dashboard, hackathon and judge management
    auth/                          Login, register, verify, and password recovery
    board/                         Live leaderboard and final results
    home/                          Participant home dashboard
    judge/                         Judge dashboard, rubric, team scoring
    participant/                   Participant dashboard shell
    profile/                       Profile viewing and editing
    schedule/                      Schedule and announcement views
    submit/                        Submission hub and review workspaces
    team/                          Team creation, joining, and hackathon registration
  routes/                          Named routes and generated route handling
  shared/                          Shared widgets and UI helpers
test/                              Widget and service tests
docs/                              Setup and onboarding documentation
assets/images/                     App images used by the UI and README
android/                           Android runner and Firebase Android config
ios/                               iOS runner
firebase.json                      Firebase CLI configuration
firestore.rules                    Firestore security rules
```

## Project Documents

- [`docs/project-setup.md`](./docs/project-setup.md): owner / lead setup for Flutter, Firebase, and shared project configuration
- [`docs/teammate-setup.md`](./docs/teammate-setup.md): teammate onboarding after cloning the repository
- [`docs/admin-account-setup.md`](./docs/admin-account-setup.md): how admin accounts work in the current implementation
- [`firestore.rules`](./firestore.rules): Firestore security rules committed with the repository

## Current Implementation Notes

- The project is mobile-first today. Android is the clearest ready-to-run Firebase path in the repo; iOS, web, and desktop targets need extra setup before they can be treated as fully ready.
- Admin access is currently tied to an email allowlist in code, not only to Firestore role changes.
- The repository includes starter Firestore rules, but you should review and align them with the latest app write flows before any real deployment.
- The app contains both live Firestore-backed screens and some UI sections that still serve as polished placeholder / preview content.
- `android/app/build.gradle.kts` and the Android Firebase config are important for Google sign-in and should stay in sync with the shared Firebase project.

## Contribution And Feedback

If you are extending this project, the highest-value review areas are:

- Firebase role and security-rule hardening
- judge assignment correctness and scoring integrity
- submission workflow edge cases around deadlines and leader permissions
- platform expansion beyond the current Android / iOS Firebase setup
- UX polish for the participant and organiser experience

Small, focused pull requests and setup-document updates will help this project stay easier for the next teammate to onboard.
