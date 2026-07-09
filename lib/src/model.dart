/// Represents a simple key-value pair with an optional extra value.
///
/// Commonly used for dropdowns, selections, and lookup lists where an
/// integer identifier is associated with a display name.
///
/// Equality is based on the [id] field.
class Pair {
  /// Unique identifier of the pair.
  int id;

  /// Display name of the pair.
  String name;

  /// Optional additional information associated with the pair.
  String extra;

  /// Creates a new [Pair] instance.
  ///
  /// Example:
  /// ```dart
  /// final item = Pair(1, 'Apple');
  /// final user = Pair(101, 'John', extra: 'Admin');
  /// ```
  Pair(this.id, this.name, {this.extra = ""});

  /// Returns the display name of the pair.
  @override
  String toString() {
    return name;
  }

  /// Compares two [Pair] objects by their [id].
  @override
  bool operator ==(Object other) {
    if (other is Pair) {
      return id == other.id;
    }
    return false;
  }

  /// Returns the hash code based on the [id].
  @override
  int get hashCode => id;
}

/// Represents a simple string key-value pair with an optional extra value.
///
/// Commonly used for dropdowns, selections, API responses, and lookup lists
/// where a string identifier is associated with a display name.
///
/// Equality is based on the [id] field.
class SPair {
  /// Unique string identifier of the pair.
  String id;

  /// Display name of the pair.
  String name;

  /// Optional additional information associated with the pair.
  String extra;

  /// Creates a new [SPair] instance.
  ///
  /// Example:
  /// ```dart
  /// final country = SPair('IN', 'India');
  /// final user = SPair('1001', 'John', extra: 'Admin');
  /// ```
  SPair(this.id, this.name, {this.extra = ""});

  /// Returns the display name of the pair.
  @override
  String toString() {
    return name;
  }

  /// Compares two [SPair] objects by their [id].
  @override
  bool operator ==(Object other) {
    if (other is SPair) {
      return id == other.id;
    }
    return false;
  }

  /// Returns the hash code based on the [id].
  @override
  int get hashCode => id.hashCode;
}
