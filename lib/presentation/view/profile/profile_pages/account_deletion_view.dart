import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_alert_dialog.dart';

class AccountDeletionView extends StatefulWidget {
  const AccountDeletionView({super.key});

  @override
  State<AccountDeletionView> createState() => _AccountDeletionViewState();
}

class _AccountDeletionViewState extends State<AccountDeletionView> {
  final AuthenticationProvider _provider = AuthenticationProvider(getIt());
  
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _understandConsequences = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'delete_account'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.05),
            vertical: context.dynamicHeight(0.02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWarningCard(),
              SizedBox(height: context.dynamicHeight(0.03)),
              _buildConsequencesCard(),
              SizedBox(height: context.dynamicHeight(0.03)),
              _buildConfirmationForm(),
              SizedBox(height: context.dynamicHeight(0.04)),
              _buildDeleteButton(),
              SizedBox(height: context.dynamicHeight(0.02)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.warning_2,
            color: Colors.red,
            size: context.dynamicHeight(0.03),
          ),
          SizedBox(width: context.dynamicWidth(0.03)),
          Expanded(
            child: Text(
              'delete_account_warning'.tr(),
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: context.dynamicHeight(0.018),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsequencesCard() {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color: Colors.orange,
                size: context.dynamicHeight(0.025),
              ),
              SizedBox(width: context.dynamicWidth(0.02)),
              Expanded(
                child: Text(
                  'deletion_consequences'.tr(),
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: context.dynamicHeight(0.018),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          _buildConsequenceItem('all_data_permanent'.tr()),
          _buildConsequenceItem('analysis_history_lost'.tr()),
          _buildConsequenceItem('subscription_cancelled'.tr()),
          _buildConsequenceItem('cannot_recover'.tr()),
        ],
      ),
    );
  }

  Widget _buildConsequenceItem(String text) {
    return Padding(
      padding: EdgeInsets.only(left: context.dynamicWidth(0.02)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.remove,
            color: Colors.orange,
            size: context.dynamicHeight(0.018),
          ),
          SizedBox(width: context.dynamicWidth(0.02)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.orange.withOpacity(0.8),
                fontSize: context.dynamicHeight(0.016),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationForm() {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'confirm_deletion'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: context.dynamicHeight(0.02),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'current_password'.tr(),
              // labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                // borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                // borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          
          // Confirmation text field
          TextFormField(
            controller: _confirmationController,
            decoration: InputDecoration(
              labelText: 'type_delete_confirmation'.tr(),
              // labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                // borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          
          // Checkboxes
          CheckboxListTile(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            title: Text(
              'agree_to_deletion'.tr(),
              style: TextStyle(
                fontSize: context.dynamicHeight(0.016),
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.red,
          ),
          
          CheckboxListTile(
            value: _understandConsequences,
            onChanged: (value) {
              setState(() {
                _understandConsequences = value ?? false;
              });
            },
            title: Text(
              'understand_consequences'.tr(),
              style: TextStyle(
                fontSize: context.dynamicHeight(0.016),
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    final isFormValid = _passwordController.text.isNotEmpty &&
        _confirmationController.text.toLowerCase() == 'delete' &&
        _agreeToTerms &&
        _understandConsequences;

    return SizedBox(
      width: double.infinity,
      height: context.dynamicHeight(0.06),
      child: ElevatedButton(
        onPressed: isFormValid && !_isLoading ? _showFinalConfirmation : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: context.dynamicHeight(0.025),
                width: context.dynamicHeight(0.025),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'delete_account_permanently'.tr(),
                style: TextStyle(
                  fontSize: context.dynamicHeight(0.018),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _showFinalConfirmation() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'final_confirmation'.tr(),
        content: 'final_confirmation_message'.tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount();
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _provider.handleAccountDeletion(
        context,
        password: _passwordController.text,
      );
      
      if (mounted) {
        RouteHelper.pushAndCloseOther(context, const LoginView());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('deletion_error'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}