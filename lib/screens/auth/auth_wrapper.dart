import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../home_screen.dart';
import 'login_screen.dart';

/// AuthWrapper listens to the authentication state from AuthProvider
/// and dynamically directs the user to either the HomeScreen or the LoginScreen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Schedule reloading of user data whenever the authentication state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ExpenseProvider>().loadExpenses();
        context.read<BudgetProvider>().loadBudgets();
      }
    });

    // If the auth provider is checking initial authentication state, show a splash loading screen
    if (authProvider.isLoading && authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Direct user according to authentication state
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

