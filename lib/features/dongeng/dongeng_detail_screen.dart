import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_constants.dart';
import '../../data/models/dongeng_model.dart';
import '../../providers/dongeng_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class DongengDetailScreen extends StatefulWidget {
  const DongengDetailScreen({super.key, required this.dongengId});
  final String dongengId;

  @override
  State<DongengDetailScreen> createState() => _DongengDetailScreenState();
}

class _DongengDetailScreenState extends State<DongengDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DongengProvider>().loadDongengById(widget.dongengId);
    });
  }

  Future<void> _confirmDelete(BuildContext context, DongengProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dongeng'),
        content: const Text('Yakin ingin menghapus dongeng ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final success = await provider.removeDongeng(widget.dongengId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dongeng berhasil dihapus.')));
        context.go(RouteConstants.dongeng);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DongengProvider>(
      builder: (context, provider, _) {
        if (provider.status == DongengStatus.loading ||
            provider.status == DongengStatus.initial) {
          return Scaffold(
              appBar: const TopAppBarWidget(title: 'Detail Dongeng', showBackButton: true),
              body: const LoadingWidget());
        }
        if (provider.status == DongengStatus.error) {
          return Scaffold(
              appBar: const TopAppBarWidget(title: 'Detail Dongeng', showBackButton: true),
              body: AppErrorWidget(
                  message: provider.errorMessage,
                  onRetry: () => provider.loadDongengById(widget.dongengId)));
        }
        final dongeng = provider.selectedDongeng;
        if (dongeng == null) {
          return Scaffold(
              appBar: const TopAppBarWidget(title: 'Detail Dongeng', showBackButton: true),
              body: const Center(child: Text('Data tidak ditemukan.')));
        }
        return Scaffold(
          appBar: TopAppBarWidget(
            title: dongeng.judul,
            showBackButton: true,
            menuItems: [
              TopAppBarMenuItem(
                text: 'Edit', icon: Icons.edit_outlined,
                onTap: () async {
                  final edited = await context.push<bool>(RouteConstants.dongengEdit(dongeng.id!));
                  if (edited == true && context.mounted) provider.loadDongengById(widget.dongengId);
                },
              ),
              TopAppBarMenuItem(
                text: 'Hapus', icon: Icons.delete_outline, isDestructive: true,
                onTap: () => _confirmDelete(context, provider),
              ),
            ],
          ),
          body: _DongengDetailBody(dongeng: dongeng),
        );
      },
    );
  }
}

class _DongengDetailBody extends StatelessWidget {
  const _DongengDetailBody({required this.dongeng});
  final DongengModel dongeng;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              dongeng.gambar,
              width: double.infinity, height: 220, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220, color: colorScheme.primaryContainer,
                child: Icon(Icons.menu_book, size: 80, color: colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(dongeng.judul,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('📍 ${dongeng.asal}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
          const SizedBox(height: 16),
          _InfoCard(title: '📖 Sinopsis', content: dongeng.sinopsis),
          const SizedBox(height: 12),
          _InfoCard(title: '👥 Tokoh', content: dongeng.tokoh),
          const SizedBox(height: 12),
          _InfoCard(title: '💡 Pesan Moral', content: dongeng.pesan),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Divider(height: 16),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}