import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';

// Services
import 'services/hive_service.dart';
import 'services/booking_service.dart';
import 'services/loyalty_service.dart';
import 'services/pricing_service.dart';
import 'services/random_data_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.init();

  // Optionally seed sample data (comment out after first run if you want to keep data)
  // await HiveService.seedSampleData();

  // Generate random data at startup (optional - comment out if not needed)
  await RandomDataGenerator.initializeRandomData(
    salonCount: 10,
    stylistCount: 20,
    treatmentCount: 15,
    appointmentCount: 0, // Set to 0 until user logs in
    userId: null, // Will be set after login
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingService()),
        ChangeNotifierProvider(create: (_) => LoyaltyService()),
        ChangeNotifierProvider(create: (_) => PricingService()),
        // Add more providers here as needed
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Salon Connect',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/customer-home': (context) => const CustomerHomeScreen(),
            '/admin-home': (context) => const AdminHomeScreen(),
          },
        ),
      ),
    );
  }
}

// Auth Wrapper to handle initial routing based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check if user is logged in
        if (authProvider.isAuthenticated) {
          // Check user role and navigate accordingly
          if (authProvider.isAdmin) {
            return const AdminHomeScreen();
          } else {
            return const CustomerHomeScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
