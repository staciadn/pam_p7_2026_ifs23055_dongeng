import 'package:flutter/material.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopAppBarWidget(title: 'Profil'),
      body: _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: colorScheme.primary,
                  child: ClipOval(
                    child: Image.asset('assets/images/profile.png',
                        width: 110, height: 110, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.person, size: 60, color: colorScheme.onPrimary)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('ifs23055', style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Mahasiswa Informatika',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text('Tentang Saya', style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Mahasiswa yang sedang belajar Flutter dan pengembangan aplikasi mobile. '
                      'Suka dengan dongeng dan cerita rakyat Nusantara.',
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}