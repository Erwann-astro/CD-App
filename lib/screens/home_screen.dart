import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/disc_provider.dart';
import '../widgets/disc_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_disc_screen.dart';
import 'add_edit_track_screen.dart';
import 'disc_detail_screen.dart';
import 'settings_screen.dart';
import 'music_screen.dart';
import 'artists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _createButtonKey = GlobalKey();
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscProvider>().loadDiscs();
    });
  }

  Future<void> _confirmDeleteDisc(int discId) async {
    final discProvider = context.read<DiscProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce disque ?'),
        content: const Text('Tous les titres de ce disque seront aussi supprimes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await discProvider.deleteDisc(discId);
    }
  }

  Future<void> _showCreateMenu() async {
    final discProvider = context.read<DiscProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final buttonContext = _createButtonKey.currentContext;
    if (buttonContext == null) {
      return;
    }

    final renderBox = buttonContext.findRenderObject() as RenderBox;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(
        buttonPosition.dx - 24,
        buttonPosition.dy - 120,
        buttonPosition.dx + buttonSize.width + 24,
        buttonPosition.dy,
      ),
      items: const [
        PopupMenuItem<String>(
          value: 'create_disc',
          child: Text('Creer disque'),
        ),
        PopupMenuItem<String>(
          value: 'create_music',
          child: Text('Creer musique'),
        ),
      ],
    );

    if (!mounted || selected == null) return;

    if (selected == 'create_disc') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddEditDiscScreen()),
      );
      if (!context.mounted) return;
      await discProvider.loadDiscs();
      return;
    }

    if (selected == 'create_music') {
      final discs = discProvider.discs;
      if (discs.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Creez d abord un disque pour ajouter un titre.')),
        );
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditTrackScreen(defaultDiscId: discs.first.id!),
        ),
      );
      if (!context.mounted) return;
      await discProvider.loadDiscs();
    }
  }

  Future<void> _onBottomTapped(int index) async {
    setState(() => _bottomIndex = index);
    if (index == 2) {
      await _showCreateMenu();
      if (mounted) setState(() => _bottomIndex = 0);
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
      body: _bottomIndex == 0
          ? Consumer<DiscProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                if (provider.discs.isEmpty) return const EmptyState(icon: Icons.album_outlined, message: 'Aucun disque pour l'instant.');
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.discs.length,
                  itemBuilder: (context, index) {
                    final disc = provider.discs[index];
                    return DiscCard(disc: disc, onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => DiscDetailScreen(disc: disc))); if (!context.mounted) return; await provider.loadDiscs(); }, onEdit: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditDiscScreen(disc: disc))); }, onDelete: () => _confirmDeleteDisc(disc.id!));
                  },
                );
              },
            )
          : _bottomIndex == 1
              ? const MusicScreen()
              : _bottomIndex == 3
                  ? const ArtistsScreen()
                  : const SettingsScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomIndex,
        onDestinationSelected: _onBottomTapped,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music), label: 'Music'),
          NavigationDestination(icon: Container(key: _createButtonKey, child: const Icon(Icons.add_circle_outline)), selectedIcon: Container(key: _createButtonKey, child: const Icon(Icons.add_circle)), label: 'Creer'),
          const NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Artistes'),
          const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Parametre'),
        ],
      ),
    );
  }
}
