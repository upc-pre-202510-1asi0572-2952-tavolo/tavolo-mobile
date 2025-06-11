import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tavolo_mobile/conf/api_client.dart';
import 'package:tavolo_mobile/data/repositories/auth_repository.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_bloc.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_event.dart';
import 'package:tavolo_mobile/routes/router.dart';
import 'package:tavolo_mobile/storage/secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuración de dependencias
    final secureStorage = SecureStorage(
      storage: const FlutterSecureStorage(),
    );
    
    final apiClient = ApiClient(
      httpClient: http.Client(),
      secureStorage: secureStorage,
      baseUrl: 'http://10.0.2.2:8080', // Cambia a 10.0.2.2 para emulador Android
    );
    
    final authRepository = AuthRepository(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );
    
    final authBloc = AuthBloc(
      authRepository: authRepository,
    )..add(AuthCheckRequested());
    
    final appRouter = AppRouter(authBloc: authBloc);


    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: MaterialApp.router(
        title: 'Tavolo Mobile',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.router,
      ),
    );
  }
}