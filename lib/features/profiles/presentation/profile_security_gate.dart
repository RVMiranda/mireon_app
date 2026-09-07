import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_models/profiles_providers.dart';

/// Above the router Navigator: also covers dialogs, deep links and restored routes.
/// Removing the child releases the viewer and stops playback while locked.
class ProfileSecurityGate extends ConsumerStatefulWidget {
  const ProfileSecurityGate({required this.child, super.key});
  final Widget child;
  @override
  ConsumerState<ProfileSecurityGate> createState() =>
      _ProfileSecurityGateState();
}

class _ProfileSecurityGateState extends ConsumerState<ProfileSecurityGate>
    with WidgetsBindingObserver {
  final _secret = TextEditingController();
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _secret.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) _secret.clear();
    ref.read(profilesNotifierProvider.notifier).setForeground(_foreground);
    setState(() {});
  }

  Future<void> _unlock() async {
    final state = ref.read(profilesNotifierProvider);
    final id = state.activeProfile?.id;
    if (id == null || state.isBusy || !_foreground) return;
    final secret = _secret.text;
    _secret.clear();
    await ref
        .read(profilesNotifierProvider.notifier)
        .setActiveProfile(id, pin: secret);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profilesNotifierProvider);
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.loadFailed) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ??
                      'No se pudo abrir el almacenamiento seguro.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(profilesNotifierProvider.notifier).load(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (state.isLocked) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Galería bloqueada',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    const Text('Desbloquea el perfil activo para continuar.'),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _secret,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLength: 128,
                      enabled: _foreground && !state.isBusy,
                      decoration: const InputDecoration(
                        labelText: 'PIN o contraseña',
                      ),
                      onSubmitted: (_) => _unlock(),
                    ),
                    if (state.errorMessage != null)
                      Text(
                        state.errorMessage!,
                        semanticsLabel: state.errorMessage,
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _foreground && !state.isBusy ? _unlock : null,
                      child: Text(
                        state.isBusy ? 'Verificando…' : 'Desbloquear',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(offstage: !_foreground, child: widget.child),
        if (!_foreground) const ColoredBox(color: Colors.black),
      ],
    );
  }
}
