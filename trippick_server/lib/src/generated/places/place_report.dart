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

/// A traveler's report that a place differs from the info shown in the app,
/// e.g. it has closed or its hours changed.
abstract class PlaceReport
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PlaceReport._({
    this.id,
    required this.placeId,
    required this.kind,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PlaceReport({
    int? id,
    required int placeId,
    required String kind,
    String? note,
    DateTime? createdAt,
  }) = _PlaceReportImpl;

  factory PlaceReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaceReport(
      id: jsonSerialization['id'] as int?,
      placeId: jsonSerialization['placeId'] as int,
      kind: jsonSerialization['kind'] as String,
      note: jsonSerialization['note'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = PlaceReportTable();

  static const db = PlaceReportRepository._();

  @override
  int? id;

  int placeId;

  /// closed_forever | hours | break_time | closed_day | other
  String kind;

  String? note;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PlaceReport]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlaceReport copyWith({
    int? id,
    int? placeId,
    String? kind,
    String? note,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaceReport',
      if (id != null) 'id': id,
      'placeId': placeId,
      'kind': kind,
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlaceReport',
      if (id != null) 'id': id,
      'placeId': placeId,
      'kind': kind,
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
    };
  }

  static PlaceReportInclude include() {
    return PlaceReportInclude._();
  }

  static PlaceReportIncludeList includeList({
    _is.WhereExpressionBuilder<PlaceReportTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaceReportTable>? orderBy,
    _is.OrderByListBuilder<PlaceReportTable>? orderByList,
    PlaceReportInclude? include,
  }) {
    return PlaceReportIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlaceReport.t),
      orderByList: orderByList?.call(PlaceReport.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlaceReportImpl extends PlaceReport {
  _PlaceReportImpl({
    int? id,
    required int placeId,
    required String kind,
    String? note,
    DateTime? createdAt,
  }) : super._(
         id: id,
         placeId: placeId,
         kind: kind,
         note: note,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PlaceReport]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlaceReport copyWith({
    Object? id = _Undefined,
    int? placeId,
    String? kind,
    Object? note = _Undefined,
    DateTime? createdAt,
  }) {
    return PlaceReport(
      id: id is int? ? id : this.id,
      placeId: placeId ?? this.placeId,
      kind: kind ?? this.kind,
      note: note is String? ? note : this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PlaceReportUpdateTable extends _is.UpdateTable<PlaceReportTable> {
  PlaceReportUpdateTable(super.table);

  _is.ColumnValue<int, int> placeId(int value) => _is.ColumnValue(
    table.placeId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class PlaceReportTable extends _is.Table<int?> {
  PlaceReportTable({super.tableRelation}) : super(tableName: 'place_report') {
    updateTable = PlaceReportUpdateTable(this);
    placeId = _is.ColumnInt(
      'placeId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final PlaceReportUpdateTable updateTable;

  late final _is.ColumnInt placeId;

  /// closed_forever | hours | break_time | closed_day | other
  late final _is.ColumnString kind;

  late final _is.ColumnString note;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    placeId,
    kind,
    note,
    createdAt,
  ];
}

class PlaceReportInclude extends _is.IncludeObject {
  PlaceReportInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PlaceReport.t;
}

class PlaceReportIncludeList extends _is.IncludeList {
  PlaceReportIncludeList._({
    _is.WhereExpressionBuilder<PlaceReportTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PlaceReport.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PlaceReport.t;
}

class PlaceReportRepository {
  const PlaceReportRepository._();

  /// Returns a list of [PlaceReport]s matching the given query parameters.
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
  Future<List<PlaceReport>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaceReportTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaceReportTable>? orderBy,
    _is.OrderByListBuilder<PlaceReportTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PlaceReport>(
      where: where?.call(PlaceReport.t),
      orderBy: orderBy?.call(PlaceReport.t),
      orderByList: orderByList?.call(PlaceReport.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PlaceReport] matching the given query parameters.
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
  Future<PlaceReport?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaceReportTable>? where,
    int? offset,
    _is.OrderByBuilder<PlaceReportTable>? orderBy,
    _is.OrderByListBuilder<PlaceReportTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PlaceReport>(
      where: where?.call(PlaceReport.t),
      orderBy: orderBy?.call(PlaceReport.t),
      orderByList: orderByList?.call(PlaceReport.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PlaceReport] by its [id] or null if no such row exists.
  Future<PlaceReport?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PlaceReport>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PlaceReport]s in the list and returns the inserted rows.
  ///
  /// The returned [PlaceReport]s will have their `id` fields set.
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
  Future<List<PlaceReport>> insert(
    _is.DatabaseSession session,
    List<PlaceReport> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PlaceReport>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PlaceReport] and returns the inserted row.
  ///
  /// The returned [PlaceReport] will have its `id` field set.
  Future<PlaceReport> insertRow(
    _is.DatabaseSession session,
    PlaceReport row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PlaceReport>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PlaceReport]s in the list and returns the resulting rows.
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
  /// The returned [PlaceReport]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaceReport>> upsert(
    _is.DatabaseSession session,
    List<PlaceReport> rows, {
    required _is.ColumnSelections<PlaceReportTable> conflictColumns,
    _is.ColumnSelections<PlaceReportTable>? updateColumns,
    _is.WhereExpressionBuilder<PlaceReportTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PlaceReport>(
      rows,
      conflictColumns: conflictColumns(PlaceReport.t),
      updateColumns: updateColumns?.call(PlaceReport.t),
      updateWhere: updateWhere?.call(PlaceReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PlaceReport] and returns the resulting row.
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
  /// The returned [PlaceReport] will have its `id` field set.
  Future<PlaceReport?> upsertRow(
    _is.DatabaseSession session,
    PlaceReport row, {
    required _is.ColumnSelections<PlaceReportTable> conflictColumns,
    _is.ColumnSelections<PlaceReportTable>? updateColumns,
    _is.WhereExpressionBuilder<PlaceReportTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PlaceReport>(
      row,
      conflictColumns: conflictColumns(PlaceReport.t),
      updateColumns: updateColumns?.call(PlaceReport.t),
      updateWhere: updateWhere?.call(PlaceReport.t),
      transaction: transaction,
    );
  }

  /// Updates all [PlaceReport]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaceReport>> update(
    _is.DatabaseSession session,
    List<PlaceReport> rows, {
    _is.ColumnSelections<PlaceReportTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PlaceReport>(
      rows,
      columns: columns?.call(PlaceReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PlaceReport]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PlaceReport> updateRow(
    _is.DatabaseSession session,
    PlaceReport row, {
    _is.ColumnSelections<PlaceReportTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PlaceReport>(
      row,
      columns: columns?.call(PlaceReport.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PlaceReport] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PlaceReport?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PlaceReportUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PlaceReport>(
      id,
      columnValues: columnValues(PlaceReport.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PlaceReport]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaceReport>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PlaceReportUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PlaceReportTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaceReportTable>? orderBy,
    _is.OrderByListBuilder<PlaceReportTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PlaceReport>(
      columnValues: columnValues(PlaceReport.t.updateTable),
      where: where(PlaceReport.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlaceReport.t),
      orderByList: orderByList?.call(PlaceReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PlaceReport]s in the list and returns the deleted rows.
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
  Future<List<PlaceReport>> delete(
    _is.DatabaseSession session,
    List<PlaceReport> rows, {
    _is.OrderByBuilder<PlaceReportTable>? orderBy,
    _is.OrderByListBuilder<PlaceReportTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PlaceReport>(
      rows,
      orderBy: orderBy?.call(PlaceReport.t),
      orderByList: orderByList?.call(PlaceReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PlaceReport].
  Future<PlaceReport> deleteRow(
    _is.DatabaseSession session,
    PlaceReport row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PlaceReport>(
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
  Future<List<PlaceReport>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlaceReportTable> where,
    _is.OrderByBuilder<PlaceReportTable>? orderBy,
    _is.OrderByListBuilder<PlaceReportTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PlaceReport>(
      where: where(PlaceReport.t),
      orderBy: orderBy?.call(PlaceReport.t),
      orderByList: orderByList?.call(PlaceReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaceReportTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PlaceReport>(
      where: where?.call(PlaceReport.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PlaceReport] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlaceReportTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PlaceReport>(
      where: where(PlaceReport.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
