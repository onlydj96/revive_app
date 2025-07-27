import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamDetailScreen extends ConsumerWidget {
  final String teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Details'),
      ),
      body: Center(
        child: Text('Team Detail Screen for ID: $teamId'),
      ),
    );
  }
}