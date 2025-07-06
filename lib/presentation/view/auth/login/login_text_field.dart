// ignore_for_file: prefer_const_constructors

part of 'login_view.dart';

class _LoginViewTextField extends StatelessWidget {
  const _LoginViewTextField({
    required this.controller,
    required this.hintText,
    required this.isSecure,
    this.textInputType, this.suffixIcon});
  final TextEditingController controller;
  final String hintText;
  final bool isSecure;
  final TextInputType? textInputType;
  final Widget? suffixIcon;
  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
    child: TextField(
      textAlign: TextAlign.center,
      keyboardType: textInputType,
      controller: controller,
      obscureText: isSecure && context.watch<AuthenticationProvider>().obsecurePassword,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        hintText: hintText,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: suffixIcon != null ? context.dynamicWidth(0.12) : context.dynamicWidth(0.04),
          vertical: context.dynamicWidth(0.04) // Dikey padding de dinamik
        ),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}