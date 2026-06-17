import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddJudgesScreen extends StatefulWidget {
  const AdminAddJudgesScreen({super.key});

  @override
  State<AdminAddJudgesScreen> createState() => _AdminAddJudgesScreenState();
}

class _AdminAddJudgesScreenState extends State<AdminAddJudgesScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final expertiseController = TextEditingController();

  bool _isCreatingJudge = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [
          /// BLUR BACKGROUND
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          /// FORM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),

                  borderRadius: BorderRadius.circular(28),

                  border: Border.all(color: Colors.white.withOpacity(0.25)),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),

                      blurRadius: 40,

                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Container(
                      padding: const EdgeInsets.all(24),

                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4F39F6),
                            Color(0xFF9810FA),
                            Color(0xFF432DD7),
                          ],
                        ),

                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),

                          topRight: Radius.circular(28),
                        ),
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),

                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: const Icon(
                              Icons.person_add_alt_1,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Judge",

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontSize: 22,

                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  "Create new judge account",

                                  style: TextStyle(
                                    color: Color(0xFFC6D2FF),

                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            behavior: HitTestBehavior.opaque,

                            child: Container(
                              width: 44,
                              height: 44,

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),

                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// BODY
                    Padding(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        children: [
                          buildField(
                            label: "Full Name *",

                            hint: "Dr. John Smith",

                            controller: nameController,

                            icon: Icons.person_outline,
                          ),

                          const SizedBox(height: 18),

                          buildField(
                            label: "Email Address *",

                            hint: "john.smith@university.edu",

                            controller: emailController,

                            icon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 18),

                          buildField(
                            label: "Temporary Password *",

                            hint: "Min. 8 characters",

                            controller: passwordController,

                            icon: Icons.lock_outline,
                          ),

                          const SizedBox(height: 8),

                          const Align(
                            alignment: Alignment.centerLeft,

                            child: Text(
                              "They'll be prompted to change this on first login",

                              style: TextStyle(
                                color: Color(0xFF6B7280),

                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          buildField(
                            label: "Specialization / Expertise",

                            hint: "AI & Machine Learning",

                            controller: expertiseController,

                            icon: Icons.psychology_outlined,
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },

                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,

                                    backgroundColor: const Color(0xFFF3F4F6),

                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),

                                  child: const Text(
                                    "Cancel",

                                    style: TextStyle(
                                      color: Color(0xFF374151),

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isCreatingJudge
                                          ? null
                                          : () async {
                                            if (nameController.text.isEmpty ||
                                                emailController.text.isEmpty ||
                                                passwordController
                                                    .text
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Please fill all required fields",
                                                  ),
                                                ),
                                              );

                                              return;
                                            }

                                            FirebaseApp? tempApp;

                                            setState(() {
                                              _isCreatingJudge = true;
                                            });

                                            try {
                                              /// LOADING
                                              showDialog(
                                                context: context,

                                                barrierDismissible: false,

                                                builder: (_) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                              );

                                              /// CREATE TEMP APP
                                              tempApp =
                                                  await Firebase.initializeApp(
                                                    name:
                                                        'tempApp_${DateTime.now().microsecondsSinceEpoch}',

                                                    options:
                                                        Firebase.app().options,
                                                  );

                                              /// SECONDARY AUTH
                                              FirebaseAuth tempAuth =
                                                  FirebaseAuth.instanceFor(
                                                    app: tempApp,
                                                  );

                                              /// CREATE ACCOUNT
                                              UserCredential
                                              userCredential = await tempAuth
                                                  .createUserWithEmailAndPassword(
                                                    email:
                                                        emailController.text
                                                            .trim(),

                                                    password:
                                                        passwordController.text
                                                            .trim(),
                                                  );

                                              final uid =
                                                  userCredential.user!.uid;

                                              /// SAVE TO FIRESTORE
                                              await FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(uid)
                                                  .set({
                                                    "createdAt":
                                                        FieldValue.serverTimestamp(),

                                                    "name":
                                                        nameController.text
                                                            .trim(),

                                                    "email":
                                                        emailController.text
                                                            .trim(),

                                                    "role": "judge",

                                                    "specialty":
                                                        expertiseController
                                                                .text
                                                                .isEmpty
                                                            ? "General"
                                                            : expertiseController
                                                                .text,

                                                    "teams": 0,
                                                  });

                                              /// IMPORTANT:
                                              /// Avoid signing out the temporary auth
                                              /// session explicitly here. On some
                                              /// platforms, that can disturb the
                                              /// primary admin session even though this
                                              /// flow uses a secondary Firebase app.
                                              await tempApp.delete();

                                              /// CLOSE LOADING
                                              Navigator.pop(context);

                                              /// SUCCESS
                                              showSuccessDialog();
                                            } on FirebaseAuthException catch (
                                              e
                                            ) {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }

                                              String message =
                                                  "Something went wrong";

                                              if (e.code ==
                                                  "email-already-in-use") {
                                                message =
                                                    "Email already exists";
                                              }

                                              if (e.code == "weak-password") {
                                                message =
                                                    "Password is too weak";
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(message),
                                                ),
                                              );
                                            } catch (e) {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString()),
                                                ),
                                              );
                                            } finally {
                                              if (tempApp != null) {
                                                try {
                                                  await tempApp?.delete();
                                                } catch (_) {}
                                              }

                                              if (mounted) {
                                                setState(() {
                                                  _isCreatingJudge = false;
                                                });
                                              }
                                            }
                                          },

                                  icon:
                                      _isCreatingJudge
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),

                                  label: Text(
                                    _isCreatingJudge
                                        ? "Creating..."
                                        : "Create Account",

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,

                                    backgroundColor: const Color(0xFF6D28D9),

                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,

            color: Color(0xFF374151),
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,

          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),

            filled: true,

            fillColor: Colors.white.withOpacity(0.7),

            contentPadding: const EdgeInsets.symmetric(vertical: 18),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: const BorderSide(color: Color(0xFF6D28D9), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,

          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: Container(
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),

                borderRadius: BorderRadius.circular(28),

                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Container(
                    width: 90,
                    height: 90,

                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.check_rounded,

                      size: 48,

                      color: Color(0xFF16A34A),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Judge Added!",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 24,

                      fontWeight: FontWeight.w800,

                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "Account created successfully.\nLogin credentials have been sent to their email.",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,

                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        Navigator.pop(context, {
                          "name": nameController.text,

                          "email": emailController.text,

                          "specialty":
                              expertiseController.text.isEmpty
                                  ? "General"
                                  : expertiseController.text,

                          "teams": 0,
                        });
                      },

                      style: ElevatedButton.styleFrom(
                        elevation: 0,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        backgroundColor: const Color(0xFF6D28D9),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      child: const Text(
                        "Continue",

                        style: TextStyle(
                          fontSize: 16,

                          fontWeight: FontWeight.w700,

                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
