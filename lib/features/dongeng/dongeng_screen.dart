import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_constants.dart';
import '../../data/models/dongeng_model.dart';
import '../../providers/dongeng_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class DongengScreen extends StatefulWidget {
  const DongengScreen({super.key});

  @override
  State<DongengScreen> createState() => _DongengScreenState();
}

class _DongengScreenState extends State<DongengScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DongengProvider>().loadDongeng();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DongengProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: TopAppBarWidget(
            title: 'Dongeng Anak',
            withSearch: true,
            searchQuery: provider.searchQuery,
            onSearchQueryChange: provider.updateSearchQuery,
          ),
          body: _buildBody(provider),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final added = await context.push<bool>(RouteConstants.dongengAdd);
              if (added == true && context.mounted) provider.loadDongeng();
            },
            tooltip: 'Tambah Dongeng',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(DongengProvider provider) {
    return switch (provider.status) {
      DongengStatus.loading || DongengStatus.initial => const LoadingWidget(),
      DongengStatus.error => AppErrorWidget(
        message: provider.errorMessage,
        onRetry: provider.loadDongeng,
      ),
      DongengStatus.success => _DongengBody(
        dongengList: provider.dongengList,
        onOpen: (id) => context.go(RouteConstants.dongengDetail(id)),
      ),
    };
  }
}

class _DongengBody extends StatelessWidget {
  const _DongengBody({required this.dongengList, required this.onOpen});
  final List<DongengModel> dongengList;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (dongengList.isEmpty) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Belum ada dongeng.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<DongengProvider>().loadDongeng(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dongengList.length,
        itemBuilder: (context, index) =>
            _DongengCard(dongeng: dongengList[index], onOpen: onOpen),
      ),
    );
  }
}

class _DongengCard extends StatelessWidget {
  const _DongengCard({required this.dongeng, required this.onOpen});
  final DongengModel dongeng;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onOpen(dongeng.id!),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  dongeng.gambar,
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70, height: 70,
                    color: colorScheme.primaryContainer,
                    child: Icon(Icons.menu_book, color: colorScheme.primary),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(width: 70, height: 70,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dongeng.judul,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('📍 ${dongeng.asal}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colorScheme.primary)),
                    const SizedBox(height: 4),
                    Text(dongeng.sinopsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}