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
  // A small base64-encoded JPEG, stored directly in the database instead
  // of Firebase Storage — Storage now requires the paid Blaze plan just
  // to enable, which isn't an option here. Kept deliberately small (see
  // ProfileScreen's image_picker settings) so this stays cheap to store.
  final String? avatarBase64;
  // Notification preferences — folded into Settings rather than given
  // their own top-level Profile menu row, since there's only ever a
  // couple of things to configure here (see settings_screen.dart).
  final bool reminderEnabled;
  final String reminderTime; // "HH:mm", 24-hour
  // "yyyy-MM-dd" of the last practice day / Monday of the week the
  // weeklyMinutes belong to — used to reset the streak and chart.
  final String? lastPracticeDate;
  final String? weekStart;

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime mondayOf(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  /// Streak as it should display right now: still alive only if the last
  /// practice was today or yesterday, otherwise it has lapsed to 0.
  int get effectiveStreak {
    final now = DateTime.now();
    if (lastPracticeDate == dateKey(now) ||
        lastPracticeDate == dateKey(now.subtract(const Duration(days: 1)))) {
      return currentStreak;
    }
    return 0;
  }

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.skillLevel,
    this.totalPracticeHours = 0,
    this.currentStreak = 0,
    this.songsLearned = 0,
    this.weeklyMinutes = const {},
    this.avatarBase64,
    this.reminderEnabled = false,
    this.reminderTime = '18:00',
    this.lastPracticeDate,
    this.weekStart,
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
      avatarBase64: map['avatarBase64'] as String?,
      reminderEnabled: map['reminderEnabled'] as bool? ?? false,
      reminderTime: map['reminderTime'] as String? ?? '18:00',
      lastPracticeDate: map['lastPracticeDate'] as String?,
      weekStart: map['weekStart'] as String?,
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
      if (avatarBase64 != null) 'avatarBase64': avatarBase64,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      if (lastPracticeDate != null) 'lastPracticeDate': lastPracticeDate,
      if (weekStart != null) 'weekStart': weekStart,
    };
  }

  /// Weekly minutes as a 7-value list, Monday first, for the dashboard chart.
  /// Empty (all zeros) if the stored minutes belong to a previous week.
  List<int> get weekMinutesList {
    if (weekStart != dateKey(mondayOf(DateTime.now()))) {
      return List.filled(7, 0);
    }
    const order = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return order.map((d) => weeklyMinutes[d] ?? 0).toList();
  }
}
