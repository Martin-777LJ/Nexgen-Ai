import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'views/drawer.dart';
import 'views/desktop_view.dart';
import 'provider/main_provider.dart';
import 'utils/platform_utils.dart';

//--------------------------------------------------------------------------//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MainProvider()),
    ],
    child: EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ko', 'KR'),
          Locale('ja', 'JP')
        ],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        child: MyOllama()),
  ));
}

class MyOllama extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
          primary: Colors.orangeAccent,
          surface: const Color(0xFF121212),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      ),
      home: const InitializationWrapper(),
    ); // <--- ENSURE THIS PARENTHESIS AND SEMICOLON ARE HERE
  }
} // <--- ENSURE THIS CLOSING BRACE IS HERE


  Future<void> setLocale(BuildContext context) async {
    String currentLocale = Intl.getCurrentLocale();
    List<String> parts = currentLocale.split('_');

    switch (parts[0]) {
      case 'ko':
        context.setLocale(const Locale('ko', 'KR'));
        break;
      case 'ja':
        context.setLocale(const Locale('ja', 'JP'));
        break;
      default:
        context.setLocale(const Locale('en', 'US'));
        break;
    }
  }

  Future<void> _initializeApp() async {
    final provider = Provider.of<MainProvider>(context, listen: false);
    await provider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(provider.serveConnected
                          ? 'Initializing...'
                          : 'Setting up local server...')
                      .tr(),
                ],
              ),
            ),
          );
        }

        return isDesktopOrTablet() ? DesktopView() : MyDrawer();
      },
    );
  }
}
