import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Done', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: context.dynamicHeight(0.05),
                backgroundColor: Colors.orange,
                child: Text('👦', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 10),
              const Text('Bilal Çavuş', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 4),
              const Text('bilalcavus01@gmail.com', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              Card(
                color: const Color(0xFF181818),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: 5 / 6,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          strokeWidth: 5,
                        ),
                      ),
                      const Text('5/6', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  title: const Text('Checklist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Finish your remaining tasks', style: TextStyle(color: Colors.grey)),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _settingsTile(Iconsax.user, 'Personal Information'),
        _settingsTile(Iconsax.location, 'Address'),
        _settingsTile(Iconsax.lock, 'Account Password'),
        _subscriptionTile(),
        _settingsTile(Iconsax.shopping_cart, 'Programs', trailing: const Text('2', style: TextStyle(color: Colors.white))),
        _settingsTile(Iconsax.clock, 'Program History'),
        _settingsTile(Iconsax.shield, 'Privacy Policy'),
        _settingsTile(Iconsax.document, 'Terms and Conditions'),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title, {Widget? trailing}) {
    return Card(
      color: const Color(0xFF181818),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _subscriptionTile() {
    return Card(
      color: const Color(0xFF181818),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Iconsax.card, color: Colors.green),
        title: const Text('Manage Subscription', style: TextStyle(color: Colors.white)),
        subtitle: const Text('Program', style: TextStyle(color: Colors.grey)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        onTap: () {},
      ),
    );
  }
}