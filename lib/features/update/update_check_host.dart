import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/features/update/app_update_controller.dart';
import 'package:tasko/features/update/present_update_check.dart';

/// Runs the GitHub update check after first frame and when the app resumes.
class UpdateCheckHost extends ConsumerStatefulWidget {
  const UpdateCheckHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateCheckHost> createState() => _UpdateCheckHostState();
}

class _UpdateCheckHostState extends ConsumerState<UpdateCheckHost>
    with WidgetsBindingObserver {
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_autoCheck());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_autoCheck());
    }
  }

  Future<void> _autoCheck() async {
    if (!mounted || _dialogOpen) return;
    final outcome = await ref.read(appUpdateControllerProvider).autoCheck();
    if (!mounted || _dialogOpen) return;
    if (outcome is! UpdateCheckAvailable) return;
    _dialogOpen = true;
    try {
      await presentUpdateCheckOutcome(
        context,
        ref,
        outcome,
        manual: false,
      );
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
