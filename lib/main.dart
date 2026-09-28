import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'services/user_provider.dart';

import 'services/session_tracker.dart';
import 'services/singular_service.dart';

import 'services/remote_config_service.dart';

import 'screens/splash_screen.dart';

import 'widgets/global_balance_bar.dart';

import 'utils/constants.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();



  SystemChrome.setPreferredOrientations([

    DeviceOrientation.portraitUp,

    DeviceOrientation.portraitDown,

  ]);



  SystemChrome.setSystemUIOverlayStyle(

    const SystemUiOverlayStyle(

      statusBarColor: Colors.transparent,

      statusBarIconBrightness: Brightness.dark,

      systemNavigationBarColor: Color(0xFFF4F6FF),

      systemNavigationBarIconBrightness: Brightness.dark,

    ),

  );



  // Singular starts here and nowhere earlier so the install session is captured
  // on a cold start; on iOS it holds that session for up to 5 minutes waiting
  // for the ATT answer. The ATT prompt, AdMob and push all need the app to be
  // on screen first, so they are driven from SplashScreen instead — see
  // SplashScreen._requestPermissionsAndInitAds.
  unawaited(SingularService().initialize());
  unawaited(SessionTracker().initialize());



  // Firebase powers the server-driven feature flags. A failure here must never

  // block startup: RemoteConfigService falls back to its built-in defaults.

  try {

    await Firebase.initializeApp();

    // Not awaited: the config fetch runs over the network, and blocking here

    // would hold the first frame back on a slow connection. Flags land in their

    // ValueNotifiers as soon as the fetch returns and the UI follows.

    unawaited(RemoteConfigService().initialize());

  } catch (e) {

    debugPrint('Firebase unavailable, using default flags: $e');

  }



  runApp(const MyApp());

}



class MyApp extends StatelessWidget {

  const MyApp({super.key});



  @override

  Widget build(BuildContext context) {

    return ChangeNotifierProvider(

      create: (_) => UserProvider(),

      // Rebuilding from above the MaterialApp lets a remote change to the

      // currency wording reach every screen that reads AppStrings.currency.

      child: ValueListenableBuilder<bool>(
        valueListenable: RemoteConfigService().fullExperience,
        builder: (context, _, __) => ValueListenableBuilder<bool>(
        valueListenable: RemoteConfigService().showRobuxIcons,
        builder: (context, _, __) => ValueListenableBuilder<bool>(
        valueListenable: RemoteConfigService().showCardArtwork,
        builder: (context, _, __) => ValueListenableBuilder<bool>(
        valueListenable: RemoteConfigService().showEarnFastButton,
        builder: (context, _, __) => ValueListenableBuilder<bool>(
        valueListenable: RemoteConfigService().showRedeemFull,
        builder: (context, _, __) => ValueListenableBuilder<bool>(
        valueListenable: RemoteConfigService().showOnboarding,
        builder: (context, _, __) => ValueListenableBuilder<String>(

        valueListenable: RemoteConfigService().currencyLabel,

        builder: (context, currency, child) => MaterialApp(

        title: AppStrings.appTitle,

        debugShowCheckedModeBanner: false,

        // Sits above the Navigator so the balance and its award animation
        // survive every push, pop and dialog.
        builder: (context, child) => Stack(
          children: [
            child!,
            const GlobalBalanceBar(),
          ],
        ),

        theme: ThemeData(

          brightness: Brightness.light,

          scaffoldBackgroundColor: AppColors.darkBackground,

          primaryColor: AppColors.purple,

          fontFamily: 'Roboto',

          textTheme: const TextTheme(

            bodyLarge: TextStyle(color: AppColors.textDark),

            bodyMedium: TextStyle(color: AppColors.textDark),

            bodySmall: TextStyle(color: AppColors.textMid),

          ),

          elevatedButtonTheme: ElevatedButtonThemeData(

            style: ElevatedButton.styleFrom(

              backgroundColor: AppColors.purple,

              foregroundColor: AppColors.white,

              elevation: 5,

              shadowColor: AppColors.purple.withOpacity(0.5),

            ),

          ),

          appBarTheme: const AppBarTheme(

            backgroundColor: AppColors.cardBackground,

            elevation: 0,

            iconTheme: IconThemeData(color: AppColors.textDark),

            titleTextStyle: TextStyle(

              color: AppColors.textDark,

              fontSize: 20,

              fontWeight: FontWeight.bold,

            ),

          ),

        ),

        home: const SplashScreen(),
        ),      // MaterialApp
      ),        // currencyLabel VLB
      ),        // showOnboarding VLB
      ),        // showRedeemFull VLB
      ),        // showEarnFastButton VLB
      ),        // showCardArtwork VLB
      ),        // showRobuxIcons VLB
      ),        // fullExperience VLB
    );          // ChangeNotifierProvider
  }
}
