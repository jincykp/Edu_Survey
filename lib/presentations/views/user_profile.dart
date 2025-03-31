import 'package:edusurvey/core/theme/colors.dart';
import 'package:edusurvey/data/model/user_model.dart';
import 'package:edusurvey/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      body:
          user == null
              ? const Center(child: Text('No user data available'))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header with gradient background
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AllColors.primaryColor,
                            AllColors.gradientSecond,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 60,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  color: AllColors.gradientSecond,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // User details section with cards
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personal Information Card
                          _buildSectionCard(
                            context,
                            'Personal Information',
                            Icons.person,
                            [
                              _buildInfoRow(context, 'Name', user.name),
                              _buildInfoRow(context, 'Email', user.email),
                              // Add more fields as needed
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Account Actions Card
                          _buildSectionCard(
                            context,
                            'Account Settings',
                            Icons.settings,
                            [
                              _buildActionRow(
                                context,
                                'Edit Profile',
                                Icons.edit,
                                () {
                                  // Navigate to edit profile
                                },
                              ),
                              _buildActionRow(
                                context,
                                'Change Password',
                                Icons.lock_outline,
                                () {
                                  // Navigate to change password
                                },
                              ),
                              _buildActionRow(
                                context,
                                'Privacy Settings',
                                Icons.privacy_tip_outlined,
                                () {
                                  // Navigate to privacy settings
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Sign Out Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Sign Out'),
                                        content: const Text(
                                          'Are you sure you want to sign out?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AllColors.gradientThird,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              final userProvider =
                                                  Provider.of<UserProvider>(
                                                    context,
                                                    listen: false,
                                                  );

                                              // Call the signOut method
                                              userProvider.signOut();

                                              // Close the dialog
                                              Navigator.pop(context);

                                              // Exit the app
                                              SystemNavigator.pop();
                                            },
                                            child: const Text(
                                              'Sign Out',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AllColors.primaryColor,
                                                fontSize: 18,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[50],
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.red.shade200),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AllColors.gradientSecond, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AllColors.gradientThird),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
