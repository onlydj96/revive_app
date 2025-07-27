import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';

final teamsProvider = StateNotifierProvider<TeamsNotifier, List<Team>>((ref) {
  return TeamsNotifier();
});

final connectGroupsProvider = Provider<List<Team>>((ref) {
  final teams = ref.watch(teamsProvider);
  return teams.where((team) => team.type == TeamType.connectGroup).toList();
});

final hangoutsProvider = Provider<List<Team>>((ref) {
  final teams = ref.watch(teamsProvider);
  return teams.where((team) => team.type == TeamType.hangout).toList();
});

class TeamsNotifier extends StateNotifier<List<Team>> {
  TeamsNotifier() : super([]) {
    _loadMockTeams();
  }

  void _loadMockTeams() {
    state = [
      Team(
        id: '1',
        name: 'Bible Study',
        description: 'Weekly Bible study focusing on practical Christian living and scriptural understanding.',
        type: TeamType.connectGroup,
        leader: 'Pastor Mike',
        meetingTime: DateTime(2024, 1, 1, 19, 0),
        meetingLocation: 'Room 101',
        requiresApplication: true,
        maxMembers: 15,
        currentMembers: 12,
        requirements: ['Regular church attendance', 'Commitment to weekly meetings'],
      ),
      Team(
        id: '2',
        name: 'Book Study',
        description: 'Study Christian books together and discuss their applications in our daily lives.',
        type: TeamType.connectGroup,
        leader: 'Sarah Johnson',
        meetingTime: DateTime(2024, 1, 1, 18, 30),
        meetingLocation: 'Library',
        requiresApplication: true,
        maxMembers: 12,
        currentMembers: 8,
        requirements: ['Must be a church member'],
      ),
      Team(
        id: '3',
        name: 'Couples Group',
        description: 'Support group for married couples focusing on strengthening relationships.',
        type: TeamType.connectGroup,
        leader: 'John & Mary Smith',
        meetingTime: DateTime(2024, 1, 1, 19, 30),
        meetingLocation: 'Room 203',
        requiresApplication: true,
        maxMembers: 8,
        currentMembers: 6,
        requirements: ['Must be married', 'Both spouses must attend'],
      ),
      Team(
        id: '4',
        name: 'Prayer & Intercession',
        description: 'Dedicated prayer group for church and community needs.',
        type: TeamType.connectGroup,
        leader: 'Elder Margaret',
        meetingTime: DateTime(2024, 1, 1, 6, 0),
        meetingLocation: 'Prayer Room',
        requiresApplication: true,
        maxMembers: 20,
        currentMembers: 14,
        requirements: ['Heart for prayer', 'Early morning availability'],
      ),
      Team(
        id: '5',
        name: 'Futsal',
        description: 'Fun futsal games for youth and young adults every weekend.',
        type: TeamType.hangout,
        leader: 'Youth Pastor Dave',
        meetingTime: DateTime(2024, 1, 1, 16, 0),
        meetingLocation: 'Sports Hall',
        requiresApplication: false,
        currentMembers: 25,
      ),
      Team(
        id: '6',
        name: 'Women\'s Group',
        description: 'Fellowship and support group for women of all ages.',
        type: TeamType.hangout,
        leader: 'Lisa Brown',
        meetingTime: DateTime(2024, 1, 1, 10, 0),
        meetingLocation: 'Fellowship Hall',
        requiresApplication: false,
        currentMembers: 18,
      ),
      Team(
        id: '7',
        name: 'Matcha (30+)',
        description: 'Social group for adults 30 and above, building friendships over coffee and activities.',
        type: TeamType.hangout,
        leader: 'Robert Wilson',
        meetingTime: DateTime(2024, 1, 1, 14, 0),
        meetingLocation: 'Café Corner',
        requiresApplication: false,
        currentMembers: 12,
      ),
      Team(
        id: '8',
        name: 'Kingdom Business',
        description: 'Network for Christian entrepreneurs and business professionals.',
        type: TeamType.hangout,
        leader: 'David Chen',
        meetingTime: DateTime(2024, 1, 1, 18, 0),
        meetingLocation: 'Conference Room',
        requiresApplication: false,
        currentMembers: 15,
      ),
    ];
  }

  void joinTeam(String teamId) {
    state = state.map((team) {
      if (team.id == teamId) {
        return team.copyWith(currentMembers: team.currentMembers + 1);
      }
      return team;
    }).toList();
  }

  void leaveTeam(String teamId) {
    state = state.map((team) {
      if (team.id == teamId && team.currentMembers > 0) {
        return team.copyWith(currentMembers: team.currentMembers - 1);
      }
      return team;
    }).toList();
  }

  void addTeam(Team team) {
    state = [...state, team];
  }

  void updateTeam(Team updatedTeam) {
    state = state.map((team) {
      return team.id == updatedTeam.id ? updatedTeam : team;
    }).toList();
  }

  void deleteTeam(String teamId) {
    state = state.where((team) => team.id != teamId).toList();
  }
}