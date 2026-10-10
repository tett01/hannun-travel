/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

/// A review written in the app.
abstract class UserReview
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  UserReview._({
    this.id,
    required this.placeId,
    required this.author,
    required this.rating,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserReview({
    int? id,
    required int placeId,
    required String author,
    required int rating,
    required String text,
    DateTime? createdAt,
  }) = _UserReviewImpl;

  factory UserReview.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserReview(
      id: jsonSerialization['id'] as int?,
      placeId: jsonSerialization['placeId'] as int,
      author: jsonSerialization['author'] as String,
      rating: jsonSerialization['rating'] as int,
      text: jsonSerialization['text'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = UserReviewTable();

  static const db = UserReviewRepository._();

  @override
  int? id;

  int placeId;

  String author;

  /// 1 to 5
  int rating;

  String text;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserReview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UserReview copyWith({
    int? id,
    int? placeId,
    String? author,
    int? rating,
    String? text,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserReview',
      if (id != null) 'id': id,
      'placeId': placeId,
      'author': author,
      'rating': rating,
      'text': text,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserReview',
      if (id != null) 'id': id,
      'placeId': placeId,
      'author': author,
      'rating': rating,
      'text': text,
      'createdAt': createdAt.toJson(),
    };
  }

  static UserReviewInclude include() {
    return UserReviewInclude._();
  }

  static UserReviewIncludeList includeList({
    _is.WhereExpressionBuilder<UserReviewTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserReviewTable>? orderBy,
    _is.OrderByListBuilder<UserReviewTable>? orderByList,
    UserReviewInclude? include,
  }) {
    return UserReviewIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserReview.t),
      orderByList: orderByList?.call(UserReview.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserReviewImpl extends UserReview {
  _UserReviewImpl({
    int? id,
    required int placeId,
    required String author,
    required int rating,
    required String text,
    DateTime? createdAt,
  }) : super._(
         id: id,
         placeId: placeId,
         author: author,
         rating: rating,
         text: text,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [UserReview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  UserReview copyWith({
    Object? id = _Undefined,
    int? placeId,
    String? author,
    int? rating,
    String? text,
    DateTime? createdAt,
  }) {
    return UserReview(
      id: id is int? ? id : this.id,
      placeId: placeId ?? this.placeId,
      author: author ?? this.author,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserReviewUpdateTable extends _is.UpdateTable<UserReviewTable> {
  UserReviewUpdateTable(super.table);

  _is.ColumnValue<int, int> placeId(int value) => _is.ColumnValue(
    table.placeId,
    value,
  );

  _is.ColumnValue<String, String> author(String value) => _is.ColumnValue(
    table.author,
    value,
  );

  _is.ColumnValue<int, int> rating(int value) => _is.ColumnValue(
    table.rating,
    value,
  );

  _is.ColumnValue<String, String> text(String value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class UserReviewTable extends _is.Table<int?> {
  UserReviewTable({super.tableRelation}) : super(tableName: 'user_review') {
    updateTable = UserReviewUpdateTable(this);
    placeId = _is.ColumnInt(
      'placeId',
      this,
    );
    author = _is.ColumnString(
      'author',
      this,
    );
    rating = _is.ColumnInt(
      'rating',
      this,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final UserReviewUpdateTable updateTable;

  late final _is.ColumnInt placeId;

  late final _is.ColumnString author;

  /// 1 to 5
  late final _is.ColumnInt rating;

  late final _is.ColumnString text;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    placeId,
    author,
    rating,
    text,
    createdAt,
  ];
}

class UserReviewInclude extends _is.IncludeObject {
  UserReviewInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => UserReview.t;
}

class UserReviewIncludeList extends _is.IncludeList {
  UserReviewIncludeList._({
    _is.WhereExpressionBuilder<UserReviewTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserReview.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => UserReview.t;
}

class UserReviewRepository {
  const UserReviewRepository._();

  /// Returns a list of [UserReview]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<UserReview>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserReviewTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserReviewTable>? orderBy,
    _is.OrderByListBuilder<UserReviewTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserReview>(
      where: where?.call(UserReview.t),
      orderBy: orderBy?.call(UserReview.t),
      orderByList: orderByList?.call(UserReview.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserReview] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<UserReview?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserReviewTable>? where,
    int? offset,
    _is.OrderByBuilder<UserReviewTable>? orderBy,
    _is.OrderByListBuilder<UserReviewTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserReview>(
      where: where?.call(UserReview.t),
      orderBy: orderBy?.call(UserReview.t),
      orderByList: orderByList?.call(UserReview.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserReview] by its [id] or null if no such row exists.
  Future<UserReview?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserReview>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserReview]s in the list and returns the inserted rows.
  ///
  /// The returned [UserReview]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserReview>> insert(
    _is.DatabaseSession session,
    List<UserReview> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<UserReview>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [UserReview] and returns the inserted row.
  ///
  /// The returned [UserReview] will have its `id` field set.
  Future<UserReview> insertRow(
    _is.DatabaseSession session,
    UserReview row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserReview>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [UserReview]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [UserReview]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserReview>> upsert(
    _is.DatabaseSession session,
    List<UserReview> rows, {
    required _is.ColumnSelections<UserReviewTable> conflictColumns,
    _is.ColumnSelections<UserReviewTable>? updateColumns,
    _is.WhereExpressionBuilder<UserReviewTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<UserReview>(
      rows,
      conflictColumns: conflictColumns(UserReview.t),
      updateColumns: updateColumns?.call(UserReview.t),
      updateWhere: updateWhere?.call(UserReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [UserReview] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [UserReview] will have its `id` field set.
  Future<UserReview?> upsertRow(
    _is.DatabaseSession session,
    UserReview row, {
    required _is.ColumnSelections<UserReviewTable> conflictColumns,
    _is.ColumnSelections<UserReviewTable>? updateColumns,
    _is.WhereExpressionBuilder<UserReviewTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<UserReview>(
      row,
      conflictColumns: conflictColumns(UserReview.t),
      updateColumns: updateColumns?.call(UserReview.t),
      updateWhere: updateWhere?.call(UserReview.t),
      transaction: transaction,
    );
  }

  /// Updates all [UserReview]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserReview>> update(
    _is.DatabaseSession session,
    List<UserReview> rows, {
    _is.ColumnSelections<UserReviewTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<UserReview>(
      rows,
      columns: columns?.call(UserReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [UserReview]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserReview> updateRow(
    _is.DatabaseSession session,
    UserReview row, {
    _is.ColumnSelections<UserReviewTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserReview>(
      row,
      columns: columns?.call(UserReview.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserReview] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserReview?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<UserReviewUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<UserReview>(
      id,
      columnValues: columnValues(UserReview.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserReview]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserReview>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UserReviewUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<UserReviewTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserReviewTable>? orderBy,
    _is.OrderByListBuilder<UserReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<UserReview>(
      columnValues: columnValues(UserReview.t.updateTable),
      where: where(UserReview.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserReview.t),
      orderByList: orderByList?.call(UserReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [UserReview]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserReview>> delete(
    _is.DatabaseSession session,
    List<UserReview> rows, {
    _is.OrderByBuilder<UserReviewTable>? orderBy,
    _is.OrderByListBuilder<UserReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<UserReview>(
      rows,
      orderBy: orderBy?.call(UserReview.t),
      orderByList: orderByList?.call(UserReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [UserReview].
  Future<UserReview> deleteRow(
    _is.DatabaseSession session,
    UserReview row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserReview>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserReview>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserReviewTable> where,
    _is.OrderByBuilder<UserReviewTable>? orderBy,
    _is.OrderByListBuilder<UserReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<UserReview>(
      where: where(UserReview.t),
      orderBy: orderBy?.call(UserReview.t),
      orderByList: orderByList?.call(UserReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserReviewTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<UserReview>(
      where: where?.call(UserReview.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserReview] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserReviewTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserReview>(
      where: where(UserReview.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
