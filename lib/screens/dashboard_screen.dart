import 'package:flutter/material.dart';
import '../services/mock_auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.errorRed),
            SizedBox(width: 8),
            Text('Confirm Logout', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text('Are you sure you want to log out of SFMS?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              minimumSize: const Size(90, 40),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              MockAuthService.instance.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showFeatureNotice(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Flexible(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Text(
          '$title module will be connected in the next milestone. Frontend authentication & navigation is currently active.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = MockAuthService.instance.currentUser;
    final farmerName = currentUser?.name.isNotEmpty == true
        ? currentUser!.name
        : 'Farmer';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.agriculture_rounded,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'SFMS Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.primaryGreenDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                farmerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Farm Status: Optimal',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        Text(
                          'Records synced',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Overview Section Title
              const Text(
                'Livestock Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Summary 2x2 Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: const [
                  _SummaryStatCard(
                    title: 'Total Livestock',
                    value: '48',
                    subtitle: 'Cattle, Goats, Sheep',
                    icon: Icons.pets_rounded,
                    color: AppTheme.primaryGreen,
                  ),
                  _SummaryStatCard(
                    title: 'Healthy Animals',
                    value: '45',
                    subtitle: '93.7% in good health',
                    icon: Icons.health_and_safety_rounded,
                    color: AppTheme.successGreen,
                  ),
                  _SummaryStatCard(
                    title: 'Vaccinations Due',
                    value: '3',
                    subtitle: 'Due within 7 days',
                    icon: Icons.vaccines_rounded,
                    color: AppTheme.accentGold,
                  ),
                  _SummaryStatCard(
                    title: 'Feeding Schedule',
                    value: '4/4',
                    subtitle: 'Evening cycle at 5 PM',
                    icon: Icons.restaurant_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Quick Actions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '6 modules',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  _QuickActionTile(
                    title: 'Add Livestock',
                    icon: Icons.add_circle_outline_rounded,
                    color: AppTheme.primaryGreen,
                    onTap: () => _showFeatureNotice(context, 'Add Livestock'),
                  ),
                  _QuickActionTile(
                    title: 'Health Record',
                    icon: Icons.medical_services_outlined,
                    color: const Color(0xFFDC2626),
                    onTap: () => _showFeatureNotice(context, 'Health Record'),
                  ),
                  _QuickActionTile(
                    title: 'Feeding',
                    icon: Icons.fastfood_outlined,
                    color: const Color(0xFFD97706),
                    onTap: () => _showFeatureNotice(context, 'Feeding Schedule'),
                  ),
                  _QuickActionTile(
                    title: 'Vaccination',
                    icon: Icons.shield_outlined,
                    color: const Color(0xFF2563EB),
                    onTap: () =>
                        _showFeatureNotice(context, 'Vaccination Schedule'),
                  ),
                  _QuickActionTile(
                    title: 'Breeding',
                    icon: Icons.favorite_border_rounded,
                    color: const Color(0xFF9333EA),
                    onTap: () => _showFeatureNotice(context, 'Breeding Records'),
                  ),
                  _QuickActionTile(
                    title: 'Production',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF0D9488),
                    onTap: () =>
                        _showFeatureNotice(context, 'Production Records'),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Upcoming Notifications / Reminders Preview
              const Text(
                'Upcoming Reminders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              _ReminderTile(
                icon: Icons.vaccines_rounded,
                iconColor: AppTheme.accentGold,
                title: 'FMD Booster Vaccination',
                subtitle: 'Cow #C-104, #C-108 scheduled for tomorrow',
                time: 'Tomorrow, 9:00 AM',
                onTap: () => _showFeatureNotice(context, 'Vaccination Reminder'),
              ),
              const SizedBox(height: 10),
              _ReminderTile(
                icon: Icons.restaurant_rounded,
                iconColor: const Color(0xFF2563EB),
                title: 'Evening Silage Feeding',
                subtitle: 'Section B (Dairy cows) ration delivery',
                time: 'Today, 5:30 PM',
                onTap: () => _showFeatureNotice(context, 'Feeding Reminder'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback onTap;

  const _ReminderTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
