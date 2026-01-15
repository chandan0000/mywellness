// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isOnlineMeta =
      const VerificationMeta('isOnline');
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
      'is_online', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_online" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, fullName, email, avatarUrl, isOnline];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('is_online')) {
      context.handle(_isOnlineMeta,
          isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      isOnline: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_online'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final bool isOnline;
  const User(
      {required this.id,
      this.fullName,
      this.email,
      this.avatarUrl,
      required this.isOnline});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['is_online'] = Variable<bool>(isOnline);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      isOnline: Value(isOnline),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      email: serializer.fromJson<String?>(json['email']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String?>(fullName),
      'email': serializer.toJson<String?>(email),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'isOnline': serializer.toJson<bool>(isOnline),
    };
  }

  User copyWith(
          {String? id,
          Value<String?> fullName = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          bool? isOnline}) =>
      User(
        id: id ?? this.id,
        fullName: fullName.present ? fullName.value : this.fullName,
        email: email.present ? email.value : this.email,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        isOnline: isOnline ?? this.isOnline,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isOnline: $isOnline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fullName, email, avatarUrl, isOnline);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.email == this.email &&
          other.avatarUrl == this.avatarUrl &&
          other.isOnline == this.isOnline);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> fullName;
  final Value<String?> email;
  final Value<String?> avatarUrl;
  final Value<bool> isOnline;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<String>? avatarUrl,
    Expression<bool>? isOnline,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (isOnline != null) 'is_online': isOnline,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String?>? fullName,
      Value<String?>? email,
      Value<String?>? avatarUrl,
      Value<bool>? isOnline,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isOnline: $isOnline, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageContentMeta =
      const VerificationMeta('lastMessageContent');
  @override
  late final GeneratedColumn<String> lastMessageContent =
      GeneratedColumn<String>('last_message_content', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageAtMeta =
      const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>('last_message_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        avatarUrl,
        lastMessageContent,
        lastMessageAt,
        unreadCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('last_message_content')) {
      context.handle(
          _lastMessageContentMeta,
          lastMessageContent.isAcceptableOrUnknown(
              data['last_message_content']!, _lastMessageContentMeta));
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
          _lastMessageAtMeta,
          lastMessageAt.isAcceptableOrUnknown(
              data['last_message_at']!, _lastMessageAtMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      lastMessageContent: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_message_content']),
      lastMessageAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_at']),
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String id;
  final String? name;
  final String type;
  final String? avatarUrl;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;
  final int unreadCount;
  const Conversation(
      {required this.id,
      this.name,
      required this.type,
      this.avatarUrl,
      this.lastMessageContent,
      this.lastMessageAt,
      required this.unreadCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || lastMessageContent != null) {
      map['last_message_content'] = Variable<String>(lastMessageContent);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      type: Value(type),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      lastMessageContent: lastMessageContent == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageContent),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      unreadCount: Value(unreadCount),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      lastMessageContent:
          serializer.fromJson<String?>(json['lastMessageContent']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'type': serializer.toJson<String>(type),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'lastMessageContent': serializer.toJson<String?>(lastMessageContent),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'unreadCount': serializer.toJson<int>(unreadCount),
    };
  }

  Conversation copyWith(
          {String? id,
          Value<String?> name = const Value.absent(),
          String? type,
          Value<String?> avatarUrl = const Value.absent(),
          Value<String?> lastMessageContent = const Value.absent(),
          Value<DateTime?> lastMessageAt = const Value.absent(),
          int? unreadCount}) =>
      Conversation(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        type: type ?? this.type,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        lastMessageContent: lastMessageContent.present
            ? lastMessageContent.value
            : this.lastMessageContent,
        lastMessageAt:
            lastMessageAt.present ? lastMessageAt.value : this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
      );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      lastMessageContent: data.lastMessageContent.present
          ? data.lastMessageContent.value
          : this.lastMessageContent,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastMessageContent: $lastMessageContent, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, avatarUrl, lastMessageContent,
      lastMessageAt, unreadCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.avatarUrl == this.avatarUrl &&
          other.lastMessageContent == this.lastMessageContent &&
          other.lastMessageAt == this.lastMessageAt &&
          other.unreadCount == this.unreadCount);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String> type;
  final Value<String?> avatarUrl;
  final Value<String?> lastMessageContent;
  final Value<DateTime?> lastMessageAt;
  final Value<int> unreadCount;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.lastMessageContent = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required String type,
    this.avatarUrl = const Value.absent(),
    this.lastMessageContent = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? avatarUrl,
    Expression<String>? lastMessageContent,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? unreadCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (lastMessageContent != null)
        'last_message_content': lastMessageContent,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<String>? type,
      Value<String?>? avatarUrl,
      Value<String?>? lastMessageContent,
      Value<DateTime?>? lastMessageAt,
      Value<int>? unreadCount,
      Value<int>? rowid}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (lastMessageContent.present) {
      map['last_message_content'] = Variable<String>(lastMessageContent.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastMessageContent: $lastMessageContent, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParticipantsTable extends Participants
    with TableInfo<$ParticipantsTable, Participant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES conversations (id)'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _isAdminMeta =
      const VerificationMeta('isAdmin');
  @override
  late final GeneratedColumn<bool> isAdmin = GeneratedColumn<bool>(
      'is_admin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_admin" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, conversationId, userId, isAdmin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(Insertable<Participant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('is_admin')) {
      context.handle(_isAdminMeta,
          isAdmin.isAcceptableOrUnknown(data['is_admin']!, _isAdminMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId, userId};
  @override
  Participant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Participant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      isAdmin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_admin'])!,
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class Participant extends DataClass implements Insertable<Participant> {
  final String id;
  final String conversationId;
  final String userId;
  final bool isAdmin;
  const Participant(
      {required this.id,
      required this.conversationId,
      required this.userId,
      required this.isAdmin});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['user_id'] = Variable<String>(userId);
    map['is_admin'] = Variable<bool>(isAdmin);
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      userId: Value(userId),
      isAdmin: Value(isAdmin),
    );
  }

  factory Participant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Participant(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      userId: serializer.fromJson<String>(json['userId']),
      isAdmin: serializer.fromJson<bool>(json['isAdmin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'userId': serializer.toJson<String>(userId),
      'isAdmin': serializer.toJson<bool>(isAdmin),
    };
  }

  Participant copyWith(
          {String? id,
          String? conversationId,
          String? userId,
          bool? isAdmin}) =>
      Participant(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        userId: userId ?? this.userId,
        isAdmin: isAdmin ?? this.isAdmin,
      );
  Participant copyWithCompanion(ParticipantsCompanion data) {
    return Participant(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      userId: data.userId.present ? data.userId.value : this.userId,
      isAdmin: data.isAdmin.present ? data.isAdmin.value : this.isAdmin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Participant(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('userId: $userId, ')
          ..write('isAdmin: $isAdmin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, userId, isAdmin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Participant &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.userId == this.userId &&
          other.isAdmin == this.isAdmin);
}

class ParticipantsCompanion extends UpdateCompanion<Participant> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> userId;
  final Value<bool> isAdmin;
  final Value<int> rowid;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.isAdmin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    required String id,
    required String conversationId,
    required String userId,
    this.isAdmin = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        userId = Value(userId);
  static Insertable<Participant> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? userId,
    Expression<bool>? isAdmin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (userId != null) 'user_id': userId,
      if (isAdmin != null) 'is_admin': isAdmin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParticipantsCompanion copyWith(
      {Value<String>? id,
      Value<String>? conversationId,
      Value<String>? userId,
      Value<bool>? isAdmin,
      Value<int>? rowid}) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      isAdmin: isAdmin ?? this.isAdmin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (isAdmin.present) {
      map['is_admin'] = Variable<bool>(isAdmin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('userId: $userId, ')
          ..write('isAdmin: $isAdmin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES conversations (id)'));
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isMineMeta = const VerificationMeta('isMine');
  @override
  late final GeneratedColumn<bool> isMine = GeneratedColumn<bool>(
      'is_mine', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_mine" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, conversationId, senderId, content, type, status, createdAt, isMine];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_mine')) {
      context.handle(_isMineMeta,
          isMine.isAcceptableOrUnknown(data['is_mine']!, _isMineMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isMine: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_mine'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String type;
  final String status;
  final DateTime createdAt;
  final bool isMine;
  const Message(
      {required this.id,
      required this.conversationId,
      required this.senderId,
      required this.content,
      required this.type,
      required this.status,
      required this.createdAt,
      required this.isMine});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_id'] = Variable<String>(senderId);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_mine'] = Variable<bool>(isMine);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      content: Value(content),
      type: Value(type),
      status: Value(status),
      createdAt: Value(createdAt),
      isMine: Value(isMine),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isMine: serializer.fromJson<bool>(json['isMine']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderId': serializer.toJson<String>(senderId),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isMine': serializer.toJson<bool>(isMine),
    };
  }

  Message copyWith(
          {String? id,
          String? conversationId,
          String? senderId,
          String? content,
          String? type,
          String? status,
          DateTime? createdAt,
          bool? isMine}) =>
      Message(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        senderId: senderId ?? this.senderId,
        content: content ?? this.content,
        type: type ?? this.type,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        isMine: isMine ?? this.isMine,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isMine: data.isMine.present ? data.isMine.value : this.isMine,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('isMine: $isMine')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, conversationId, senderId, content, type, status, createdAt, isMine);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.type == this.type &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.isMine == this.isMine);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> senderId;
  final Value<String> content;
  final Value<String> type;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<bool> isMine;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isMine = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String senderId,
    required String content,
    required String type,
    required String status,
    required DateTime createdAt,
    this.isMine = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        senderId = Value(senderId),
        content = Value(content),
        type = Value(type),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<String>? content,
    Expression<String>? type,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<bool>? isMine,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (isMine != null) 'is_mine': isMine,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? conversationId,
      Value<String>? senderId,
      Value<String>? content,
      Value<String>? type,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<bool>? isMine,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isMine.present) {
      map['is_mine'] = Variable<bool>(isMine.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('isMine: $isMine, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, conversations, participants, messages];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  Value<String?> fullName,
  Value<String?> email,
  Value<String?> avatarUrl,
  Value<bool> isOnline,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String?> fullName,
  Value<String?> email,
  Value<String?> avatarUrl,
  Value<bool> isOnline,
  Value<int> rowid,
});

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UsersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UsersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> fullName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isOnline = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            fullName: fullName,
            email: email,
            avatarUrl: avatarUrl,
            isOnline: isOnline,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> fullName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isOnline = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            fullName: fullName,
            email: email,
            avatarUrl: avatarUrl,
            isOnline: isOnline,
            rowid: rowid,
          ),
        ));
}

class $$UsersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fullName => $state.composableBuilder(
      column: $state.table.fullName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get avatarUrl => $state.composableBuilder(
      column: $state.table.avatarUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isOnline => $state.composableBuilder(
      column: $state.table.isOnline,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter participantsRefs(
      ComposableFilter Function($$ParticipantsTableFilterComposer f) f) {
    final $$ParticipantsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.participants,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder, parentComposers) =>
            $$ParticipantsTableFilterComposer(ComposerState($state.db,
                $state.db.participants, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter messagesRefs(
      ComposableFilter Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.messages,
        getReferencedColumn: (t) => t.senderId,
        builder: (joinBuilder, parentComposers) =>
            $$MessagesTableFilterComposer(ComposerState(
                $state.db, $state.db.messages, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fullName => $state.composableBuilder(
      column: $state.table.fullName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get avatarUrl => $state.composableBuilder(
      column: $state.table.avatarUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isOnline => $state.composableBuilder(
      column: $state.table.isOnline,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  required String id,
  Value<String?> name,
  required String type,
  Value<String?> avatarUrl,
  Value<String?> lastMessageContent,
  Value<DateTime?> lastMessageAt,
  Value<int> unreadCount,
  Value<int> rowid,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<String> id,
  Value<String?> name,
  Value<String> type,
  Value<String?> avatarUrl,
  Value<String?> lastMessageContent,
  Value<DateTime?> lastMessageAt,
  Value<int> unreadCount,
  Value<int> rowid,
});

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ConversationsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ConversationsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<String?> lastMessageContent = const Value.absent(),
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            name: name,
            type: type,
            avatarUrl: avatarUrl,
            lastMessageContent: lastMessageContent,
            lastMessageAt: lastMessageAt,
            unreadCount: unreadCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> name = const Value.absent(),
            required String type,
            Value<String?> avatarUrl = const Value.absent(),
            Value<String?> lastMessageContent = const Value.absent(),
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion.insert(
            id: id,
            name: name,
            type: type,
            avatarUrl: avatarUrl,
            lastMessageContent: lastMessageContent,
            lastMessageAt: lastMessageAt,
            unreadCount: unreadCount,
            rowid: rowid,
          ),
        ));
}

class $$ConversationsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get avatarUrl => $state.composableBuilder(
      column: $state.table.avatarUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get lastMessageContent => $state.composableBuilder(
      column: $state.table.lastMessageContent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastMessageAt => $state.composableBuilder(
      column: $state.table.lastMessageAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get unreadCount => $state.composableBuilder(
      column: $state.table.unreadCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter participantsRefs(
      ComposableFilter Function($$ParticipantsTableFilterComposer f) f) {
    final $$ParticipantsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.participants,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder, parentComposers) =>
            $$ParticipantsTableFilterComposer(ComposerState($state.db,
                $state.db.participants, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter messagesRefs(
      ComposableFilter Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.messages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder, parentComposers) =>
            $$MessagesTableFilterComposer(ComposerState(
                $state.db, $state.db.messages, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get avatarUrl => $state.composableBuilder(
      column: $state.table.avatarUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get lastMessageContent => $state.composableBuilder(
      column: $state.table.lastMessageContent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastMessageAt => $state.composableBuilder(
      column: $state.table.lastMessageAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get unreadCount => $state.composableBuilder(
      column: $state.table.unreadCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ParticipantsTableCreateCompanionBuilder = ParticipantsCompanion
    Function({
  required String id,
  required String conversationId,
  required String userId,
  Value<bool> isAdmin,
  Value<int> rowid,
});
typedef $$ParticipantsTableUpdateCompanionBuilder = ParticipantsCompanion
    Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> userId,
  Value<bool> isAdmin,
  Value<int> rowid,
});

class $$ParticipantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder> {
  $$ParticipantsTableTableManager(_$AppDatabase db, $ParticipantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ParticipantsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ParticipantsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<bool> isAdmin = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ParticipantsCompanion(
            id: id,
            conversationId: conversationId,
            userId: userId,
            isAdmin: isAdmin,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String userId,
            Value<bool> isAdmin = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ParticipantsCompanion.insert(
            id: id,
            conversationId: conversationId,
            userId: userId,
            isAdmin: isAdmin,
            rowid: rowid,
          ),
        ));
}

class $$ParticipantsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isAdmin => $state.composableBuilder(
      column: $state.table.isAdmin,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $state.db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ConversationsTableFilterComposer(ComposerState($state.db,
                $state.db.conversations, joinBuilder, parentComposers)));
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $state.db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$UsersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.users, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ParticipantsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isAdmin => $state.composableBuilder(
      column: $state.table.isAdmin,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.conversationId,
            referencedTable: $state.db.conversations,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ConversationsTableOrderingComposer(ComposerState($state.db,
                    $state.db.conversations, joinBuilder, parentComposers)));
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $state.db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$UsersTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.users, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String conversationId,
  required String senderId,
  required String content,
  required String type,
  required String status,
  required DateTime createdAt,
  Value<bool> isMine,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> senderId,
  Value<String> content,
  Value<String> type,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<bool> isMine,
  Value<int> rowid,
});

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MessagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MessagesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isMine = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            conversationId: conversationId,
            senderId: senderId,
            content: content,
            type: type,
            status: status,
            createdAt: createdAt,
            isMine: isMine,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String senderId,
            required String content,
            required String type,
            required String status,
            required DateTime createdAt,
            Value<bool> isMine = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            conversationId: conversationId,
            senderId: senderId,
            content: content,
            type: type,
            status: status,
            createdAt: createdAt,
            isMine: isMine,
            rowid: rowid,
          ),
        ));
}

class $$MessagesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isMine => $state.composableBuilder(
      column: $state.table.isMine,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $state.db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ConversationsTableFilterComposer(ComposerState($state.db,
                $state.db.conversations, joinBuilder, parentComposers)));
    return composer;
  }

  $$UsersTableFilterComposer get senderId {
    final $$UsersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.senderId,
        referencedTable: $state.db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$UsersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.users, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isMine => $state.composableBuilder(
      column: $state.table.isMine,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.conversationId,
            referencedTable: $state.db.conversations,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ConversationsTableOrderingComposer(ComposerState($state.db,
                    $state.db.conversations, joinBuilder, parentComposers)));
    return composer;
  }

  $$UsersTableOrderingComposer get senderId {
    final $$UsersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.senderId,
        referencedTable: $state.db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$UsersTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.users, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
}
