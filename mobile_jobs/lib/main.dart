import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile_jobs/models/job.dart'; // Add this import for Job model
import 'package:mobile_jobs/pages/landing_page.dart';
import 'package:mobile_jobs/pages/register.dart';
import 'package:mobile_jobs/pages/login.dart';
import 'package:mobile_jobs/services/local_storage_service.dart';
import 'package:mobile_jobs/pages/home.dart';
import 'package:mobile_jobs/pages/profile.dart';
import 'package:mobile_jobs/pages/job_details.dart';
import 'firebase_options.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling a background message: ${message.messageId}');
//   // You can handle background messages here, such as displaying notifications or saving data.
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorageService.init();

  // // Request notification permissions (for iOS)
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // await messaging.requestPermission();

  // // Handle foreground notifications
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Received a message while the app is in the foreground: ${message.notification?.title}');
  //   // Show a notification when the app is in the foreground
  //   // For now, just print the title
  // });

  // // Handle background and terminated state notifications
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFdc2f02),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFdc2f02),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/signup': (context) => const SignUPPage(),
        '/signin': (context) => const SignInPage(),
        '/home': (context) => const JobSeekerHomePage(),
        '/profile': (context) => const ProfilePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/job_details':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => JobDetailsPage(
                job: args['job'] as Job,
                isApplied: args['isApplied'] as bool,
                onApply: args['onApply'] as Future<void> Function(),
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
