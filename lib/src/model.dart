class Pair {
  int id;
  String name;
  String extra;

  Pair(this.id, this.name, {this.extra = ""});

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (other is Pair) {
      return id == other.id;
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id;
}

class SPair {
  String id;
  String name;
  String extra;

  SPair(this.id, this.name, {this.extra = ""});

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (other is SPair) {
      return id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;
}
