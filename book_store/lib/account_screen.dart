import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AccountScreen extends StatelessWidget {
  bool name = false;

  AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4C57D6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                          'assets/avatar.png'), // Add an avatar image to your assets
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sahil Maharnawar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '@sahilmaharnawar',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.edit, color: Colors.white),
                  ],
                ),
              ),
            ),

            // Account Options
            buildSection([
              buildListTile(
                  icon: Icons.person_outline,
                  title: "My Account",
                  subtitle: "Make changes to your account",
                  trailingIcon: Icons.warning_amber_rounded,
                  trailingColor: Colors.red),
              buildListTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Download",
                  subtitle: "See your download Books"),
              buildListTile(
                  icon: Icons.logout,
                  title: "Log out",
                  subtitle: "Further secure your account for safety"),
            ]),

            const SizedBox(height: 16),

            // More Section
            buildSection([
              buildListTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  subtitle: ""),
              buildListTile(
                  icon: Icons.info_outline, title: "About App", subtitle: ""),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget buildListTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      IconData? trailingIcon,
      Color? trailingColor}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailingIcon != null
          ? Icon(trailingIcon, color: trailingColor ?? Colors.grey)
          : const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget buildSwitchTile(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: name,
      onChanged: (value) {},
    );
  }
}
