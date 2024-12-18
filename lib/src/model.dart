enum State {
  Success,
  Skipped,
  Failure,
}

class TestModel {
  final int id;
  final String name;
  final String filename;
  String? error;
  String? message;
  State? state;

  TestModel({
    required this.id,
    required this.name,
    this.filename = '',
    this.state,
  });

  String get info => '[$id] $filename: $name';

  @override
  bool operator ==(Object other) {
    if (other is TestModel) {
      return id == other.id &&
          name == other.name &&
          error == other.error &&
          message == other.message &&
          state == other.state;
    }
    return false;
  }

  @override
  String toString() {
    return 'TestModel { $id $state $name $filename $error $message }';
  }
}
