import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Cloud Host'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              icon: Icons.code,
              title: 'محرر الأكواد',
              subtitle: 'استضافة مواقع الويب',
              color: Colors.blue,
              onTap: () {
                // TODO: الانتقال إلى محرر الأكواد
              },
            ),
            _buildFeatureCard(
              context,
              icon: Icons.smart_toy,
              title: 'بوتات تيليجرام',
              subtitle: 'تشغيل البوتات محلياً',
              color: Colors.cyan,
              onTap: () {
                // TODO: الانتقال إلى إدارة البوتات
              },
            ),
            _buildFeatureCard(
              context,
              icon: Icons.folder,
              title: 'إدارة الملفات',
              subtitle: 'تخزين ومشاركة الملفات',
              color: Colors.orange,
              onTap: () {
                // TODO: الانتقال إلى مدير الملفات
              },
            ),
            _buildFeatureCard(
              context,
              icon: Icons.link,
              title: 'الأنفاق الحية',
              subtitle: 'روابط عامة بمؤقت تدمير',
              color: Colors.green,
              onTap: () {
                // TODO: الانتقال إلى إدارة الأنفاق
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}