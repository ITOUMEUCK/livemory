import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/buttons/buttons.dart';
import '../providers/auth_provider.dart';

/// Login screen avec email/password et auth sociale
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        context.showSuccessSnackBar('Connexion réussie !');
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        context.showErrorSnackBar(
          authProvider.errorMessage ?? 'Erreur de connexion',
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Erreur de connexion: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final bool success;
      
      if (provider == 'Google') {
        success = await authProvider.signInWithGoogle();
      } else if (provider == 'Apple') {
        success = await authProvider.signInWithApple();
      } else {
        success = false;
      }

      if (!mounted) return;

      if (success) {
        context.showSuccessSnackBar('Connexion $provider réussie !');
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        context.showErrorSnackBar(
          authProvider.errorMessage ?? 'Erreur $provider',
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Erreur $provider: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.event_available,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Text(
                'Content de te revoir ! 👋',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Connecte-toi pour retrouver tes amis',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      validator: Validators.email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'ton@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusM,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !_isLoading,
                      onFieldSubmitted: (_) => _handleEmailLogin(),
                      validator: Validators.required,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusM,
                          ),
                        ),
                      ),
                    ),

                    // Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                // TODO: Navigation vers forgot password
                                context.showInfoSnackBar(
                                  'Fonctionnalité bientôt disponible',
                                );
                              },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Bouton connexion
                    PrimaryButton(
                      text: 'Se connecter',
                      onPressed: _handleEmailLogin,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Divider "OU"
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OU',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),

              // Authentification sociale
              _SocialButton(
                icon: Icons.g_mobiledata,
                label: 'Continuer avec Google',
                onPressed: _isLoading
                    ? null
                    : () => _handleSocialLogin('Google'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
              const SizedBox(height: 12),

              _SocialButton(
                icon: Icons.apple,
                label: 'Continuer avec Apple',
                onPressed: _isLoading
                    ? null
                    : () => _handleSocialLogin('Apple'),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),

              const SizedBox(height: 40),

              // Lien inscription
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Pas encore de compte ? '),
                      TextSpan(
                        text: 'Inscris-toi',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _isLoading
                              ? null
                              : () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.register);
                                },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton d'authentification sociale
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
          ),
          side: BorderSide(color: AppColors.textTertiary.withOpacity(0.2)),
        ),
      ),
    );
  }
}
