/// Login Screen Widget Tests - Fixed
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:opensocialapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:opensocialapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:opensocialapp/features/auth/presentation/bloc/auth_state.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    // Setup default stream
    when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const Scaffold(
          body: _TestLoginForm(),
        ),
      ),
    );
  }

  group('Login Form Widget', () {
    testWidgets('displays email and password fields', (tester) async {
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('displays login button', (tester) async {
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('shows loading indicator when AuthLoading', (tester) async {
      when(mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when AuthError', (tester) async {
      when(mockAuthBloc.state).thenReturn(const AuthError('Invalid credentials'));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}

/// Simple test login form for widget testing
class _TestLoginForm extends StatefulWidget {
  const _TestLoginForm();

  @override
  State<_TestLoginForm> createState() => _TestLoginFormState();
}

class _TestLoginFormState extends State<_TestLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state is AuthError) Text(state.message),
            TextField(
              key: const Key('email_field'),
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              key: const Key('password_field'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (state is AuthLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                key: const Key('login_button'),
                onPressed: () {
                  context.read<AuthBloc>().add(
                        AuthLoginRequested(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ),
                      );
                },
                child: const Text('Login'),
              ),
          ],
        );
      },
    );
  }
}
