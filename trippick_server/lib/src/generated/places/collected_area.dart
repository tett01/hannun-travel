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

/// An area whose places have already been collected from TourAPI / Kakao.
abstract class CollectedArea
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CollectedArea._({
    this.id,
    required this.lat,
    required this.lng,
    DateTime? collectedAt,
  }) : collectedAt = collectedAt ?? DateTime.now();

  factory CollectedArea({
    int? id,
    required double lat,
    required double lng,
    DateTime? collectedAt,
  }) = _CollectedAreaImpl;

  factory CollectedArea.fromJson(Map<String, dynamic> jsonSerialization) {
    return CollectedArea(
      id: jsonSerialization['id'] as int?,
      lat: (jsonSerialization['lat'] as num).toDouble(),
      lng: (jsonSerialization['lng'] as num).toDouble(),
      collectedAt: jsonSerialization['collectedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['collectedAt'],
            ),
    );
  }

  static final t = CollectedAreaTable();

  static const db = CollectedAreaRepository._();

  @override
  int? id;

  double lat;

  double lng;

  DateTime collectedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CollectedArea]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CollectedArea copyWith({
    int? id,
    double? lat,
    double? lng,
    DateTime? collectedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CollectedArea',
      if (id != null) 'id': id,
      'lat': lat,
      'lng': lng,
      'collectedAt': collectedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CollectedAreaInclude include() {
    return CollectedAreaInclude._();
  }

  static CollectedAreaIncludeList includeList({
    _is.WhereExpressionBuilder<CollectedAreaTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CollectedAreaTable>? orderBy,
    _is.OrderByListBuilder<CollectedAreaTable>? orderByList,
    CollectedAreaInclude? include,
  }) {
    return CollectedAreaIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CollectedArea.t),
      orderByList: orderByList?.call(CollectedArea.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CollectedAreaImpl extends CollectedArea {
  _CollectedAreaImpl({
    int? id,
    required double lat,
    required double lng,
    DateTime? collectedAt,
  }) : super._(
         id: id,
         lat: lat,
         lng: lng,
         collectedAt: collectedAt,
       );

  /// Returns a shallow copy of this [CollectedArea]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CollectedArea copyWith({
    Object? id = _Undefined,
    double? lat,
    double? lng,
    DateTime? collectedAt,
  }) {
    return CollectedArea(
      id: id is int? ? id : this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }
}

class CollectedAreaUpdateTable extends _is.UpdateTable<CollectedAreaTable> {
  CollectedAreaUpdateTable(super.table);

  _is.ColumnValue<double, double> lat(double value) => _is.ColumnValue(
    table.lat,
    value,
  );

  _is.ColumnValue<double, double> lng(double value) => _is.ColumnValue(
    table.lng,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> collectedAt(DateTime value) =>
      _is.ColumnValue(
        table.collectedAt,
        value,
      );
}

class CollectedAreaTable extends _is.Table<int?> {
  CollectedAreaTable({super.tableRelation})
    : super(tableName: 'collected_area') {
    updateTable = CollectedAreaUpdateTable(this);
    lat = _is.ColumnDouble(
      'lat',
      this,
    );
    lng = _is.ColumnDouble(
      'lng',
      this,
    );
    collectedAt = _is.ColumnDateTime(
      'collectedAt',
      this,
      hasDefault: true,
    );
  }

  late final CollectedAreaUpdateTable updateTable;

  late final _is.ColumnDouble lat;

  late final _is.ColumnDouble lng;

  late final _is.ColumnDateTime collectedAt;

  @override
  List<_is.Column> get columns => [
    id,
    lat,
    lng,
    collectedAt,
  ];
}

class CollectedAreaInclude extends _is.IncludeObject {
  CollectedAreaInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CollectedArea.t;
}

class CollectedAreaIncludeList extends _is.IncludeList {
  CollectedAreaIncludeList._({
    _is.WhereExpressionBuilder<CollectedAreaTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CollectedArea.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CollectedArea.t;
}

class CollectedAreaRepository {
  const CollectedAreaRepository._();

  /// Returns a list of [CollectedArea]s matching the given query parameters.
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
  Future<List<CollectedArea>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CollectedAreaTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CollectedAreaTable>? orderBy,
    _is.OrderByListBuilder<CollectedAreaTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CollectedArea>(
      where: where?.call(CollectedArea.t),
      orderBy: orderBy?.call(CollectedArea.t),
      orderByList: orderByList?.call(CollectedArea.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CollectedArea] matching the given query parameters.
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
  Future<CollectedArea?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CollectedAreaTable>? where,
    int? offset,
    _is.OrderByBuilder<CollectedAreaTable>? orderBy,
    _is.OrderByListBuilder<CollectedAreaTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CollectedArea>(
      where: where?.call(CollectedArea.t),
      orderBy: orderBy?.call(CollectedArea.t),
      orderByList: orderByList?.call(CollectedArea.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CollectedArea] by its [id] or null if no such row exists.
  Future<CollectedArea?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CollectedArea>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CollectedArea]s in the list and returns the inserted rows.
  ///
  /// The returned [CollectedArea]s will have their `id` fields set.
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
  Future<List<CollectedArea>> insert(
    _is.DatabaseSession session,
    List<CollectedArea> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CollectedArea>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CollectedArea] and returns the inserted row.
  ///
  /// The returned [CollectedArea] will have its `id` field set.
  Future<CollectedArea> insertRow(
    _is.DatabaseSession session,
    CollectedArea row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CollectedArea>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CollectedArea]s in the list and returns the resulting rows.
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
  /// The returned [CollectedArea]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CollectedArea>> upsert(
    _is.DatabaseSession session,
    List<CollectedArea> rows, {
    required _is.ColumnSelections<CollectedAreaTable> conflictColumns,
    _is.ColumnSelections<CollectedAreaTable>? updateColumns,
    _is.WhereExpressionBuilder<CollectedAreaTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CollectedArea>(
      rows,
      conflictColumns: conflictColumns(CollectedArea.t),
      updateColumns: updateColumns?.call(CollectedArea.t),
      updateWhere: updateWhere?.call(CollectedArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CollectedArea] and returns the resulting row.
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
  /// The returned [CollectedArea] will have its `id` field set.
  Future<CollectedArea?> upsertRow(
    _is.DatabaseSession session,
    CollectedArea row, {
    required _is.ColumnSelections<CollectedAreaTable> conflictColumns,
    _is.ColumnSelections<CollectedAreaTable>? updateColumns,
    _is.WhereExpressionBuilder<CollectedAreaTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CollectedArea>(
      row,
      conflictColumns: conflictColumns(CollectedArea.t),
      updateColumns: updateColumns?.call(CollectedArea.t),
      updateWhere: updateWhere?.call(CollectedArea.t),
      transaction: transaction,
    );
  }

  /// Updates all [CollectedArea]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CollectedArea>> update(
    _is.DatabaseSession session,
    List<CollectedArea> rows, {
    _is.ColumnSelections<CollectedAreaTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CollectedArea>(
      rows,
      columns: columns?.call(CollectedArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CollectedArea]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CollectedArea> updateRow(
    _is.DatabaseSession session,
    CollectedArea row, {
    _is.ColumnSelections<CollectedAreaTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CollectedArea>(
      row,
      columns: columns?.call(CollectedArea.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CollectedArea] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CollectedArea?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CollectedAreaUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CollectedArea>(
      id,
      columnValues: columnValues(CollectedArea.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CollectedArea]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CollectedArea>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CollectedAreaUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CollectedAreaTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CollectedAreaTable>? orderBy,
    _is.OrderByListBuilder<CollectedAreaTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CollectedArea>(
      columnValues: columnValues(CollectedArea.t.updateTable),
      where: where(CollectedArea.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CollectedArea.t),
      orderByList: orderByList?.call(CollectedArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CollectedArea]s in the list and returns the deleted rows.
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
  Future<List<CollectedArea>> delete(
    _is.DatabaseSession session,
    List<CollectedArea> rows, {
    _is.OrderByBuilder<CollectedAreaTable>? orderBy,
    _is.OrderByListBuilder<CollectedAreaTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CollectedArea>(
      rows,
      orderBy: orderBy?.call(CollectedArea.t),
      orderByList: orderByList?.call(CollectedArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CollectedArea].
  Future<CollectedArea> deleteRow(
    _is.DatabaseSession session,
    CollectedArea row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CollectedArea>(
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
  Future<List<CollectedArea>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CollectedAreaTable> where,
    _is.OrderByBuilder<CollectedAreaTable>? orderBy,
    _is.OrderByListBuilder<CollectedAreaTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CollectedArea>(
      where: where(CollectedArea.t),
      orderBy: orderBy?.call(CollectedArea.t),
      orderByList: orderByList?.call(CollectedArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CollectedAreaTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CollectedArea>(
      where: where?.call(CollectedArea.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CollectedArea] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CollectedAreaTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CollectedArea>(
      where: where(CollectedArea.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
