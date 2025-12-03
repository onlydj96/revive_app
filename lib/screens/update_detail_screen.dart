import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateDetailScreen extends ConsumerWidget {
  final String updateId;

  const UpdateDetailScreen({super.key, required this.updateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Details'),
      ),
      body: Center(
        child: Text('Update Detail Screen for ID: $updateId'),
      ),
    );
  }
}
