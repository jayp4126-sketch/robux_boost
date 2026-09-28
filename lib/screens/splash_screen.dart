import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../services/push_service.dart';
import '../services/singular_service.dart';
import '../services/user_provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'welcome_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _checkFirstTime();

    // Everything that needs a live, on-screen app waits for the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionsAndInitAds();
    });
  }

  /// Consent first, then the SDKs that depend on it.
  ///
  /// The order matters on iOS. ATT has to come before AdMob is initialised, or
  /// the Mobile Ads SDK starts up without the IDFA and can only serve
  /// non-personalised ads for the rest of the session. Push asks last because
  /// iOS presents one system dialog at a time and silently drops a second one
  /// raised while the first is up.
  ///
  /// The splash sits here for 3 seconds before navigating, which is the window
  /// this runs in. Ads still get that time to load before MainScreen appears.
  Future<void> _requestPermissionsAndInitAds() async {
    await SingularService().requestTrackingAuthorization();
    await AdService().initialize();
    await PushService().initialize();
  }

  Future<void> _checkFirstTime() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final storageService = StorageService();
    final isFirstTime = await storageService.isFirstTime();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();

    if (!mounted) return;

    final needsOnboarding = isFirstTime || userProvider.user == null;

    if (needsOnboarding && !AppStrings.showOnboarding) {
      // Restricted mode skips onboarding entirely, so make sure the account
      // the rest of the app depends on still exists.
      if (userProvider.user == null) {
        await userProvider.createUser(AppStrings.welcomeMessage);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
      return;
    }

    if (needsOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } else {
      await userProvider.updateStreak();
      await userProvider.resetDailyLimits();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.purple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      AppStrings.currency,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Earn Coins, Play Games!',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
