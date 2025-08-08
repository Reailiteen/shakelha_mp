
/// Represents a user account in the game system.
class User {
  /// Unique identifier for the user
  final String id;
  
  /// The user's display name
  final String username;
  
  /// The user's email address
  final String email;
  
  /// URL to the user's profile picture
  final String? photoUrl;
  
  /// The user's total score across all games
  final int totalScore;
  
  /// Number of games played
  final int gamesPlayed;
  
  /// Number of games won
  final int gamesWon;
  
  /// User's preferred language code (e.g., 'en', 'ar')
  final String language;
  
  /// Whether the user has verified their email
  final bool isEmailVerified;
  
  /// When the user account was created
  final DateTime createdAt;
  
  /// When the user was last active
  final DateTime lastActiveAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    this.totalScore = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.language = 'en',
    this.isEmailVerified = false,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastActiveAt = lastActiveAt ?? DateTime.now();

  /// Creates a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      totalScore: json['totalScore'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      language: json['language'] ?? 'en',
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
    );
  }

  /// Converts the user to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'language': language,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }
  
  /// Creates a copy of this user with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? photoUrl,
    int? totalScore,
    int? gamesPlayed,
    int? gamesWon,
    String? language,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      totalScore: totalScore ?? this.totalScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      language: language ?? this.language,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
  
  /// Returns the user's win rate as a percentage (0-100)
  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return (gamesWon / gamesPlayed) * 100;
  }
  
  /// Updates the user's last active timestamp
  User updateLastActive() {
    return copyWith(lastActiveAt: DateTime.now());
  }
  
  /// Increments the user's game stats
  User incrementGamesPlayed({bool won = false}) {
    return copyWith(
      gamesPlayed: gamesPlayed + 1,
      gamesWon: won ? gamesWon + 1 : gamesWon,
    );
  }
  
  /// Adds points to the user's total score
  User addToScore(int points) {
    if (points <= 0) return this;
    return copyWith(totalScore: totalScore + points);
  }
  
  @override
  String toString() => 'User($username, score: $totalScore)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;
          
  @override
  int get hashCode => Object.hash(id, email);
}
