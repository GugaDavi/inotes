import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:inotes/features/auth/presentation/cubit/auth_state.dart';
import 'package:inotes/features/shared/widgets/copy_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Locator.get<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        builder: (context, state) {
          if (state is AuthSessionCreated) {
            return _AuthScaffold(
              child: _CodeCreatedView(
                code: state.code,
                onContinue: () => context.read<AuthCubit>().confirmNewSession(),
              ),
            );
          }
          return _AuthScaffold(
            child: _FormView(
              controller: _controller,
              isLoading: state is AuthLoading,
              error: state is AuthError ? state.message : null,
              onEnter: () => context.read<AuthCubit>().enterCode(_controller.text),
              onNewSession: () => context.read<AuthCubit>().startNewSession(),
            ),
          );
        },
      ),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxFormWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.controller,
    required this.isLoading,
    required this.error,
    required this.onEnter,
    required this.onNewSession,
  });

  final TextEditingController controller;
  final bool isLoading;
  final String? error;
  final VoidCallback onEnter;
  final VoidCallback onNewSession;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        Text('iNotes', style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Session Code',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        CupertinoTextField(
          controller: controller,
          placeholder: 'Enter your code…',
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(error!, style: const TextStyle(color: CupertinoColors.destructiveRed, fontSize: 13)),
        ],
        const SizedBox(height: AppSpacing.md),
        CupertinoButton.filled(
          onPressed: isLoading ? null : onEnter,
          child: isLoading ? const CupertinoActivityIndicator() : const Text('Enter'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: CupertinoColors.separator.resolveFrom(context))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'or',
                style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 13),
              ),
            ),
            Expanded(child: Container(height: 1, color: CupertinoColors.separator.resolveFrom(context))),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        CupertinoButton(onPressed: isLoading ? null : onNewSession, child: const Text('Start New Session')),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _CodeCreatedView extends StatelessWidget {
  const _CodeCreatedView({required this.code, required this.onContinue});

  final String code;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        Text(
          'Your Session Code',
          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(code, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 4)),
              const SizedBox(width: 12),
              CopyButton(text: code, size: 20),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Write it down! You will need this code to access your notes from another device.',
          textAlign: TextAlign.center,
          style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        CupertinoButton.filled(onPressed: onContinue, child: const Text('Continue')),
        const SizedBox(height: 48),
      ],
    );
  }
}
