import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_constants.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBarWidget(title: 'Dongeng Anak Nusantara'),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📖 Selamat Datang!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Temukan dongeng seru dari seluruh Nusantara untuk si kecil.',
                    style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.9))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                      ),
                      onPressed: () => context.go(RouteConstants.dongeng),
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Baca Dongeng'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        side: BorderSide(color: colorScheme.onPrimary),
                      ),
                      onPressed: () => context.go(RouteConstants.plants),
                      child: const Text('Plants'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Kategori Dongeng
          Text('Kategori Dongeng', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _CategoryCard(emoji: '🏰', label: 'Legenda', color: colorScheme.primaryContainer),
              _CategoryCard(emoji: '🐰', label: 'Fabel', color: colorScheme.secondaryContainer),
              _CategoryCard(emoji: '👸', label: 'Dongeng Klasik', color: colorScheme.tertiaryContainer ?? colorScheme.primaryContainer),
              _CategoryCard(emoji: '🌊', label: 'Mitos', color: colorScheme.surfaceContainerHighest),
            ],
          ),
          const SizedBox(height: 24),

          // Info card
          Card(
            color: colorScheme.surface,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('🌟 Dongeng Anak Nusantara 🌟',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text(
                    'Aplikasi koleksi dongeng anak dari seluruh Indonesia. '
                        'Kenalkan budaya dan nilai moral kepada anak melalui cerita yang menarik.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.emoji, required this.label, required this.color});
  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}