/// Represents a position on the game board (0-based indices)
class Position {
  /// The row index (0 = top)
  final int row;
  
  /// The column index (0 = left)
  final int col;

  /// Creates a new position with the given row and column
  const Position({required this.row, required this.col});
  
  /// Creates a Position from a JSON map
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      row: json['row'],
      col: json['col'],
    );
  }
  
  /// Converts the position to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
    };
  }
  
  /// Creates a new position offset by the given delta
  Position offset(int dRow, int dCol) {
    return Position(row: row + dRow, col: col + dCol);
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;
          
  @override
  int get hashCode => Object.hash(row, col);
  
  @override
  String toString() => 'Position($row, $col)';
}
