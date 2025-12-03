import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SermonDetailScreen extends ConsumerWidget {
  final String sermonId;

  const SermonDetailScreen({super.key, required this.sermonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sermon Details'),
      ),
      body: Center(
        child: Text('Sermon Detail Screen for ID: $sermonId'),
      ),
    );
  }
}
