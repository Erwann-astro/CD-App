import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/disc_provider.dart';
import '../widgets/disc_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_disc_screen.dart';
import 'disc_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscProvider>().loadDiscs();
    });
  }

  Future<void> _confirmDeleteDisc(int discId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce disque ?'),
        content: const Text('Tous les titres de ce disque seront aussi supprimés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await context.read<DiscProvider>().deleteDisc(discId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Disques',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Consumer<DiscProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.discs.isEmpty) {
            return const EmptyState(
              icon: Icons.album_outlined,
              message: 'Aucun disque pour l\'instant.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.discs.length,
            itemBuilder: (context, index) {
              final disc = provider.discs[index];
              return DiscCard(
                disc: disc,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DiscDetailScreen(disc: disc)),
                  );
                  if (mounted) {
                    await context.read<DiscProvider>().loadDiscs();
                  }
                },
                onEdit: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditDiscScreen(disc: disc)),
                  );
                },
                onDelete: () => _confirmDeleteDisc(disc.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditDiscScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau disque', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
