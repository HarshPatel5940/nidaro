import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock business profile data
  final Map<String, dynamic> _profileData = {
    'lgnm': 'Sri Shanker Vijaya Saw Mills',
    'tradeNam': 'Sri Shanker Vijaya Saw Mills',
    'gstin': '33AABFS0153K1ZH',
    'ctb': 'Partnership',
    'rgdt': '01/07/2017',
    'dty': 'Regular',
    'sts': 'Active',
    'pradr':
        'Old 195/ New 335, Sydenhams Road, Apparao Garden, Choolai, Chennai, Tamil Nadu, 600112',
    'nba': [
      'Office / Sale Office',
      'Retail Business',
      'Wholesale Business',
      'Warehouse / Depot',
      'Others',
    ],
    'stj':
        'State - Tamil Nadu, Division - CHENNAI NORTH, Zone - North-III, Circle - CHOOLAI (Jurisdictional Office)',
    'ctj':
        'State - CBIC, Zone - CHENNAI, Commissionerate - CHENNAI-NORTH, Division - PARRYS, Range - RANGE V',
    'adhrVFlag': 'Yes',
    'adhrVdt': '24/04/2025',
    'ekycVFlag': 'Not Applicable',
    'einvoiceStatus': 'No',
    'isFieldVisitConducted': 'No',
  };

  void _handleLogout() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // Navigate to login screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(color: AppColors.googleRed),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildBusinessDetails(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildSupportSection(),
          const SizedBox(height: 40),
          Center(
            child: TextButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: AppColors.googleRed),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.googleRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return FadeInDown(
      duration: AppDurations.fast,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.googleBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _profileData['lgnm'].substring(0, 2),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.googleBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profileData['lgnm'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 14,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _profileData['gstin'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _profileData['sts'] == 'Active'
                              ? AppColors.googleGreen.withOpacity(0.1)
                              : AppColors.googleRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      _profileData['sts'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            _profileData['sts'] == 'Active'
                                ? AppColors.googleGreen
                                : AppColors.googleRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Edit profile - just a mock functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature is not available yet.'),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.googleBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetails() {
    return FadeInUp(
      duration: AppDurations.fast,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Business Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.googleBlue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Share business profile - just a mock functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Business profile shared successfully'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                  iconSize: 20,
                  color: AppColors.googleBlue,
                ),
              ],
            ),
            const Divider(),

            // Business details
            _buildDetailRow('Legal Name (lgnm)', _profileData['lgnm']),
            _buildDetailRow('Trade Name (tradeNam)', _profileData['tradeNam']),
            _buildDetailRow('GSTIN (gstin)', _profileData['gstin']),
            _buildDetailRow(
              'Constitution of Business (ctb)',
              _profileData['ctb'],
            ),
            _buildDetailRow(
              'Date of Registration (rgdt)',
              _profileData['rgdt'],
            ),
            _buildDetailRow('Taxpayer Type (dty)', _profileData['dty']),
            _buildDetailRow('Status (sts)', _profileData['sts']),
            _buildDetailRow('Principal Address (pradr)', _profileData['pradr']),

            // Nature of Business Activities
            const SizedBox(height: 8),
            const Text(
              'Nature of Business Activities (nba):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  (_profileData['nba'] as List<String>).map((activity) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(activity)),
                        ],
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 8),
            _buildDetailRow('State Jurisdiction (stj)', _profileData['stj']),
            _buildDetailRow('Central Jurisdiction (ctj)', _profileData['ctj']),
            _buildDetailRow(
              'Aadhaar Verification Flag (adhrVFlag)',
              _profileData['adhrVFlag'],
            ),
            _buildDetailRow(
              'Aadhaar Verification Date (adhrVdt)',
              _profileData['adhrVdt'],
            ),
            _buildDetailRow(
              'e-KYC Verification Flag (ekycVFlag)',
              _profileData['ekycVFlag'],
            ),
            _buildDetailRow(
              'e-Invoice Status (einvoiceStatus)',
              _profileData['einvoiceStatus'],
            ),
            _buildDetailRow(
              'Is Field Visit Conducted (isFieldVisitConducted)',
              _profileData['isFieldVisitConducted'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return FadeInUp(
      duration: AppDurations.medium,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.googleBlue,
              ),
            ),
            const Divider(),
            _buildSettingItem(
              'Notifications',
              'Manage your notification preferences',
              Icons.notifications_outlined,
            ),
            _buildSettingItem(
              'Privacy',
              'Control your data and privacy settings',
              Icons.privacy_tip_outlined,
            ),
            _buildSettingItem(
              'Security',
              'Password and security settings',
              Icons.security_outlined,
            ),
            _buildSettingItem(
              'Language',
              'Change app language',
              Icons.language_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return FadeInUp(
      duration: AppDurations.slow,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.googleBlue,
              ),
            ),
            const Divider(),
            _buildSettingItem(
              'Help Center',
              'Get help with using the app',
              Icons.help_outline,
            ),
            _buildSettingItem(
              'Contact Us',
              'Reach out to our support team',
              Icons.support_agent_outlined,
            ),
            _buildSettingItem(
              'Terms & Conditions',
              'Read our terms and conditions',
              Icons.description_outlined,
            ),
            _buildSettingItem(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.policy_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon) {
    return InkWell(
      onTap: () {
        // Mock functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title functionality is not available yet.')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.googleBlue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}
