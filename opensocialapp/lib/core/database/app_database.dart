import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get type => text()(); // 'individual' or 'group'
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get lastMessageContent => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Participants extends Table {
  TextColumn get id => text()(); // Unique ID for the participant entry
  TextColumn get conversationId => text().references(Conversations, #id)();
  TextColumn get userId => text().references(Users, #id)();
  BoolColumn get isAdmin => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {conversationId, userId};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text().references(Conversations, #id)();
  TextColumn get senderId => text().references(Users, #id)();
  TextColumn get content => text()();
  TextColumn get type => text()(); // 'text', 'image', etc.
  TextColumn get status => text()(); // 'sent', 'delivered', 'read'
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isMine => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, Conversations, Participants, Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_app_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
