import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/disc.dart';
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

  Future<void> _confirmDelete(BuildContext context, Disc disc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce disque ?'),
        content: Text(
          'Le disque "${disc.name}" et tous ses titres seront supprimés définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<DiscProvider>().deleteDisc(disc.id!);
    }
  }

  void _openDisc(Disc disc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DiscDetailScreen(disc: disc)),
    ).then((_) => context.read<DiscProvider>().loadDiscs());
  }

  void _openAddDisc() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditDiscScreen()),
    );
  }

  void _openEditDisc(Disc disc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditDiscScreen(disc: disc)),
    );
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
          if (provider.loading && provider.discs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.discs.isEmpty) {
            return const EmptyState(
              icon: Icons.album_outlined,
              message: 'Aucun disque pour l\'instant.\nAppuyez sur + pour commencer.',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadDiscs,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.discs.length,
              itemBuilder: (context, index) {
                final disc = provider.discs[index];
                return DiscCard(
                  disc: disc,
                  onTap: () => _openDisc(disc),
                  onEdit: () => _openEditDisc(disc),
                  onDelete: () => _confirmDelete(context, disc),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDisc,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau disque', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
