import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/auth/auth_provider.dart';
import 'package:tasko/core/constants.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/mascot/tasko_mascot.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';
import 'package:tasko/core/theme.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [TaskoColors.cream, TaskoColors.mist, Color(0xFFD9EDE9)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _entrance,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _entrance,
                curve: Curves.easeOutCubic,
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    const TaskoMascot(pose: TaskoPose.wave, size: 200),
                    const SizedBox(height: 20),
                    Text(
                      AppConstants.appName,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 44,
                                color: TaskoColors.charcoal,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.signInTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(flex: 2),
                    if (auth.error != null) ...[
                      Text(
                        auth.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: TaskoColors.danger),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed:
                            auth.isLoading ? null : () => ref.read(authProvider.notifier).signIn(),
                        icon: auth.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(
                          auth.isLoading
                              ? AppStrings.signingIn
                              : AppStrings.continueWithGoogle,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: TaskoColors.teal,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.signInFootnote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.versionLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: TaskoColors.warmGrey,
                          ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
