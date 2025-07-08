// ignore_for_file: prefer_const_constructors

part of 'login_view.dart';

class _LoginViewButton extends StatelessWidget {
  const _LoginViewButton();
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthenticationProvider>();
    return TextButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        await provider.handleLogin(context);
        RouteHelper.pushAndCloseOther(context, AppNavigation());
      },
        child: provider.isLoading ? Container(
          height: MediaQuery.of(context).size.height * 0.055,
          decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Lottie.asset('assets/lotties/mind-flow-loading.json', width: 200, height: 90),
          ),
        ) : Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.057,
        decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20)),
          child: Center(
          child: Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
      ),
    ),
        );
  }
}