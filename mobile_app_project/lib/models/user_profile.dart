/// Maps to a document at users/{uid} in Realtime Database.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String skillLevel;
  final double totalPracticeHours;
  final int currentStreak;
  final int songsLearned;
  final Map<String, int> weeklyMinutes; // keys: mon..sun, values: minutes

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.skillLevel,
    this.totalPracticeHours = 0,
    this.currentStreak = 0,
    this.songsLearned = 0,
    this.weeklyMinutes = const {},
  });

  factory UserProfile.fromMap(String uid, Map<dynamic, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] as String? ?? 'Guitarist',
      email: map['email'] as String? ?? '',
      skillLevel: map['skillLevel'] as String? ?? 'beginner',
      totalPracticeHours: (map['totalPracticeHours'] as num?)?.toDouble() ?? 0,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      songsLearned: (map['songsLearned'] as num?)?.toInt() ?? 0,
      weeklyMinutes: (map['weeklyMinutes'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ) ??
          const {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'skillLevel': skillLevel,
      'totalPracticeHours': totalPracticeHours,
      'currentStreak': currentStreak,
      'songsLearned': songsLearned,
      'weeklyMinutes': weeklyMinutes,
    };
  }

  /// Weekly minutes as a 7-value list, Monday first, for the dashboard chart.
  List<int> get weekMinutesList {
    const order = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return order.map((d) => weeklyMinutes[d] ?? 0).toList();
  }
}
