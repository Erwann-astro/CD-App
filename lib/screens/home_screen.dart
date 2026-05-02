import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/disc_provider.dart';
import '../widgets/disc_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_disc_screen.dart';
import 'add_edit_track_screen.dart';
import 'settings_screen.dart';
import 'disc_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Clé utilisée pour récupérer la position exacte du bouton central
  // afin d'afficher un petit menu flottant juste au-dessus.
  final GlobalKey _createButtonKey = GlobalKey();

  // Index de la barre du bas: 0 = Home, 1 = Crée, 2 = Paramètre.
  // Ici l'app est centrée sur Home, donc on conserve 0 comme état sélectionné.
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    // Chargement des disques après le premier rendu pour éviter d'appeler
    // le provider pendant la phase de build initiale.
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

  // Affiche un menu flottant rectangulaire contenant les 2 actions de création.
  Future<void> _showCreateMenu() async {
    final buttonContext = _createButtonKey.currentContext;
    if (buttonContext == null) {
      return;
    }

    final renderBox = buttonContext.findRenderObject() as RenderBox;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    // Position calculée pour placer le menu juste au-dessus du bouton +.
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
          child: Text('Crée disque'),
        ),
        PopupMenuItem<String>(
          value: 'create_music',
          child: Text('Crée Music'),
        ),
      ],
    );

    // Routage selon le choix utilisateur dans le menu flottant.
    if (!mounted || selected == null) return;

    if (selected == 'create_disc') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddEditDiscScreen()),
      );
      if (mounted) {
        await context.read<DiscProvider>().loadDiscs();
      }
      return;
    }

    if (selected == 'create_music') {
      final discs = context.read<DiscProvider>().discs;
      if (discs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Créez d\'abord un disque pour ajouter un titre.')),
        );
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditTrackScreen(defaultDiscId: discs.first.id!),
        ),
      );
      if (mounted) {
        await context.read<DiscProvider>().loadDiscs();
      }
    }
  }

  // Gestion des clics sur la barre du bas.
  Future<void> _onBottomTapped(int index) async {
    if (index == 0) {
      // Home: reste sur la page d'accueil et rafraîchit la liste.
      setState(() => _bottomIndex = 0);
      await context.read<DiscProvider>().loadDiscs();
      return;
    }

    if (index == 1) {
      // Crée: ouvre le menu flottant avec les deux actions demandées.
      setState(() => _bottomIndex = 1);
      await _showCreateMenu();
      if (mounted) {
        setState(() => _bottomIndex = 0);
      }
      return;
    }

    // Paramètre: ouvre un écran de paramètres simple.
    setState(() => _bottomIndex = 2);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (mounted) {
      setState(() => _bottomIndex = 0);
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
      // Suppression du FloatingActionButton "Nouveau disque" et remplacement
      // par une barre de navigation basse avec 3 boutons.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomIndex,
        onDestinationSelected: _onBottomTapped,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Container(
              key: _createButtonKey,
              child: const Icon(Icons.add_circle_outline),
            ),
            selectedIcon: Container(
              key: _createButtonKey,
              child: const Icon(Icons.add_circle),
            ),
            label: 'Crée',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètre',
          ),
        ],
      ),
    );
  }
}
