# Teammate Setup Guide

This guide is for teammates who clone or pull `persaka_hackathon_app` and need to set up their own computer to work with the same shared Firebase project.

## Important Idea

GitHub gives you the codebase.
Firebase still provides the live backend.

When you clone this repository, you get:

- Flutter source code
- Firebase configuration files that are committed to the repo
- rules files

When you clone this repository, you do not get:

- Firestore database contents
- Authentication users export
- deployed Firebase environment itself
- private admin secrets

So your job is to pull the code, install the dependencies, log into Firebase with your own account, and connect your machine to the same shared Firebase project.

## Before You Start

Ask the project owner to make sure you have access to:

- the GitHub repository
- the shared Firebase project in Firebase Console

You should be added to the Firebase project as a team member using your own Google account.

## 1. Install Required Tools

Make sure these are installed on your computer:

- Flutter SDK
- VS Code
- Git
- Node.js 18 or later
- Firebase CLI
- FlutterFire CLI

Check versions:

```bash
node -v
flutter --version
git --version
```

Install Firebase CLI:

```bash
npm install -g firebase-tools
```

Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

Verify:

```bash
firebase --version
flutterfire --version
```

## 2. Clone the Repository

Clone the project and move into the root folder:

```bash
git clone <repository-url>
cd persaka_hackathon_app
```

Open it in VS Code:

```bash
code .
```

## 3. Install Flutter Dependencies

From the project root:

```bash
flutter pub get
```

## 4. Log In to Firebase

Log in with your own Firebase account:

```bash
firebase login
```

Use the same Google account that has been added to the shared Firebase project.

## 5. Use the Shared Firebase Project

This team is using one shared Firebase project.

That means:

- do not create a different Firebase project for your own machine unless the team explicitly wants that
- do not overwrite the shared Firebase app configuration without discussing it with the team
- use the same Firebase project that the repository is already configured for

There are two common cases.

### Case A: Firebase config files are already committed

If the repository already contains files such as:

- `lib/firebase_options.dart`
- `firebase.json`
- `.firebaserc`

Then usually you only need:

```bash
flutter pub get
firebase login
```

After that, you can usually run the app directly.

### Case B: The owner asks you to regenerate local platform config

Sometimes the team may ask you to run:

```bash
flutterfire configure
```

Only do this if:

- the team has agreed on it
- the repository is missing Firebase app config
- platform registration needs to be updated

If you run it, make sure you select the shared Firebase project, not a personal one.

## 6. Run the App

After dependencies are installed and Firebase access is ready:

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

If the app fails because Firebase is not configured yet, check with the project owner whether:

- `lib/firebase_options.dart` has been committed
- the correct Firebase project access has been granted
- Auth and Firestore have been enabled in Firebase Console

If Android Google sign-in does not work on your machine, do this on Windows:

```powershell
cd android
.\gradlew signingReport
```

Then:

1. Copy the `SHA-1` and `SHA-256` values from the `debug` and `release` variants.
2. Ask the project owner to confirm those fingerprints are added to the Android app in Firebase Console for `com.example.persaka_hackathon_app`, or add them yourself if the team expects you to manage Firebase setup.
3. Make sure Google sign-in is enabled in Firebase Console under Authentication → Sign-in method → Google.
4. Download the refreshed Firebase Android config and replace:

```text
android/app/google-services.json
```

5. Rebuild the app:

```bash
flutter clean
flutter pub get
flutter run
```

If you see a Google sign-in developer error or `ApiException: 10`, it usually means the SHA fingerprints or `google-services.json` file are out of date.

## 7. Local Storage Reminder

This project does not use Firebase Storage.

That means:

- files and device-only data stay in local storage on the user device
- app logic stays inside Flutter
- Firebase is only used for authentication and shared Firestore data

If you are working on local persistence features, check the Flutter codebase for the chosen local storage approach such as:

- `shared_preferences`
- local file storage
- SQLite or another local database package if the team adds one later

## 8. What Git Pull Actually Gives You

`git fetch` or `git pull` will give you:

- Flutter code
- Firebase rules
- project configuration files

`git fetch` or `git pull` will not give you:

- Firestore documents
- Auth users list
- deployed backend state

Think of Git as the blueprint and Firebase as the live cloud service.

## 9. Safe Team Workflow

Use this normal working flow:

```bash
git pull
flutter pub get
firebase login
flutter run
```

Then work normally, commit your changes, and push them back to GitHub.

## 10. Do Not Commit Secrets

Do not commit:

- service account JSON files
- private `.env` values
- API secrets
- any local-only credentials

Safe things that are usually committed:

- Flutter source code
- `lib/firebase_options.dart`
- Firebase rules files
- `firebase.json`
- `.firebaserc` when the team intentionally shares the same project alias

## 11. If Something Does Not Work

Check these in order:

1. run `flutter pub get`
2. confirm `firebase login` was done with the correct Google account
3. confirm you were added to the shared Firebase project
4. check whether `lib/firebase_options.dart` exists
5. confirm Auth and Firestore are enabled in Firebase Console

If it still fails, ask the project owner these exact questions:

- Have I been added to the shared Firebase project?
- Is `lib/firebase_options.dart` already committed?
- Should I run `flutterfire configure`, or should I use the committed config?
- Are Auth and Firestore already enabled in Firebase Console?

## Quick Start Summary

Most teammates will only need these commands:

```bash
git clone <repository-url>
cd persaka_hackathon_app
flutter pub get
firebase login
flutter run
```

For this project, always use the shared Firebase project unless the team explicitly decides otherwise.
