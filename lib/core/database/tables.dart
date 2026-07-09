import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localId => text().nullable()();
  TextColumn get serverId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get businessName => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get token => text().nullable()();
  TextColumn get subscription => text().withDefault(const Constant('free'))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localId => text().nullable()();
  TextColumn get serverId => text().nullable()();
  IntColumn get userId => integer().nullable()();
  TextColumn get vendor => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  IntColumn get categoryId => integer().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get clientName => text().nullable()();
  TextColumn get projectName => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get receiptImageLocalPath => text().nullable()();
  TextColumn get receiptImageRemoteUrl => text().nullable()();
  RealColumn get aiConfidence => real().nullable()();
  TextColumn get aiExplanation => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localId => text().nullable()();
  TextColumn get serverId => text().nullable()();
  IntColumn get userId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'Business' | 'Personal'
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()(); // 'create', 'update', 'delete'
  TextColumn get targetTable => text()(); // 'expenses', 'categories'
  TextColumn get localRecordId => text()();
  TextColumn get payload => text().nullable()(); // JSON string
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
}
