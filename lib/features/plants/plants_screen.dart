import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_constants.dart';
import '../../data/models/plant_model.dart';
import '../../providers/plant_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantProvider>().loadPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: TopAppBarWidget(
            title: 'Plants',
            withSearch: true,
            searchQuery: provider.searchQuery,
            onSearchQueryChange: provider.updateSearchQuery,
          ),
          body: switch (provider.status) {
            PlantStatus.loading || PlantStatus.initial => const LoadingWidget(),
            PlantStatus.error => AppErrorWidget(
                message: provider.errorMessage, onRetry: provider.loadPlants),
            PlantStatus.success => _PlantsBody(
                plants: provider.plants,
                onOpen: (id) => context.go(RouteConstants.plantsDetail(id))),
          },
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final added = await context.push<bool>(RouteConstants.plantsAdd);
              if (added == true && context.mounted) provider.loadPlants();
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _PlantsBody extends StatelessWidget {
  const _PlantsBody({required this.plants, required this.onOpen});
  final List<PlantModel> plants;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) {
      return const Center(child: Text('Tidak ada data tanaman!'));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<PlantProvider>().loadPlants(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          final colorScheme = Theme.of(context).colorScheme;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onOpen(plant.id!),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(plant.gambar, width: 70, height: 70, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 70, height: 70,
                            color: colorScheme.primaryContainer,
                            child: Icon(Icons.eco, color: colorScheme.primary))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(plant.nama, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(plant.deskripsi, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ])),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}