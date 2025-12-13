import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo or App Name
              const Text(
                'Interval',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Minimalist Awareness\nLogger',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey4,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'GET STARTED',
                onPress: () {
                  context.push('/onboarding/interval');
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
