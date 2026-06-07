import 'dart:ui';
import 'package:app/core/services/api_service.dart';
import 'package:app/router/app_router.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _gender = 'male';
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await ApiService().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        gender: _gender,
      );
      if (mounted) {
        AppRouter.isAuthenticated = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text('Bem-vindo ao Koin, ${user.name}!',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(
                e.toString().replaceAll('Exception: ', ''),
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
            ]),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
              top: -80,
              right: -80,
              child: _GlowOrb(
                  color: AppTheme.secondary.withAlpha(30), size: 280)),
          Positioned(
              bottom: -80,
              left: -80,
              child: _GlowOrb(
                  color: AppTheme.primary.withAlpha(38), size: 260)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white70, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withAlpha(38),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.secondary.withAlpha(51)),
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded,
                            size: 40, color: AppTheme.secondary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Criar conta',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Comece a gerenciar suas finanças agora',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(153)),
                      ),
                      const SizedBox(height: 32),

                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: Colors.white.withAlpha(20)),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  _buildInputField(
                                    controller: _nameController,
                                    label: 'Nome completo',
                                    hint: 'Seu nome',
                                    icon: Icons.person_outline_rounded,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Informe seu nome';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                    controller: _emailController,
                                    label: 'E-mail',
                                    hint: 'nome@exemplo.com',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Informe seu e-mail';
                                      }
                                      if (!v.contains('@')) {
                                        return 'E-mail inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                    controller: _passwordController,
                                    label: 'Senha',
                                    hint: 'Mínimo 6 caracteres',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons
                                                .visibility_off_outlined,
                                        color: Colors.white54,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.length < 6) {
                                        return 'Senha deve ter pelo menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Gênero',
                                          style: TextStyle(
                                              color:
                                                  Colors.white.withAlpha(179),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(15),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                              color:
                                                  Colors.white.withAlpha(25)),
                                        ),
                                        child: Row(
                                          children: [
                                            _GenderChip(
                                                label: 'Masculino',
                                                value: 'male',
                                                selected: _gender == 'male',
                                                onTap: () => setState(
                                                    () => _gender = 'male')),
                                            _GenderChip(
                                                label: 'Feminino',
                                                value: 'female',
                                                selected:
                                                    _gender == 'female',
                                                onTap: () => setState(() =>
                                                    _gender = 'female')),
                                            _GenderChip(
                                                label: 'Outro',
                                                value: 'other',
                                                selected:
                                                    _gender == 'other',
                                                onTap: () => setState(() =>
                                                    _gender = 'other')),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),

                                  _GradientButton(
                                    label: 'Criar conta',
                                    icon: Icons.check_rounded,
                                    isLoading: _isLoading,
                                    onPressed: _register,
                                    gradientColors: [
                                      AppTheme.secondary,
                                      const Color(0xFF0891B2)
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Já tem uma conta? ',
                                        style: TextStyle(
                                            color: Colors.white
                                                .withAlpha(128),
                                            fontSize: 14),
                                      ),
                                      GestureDetector(
                                        onTap: () => context.pop(),
                                        child: const Text(
                                          'Entrar',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black.withAlpha(128),
                  child: const Center(
                    child: Card(
                      color: Color(0xFF151B2C),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 36, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.secondary),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Criando sua conta...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
            prefixIcon:
                Icon(icon, color: Colors.white.withAlpha(102), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withAlpha(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withAlpha(25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withAlpha(25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.secondary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.danger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.danger, width: 1.5),
            ),
            errorStyle:
                const TextStyle(color: AppTheme.danger, fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox(),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.secondary.withAlpha(51)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: AppTheme.secondary.withAlpha(153))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppTheme.secondary : Colors.white54,
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;
  final List<Color> gradientColors;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(77),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(width: 8),
                  Icon(icon, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}
