import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaDetailScreen extends ConsumerWidget {
  final String mediaId;

  const MediaDetailScreen({super.key, required this.mediaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Details'),
      ),
      body: Center(
        child: Text('Media Detail Screen for ID: $mediaId'),
      ),
    );
  }
}