

/// Represents a letter with its properties for Arabic Scrabble
class Letter {
  /// The Arabic letter character
  final String value;
  
  /// The point value of this letter
  final int points;
  
  /// Whether this letter was newly placed in the current turn
  final bool isNew;
  
  /// Whether this is a blank/wildcard tile
  final bool isBlank;
  
  /// If this is a blank tile, what letter it represents
  final String? blankLetter;

  const Letter({
    required this.value,
    required this.points,
    this.isNew = false,
    this.isBlank = false,
    this.blankLetter,
  });

  /// Creates a Letter from a JSON map
  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      value: json['value'] ?? '',
      points: json['points'] ?? 0,
      isNew: json['isNew'] ?? false,
      isBlank: json['isBlank'] ?? false,
      blankLetter: json['blankLetter'],
    );
  }

  /// Converts the letter to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'points': points,
      'isNew': isNew,
      'isBlank': isBlank,
      'blankLetter': blankLetter,
    };
  }

  /// Creates a copy of this letter with updated fields
  Letter copyWith({
    String? value,
    int? points,
    bool? isNew,
    bool? isBlank,
    String? blankLetter,
  }) {
    return Letter(
      value: value ?? this.value,
      points: points ?? this.points,
      isNew: isNew ?? this.isNew,
      isBlank: isBlank ?? this.isBlank,
      blankLetter: blankLetter ?? this.blankLetter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Letter &&
        other.value == value &&
        other.points == points &&
        other.isNew == isNew &&
        other.isBlank == isBlank &&
        other.blankLetter == blankLetter;
  }

  @override
  int get hashCode {
    return value.hashCode ^
        points.hashCode ^
        isNew.hashCode ^
        isBlank.hashCode ^
        (blankLetter?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'Letter(value: $value, points: $points, isNew: $isNew, isBlank: $isBlank, blankLetter: $blankLetter)';
  }
}
