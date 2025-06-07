import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_bloc.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_event.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;
  
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      context.read<AuthBloc>().add(
        SignInRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: SvgPicture.asset(
                                'assets/images/logo.svg',
                                width: 100,
                                height: 100,
                              ),
                            ),
                            
                            const SizedBox(height: 16),

                            const Center(
                              child: Text(
                                '¡Bienvenido de vuelta!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.brown,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Center(
                              child: Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                            
                            TextFormField(
                              controller: _usernameController,
                              focusNode: _usernameFocus,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.username],
                              onEditingComplete: () {
                                _passwordFocus.requestFocus();
                              },
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                labelStyle: TextStyle(color: Colors.brown),
                                // Bordes redondeados pero sin línea visible
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none, // Sin línea de borde
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none, // Sin línea de borde
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none, // Sin línea de borde
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none, // Sin línea de borde
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none, // Sin línea de borde
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                prefixIcon: Icon(Icons.person, color: Colors.brown),
                                filled: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu usuario';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: _obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onEditingComplete: () {
                                TextInput.finishAutofillContext();
                                _login();
                              },
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: const TextStyle(color: Colors.brown),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                                disabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                prefixIcon: const Icon(Icons.lock, color: Colors.brown),
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword 
                                        ? Icons.visibility 
                                        : Icons.visibility_off,
                                    color: Colors.brown,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            Center(
                              child: ElevatedButton(
                                onPressed: state is AuthLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  minimumSize: const Size(120, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Center(
                              child: TextButton(
                                onPressed: () => context.go('/register'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.brown,
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '¿No tienes cuenta? ',
                                        style: TextStyle(
                                          color: Color(0xFFBEA89B),
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Regístrate',
                                        style: TextStyle(
                                          color: Colors.brown,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}