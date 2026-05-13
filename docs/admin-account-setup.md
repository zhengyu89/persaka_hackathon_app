# Admin Account Setup Guide

This guide explains how to create or enable an admin account in `persaka_hackathon_app`.

## Important Note

Right now, this app does **not** promote admins from Firestore alone.

Admin access is currently decided in:

- `lib/core/services/auth_service.dart`

In `AuthService.getUserRole(...)`, the app checks whether the signed-in user's email is inside a hardcoded `adminEmails` list.

That means:

- a newly registered user is saved to Firestore with role `admin` if their email is listed in `adminEmails`
- all other newly registered users are saved with role `participant`
- changing the Firestore `role` field to `admin` is not enough if the email is not in the hardcoded admin list
- the account email must match an email listed in `adminEmails`

## Current Admin Flow

When a user registers:

- Firebase Authentication creates the account
- a Firestore document is created in `users/{uid}`
- the saved role is `admin` for emails in `adminEmails`, otherwise `participant`

When a user logs in:

- the app first checks whether the user's email is in the hardcoded admin email list
- if yes, the app returns `admin`
- if not, the app falls back to the Firestore `role` value

## Option 1: Enable an Existing Email as Admin

Use this when the admin account already exists in Firebase Authentication, or when the user will register using a known email.

### Step 1. Open the auth service

Open:

```text
lib/core/services/auth_service.dart
```

Look for this section:

```dart
const adminEmails = [
  'danishekhsan@gmail.com',
  'admin2@gmail.com',
  'admin3@gmail.com',
  'h58176801@gmail.com',
];
```

### Step 2. Add the new admin email

Add the email address you want to allow as admin.

Example:

```dart
const adminEmails = [
  'danishekhsan@gmail.com',
  'admin2@gmail.com',
  'admin3@gmail.com',
  'h58176801@gmail.com',
  'newadmin@example.com',
];
```

### Step 3. Save and rebuild the app

Run:

```bash
flutter run
```

If the app is already running, do a full restart to make sure the updated admin list is loaded.

### Step 4. Sign in with that email

The user can now:

- register with that email and password, or
- sign in with Google using that same email, if Google sign-in is enabled

Once signed in, the app should detect the email and treat the user as `admin`.

## Option 2: Create a Brand-New Admin Account

Use this when there is no admin account yet.

### Step 1. Choose the admin email

Decide the exact email that will be used for the admin account.

Example:

- `newadmin@example.com`

### Step 2. Add that email to `adminEmails`

Before testing login, add the same email to:

```text
lib/core/services/auth_service.dart
```

Follow the same process shown in Option 1.

### Step 3. Create the account

Create the account using one of these methods:

- register through the app using email and password
- sign in through Google using the same email account
- create the user manually in Firebase Authentication if your team prefers console-based setup

### Step 4. Confirm Firestore user creation

After first sign-in or registration, check Firestore:

```text
users/{uid}
```

You should usually see fields like:

```text
createdAt: <server timestamp>
email: newadmin@example.com
name:
role: admin
```

If the email is listed in `adminEmails`, the saved Firestore role should also be `admin`.

## Firebase Console Checks

If account creation or login fails, verify these are enabled in Firebase Console:

- Authentication
- Email/Password sign-in, if using password login
- Google sign-in, if using Google login
- Cloud Firestore

Also confirm the signed-in email exactly matches the email in `adminEmails`.

## Common Mistakes

- adding `role: admin` in Firestore but forgetting to add the email in `adminEmails`
- using a different Google account than the one added to the admin list
- editing the code but not rebuilding or fully restarting the app
- typing the admin email with a mismatch in spelling or letter case

## Recommended Improvement Later

The current setup works for quick development, but it is not ideal for long-term admin management.

Later, the team should consider moving admin control to a backend-managed approach such as:

- storing the role fully in Firestore and enforcing it safely with security rules
- using Firebase custom claims for admin authorization

That would avoid needing to hardcode admin emails in the app source code.
