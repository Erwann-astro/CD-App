import 'package:flutter/material.dart';

import '../models/track.dart';
import '../services/database_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _c = TextEditingController();
  List<Track> _items = [];

  @override
  void initState() { super.initState(); _search(); }
  Future<void> _search() async {
    _items = await DatabaseService.instance.searchTracks(_c.text.trim());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Column(children:[
    Padding(padding: const EdgeInsets.all(12), child: TextField(controller:_c, onChanged: (_) => _search(), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText:'Rechercher année, artiste, titre...'))),
    Expanded(child: ListView.builder(itemCount:_items.length,itemBuilder:(_,i){final t=_items[i]; return ListTile(title: Text(t.title),subtitle: Text('${t.artist}${t.year!=null?' • ${t.year}':''}'));}))
  ]);
}
