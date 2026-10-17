// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LibrarySourcesTableTable extends LibrarySourcesTable
    with TableInfo<$LibrarySourcesTableTable, LibrarySourcesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibrarySourcesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locatorMeta = const VerificationMeta(
    'locator',
  );
  @override
  late final GeneratedColumn<String> locator = GeneratedColumn<String>(
    'locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _lastSuccessfulScanMeta =
      const VerificationMeta('lastSuccessfulScan');
  @override
  late final GeneratedColumn<int> lastSuccessfulScan = GeneratedColumn<int>(
    'last_successful_scan',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scanGenerationMeta = const VerificationMeta(
    'scanGeneration',
  );
  @override
  late final GeneratedColumn<int> scanGeneration = GeneratedColumn<int>(
    'scan_generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    locator,
    status,
    lastSuccessfulScan,
    scanGeneration,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibrarySourcesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('locator')) {
      context.handle(
        _locatorMeta,
        locator.isAcceptableOrUnknown(data['locator']!, _locatorMeta),
      );
    } else if (isInserting) {
      context.missing(_locatorMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_successful_scan')) {
      context.handle(
        _lastSuccessfulScanMeta,
        lastSuccessfulScan.isAcceptableOrUnknown(
          data['last_successful_scan']!,
          _lastSuccessfulScanMeta,
        ),
      );
    }
    if (data.containsKey('scan_generation')) {
      context.handle(
        _scanGenerationMeta,
        scanGeneration.isAcceptableOrUnknown(
          data['scan_generation']!,
          _scanGenerationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibrarySourcesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibrarySourcesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      locator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastSuccessfulScan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_successful_scan'],
      ),
      scanGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_generation'],
      )!,
    );
  }

  @override
  $LibrarySourcesTableTable createAlias(String alias) {
    return $LibrarySourcesTableTable(attachedDatabase, alias);
  }
}

class LibrarySourcesTableData extends DataClass
    implements Insertable<LibrarySourcesTableData> {
  final String id;
  final String kind;
  final String locator;
  final String status;
  final int? lastSuccessfulScan;
  final int scanGeneration;
  const LibrarySourcesTableData({
    required this.id,
    required this.kind,
    required this.locator,
    required this.status,
    this.lastSuccessfulScan,
    required this.scanGeneration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['locator'] = Variable<String>(locator);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastSuccessfulScan != null) {
      map['last_successful_scan'] = Variable<int>(lastSuccessfulScan);
    }
    map['scan_generation'] = Variable<int>(scanGeneration);
    return map;
  }

  LibrarySourcesTableCompanion toCompanion(bool nullToAbsent) {
    return LibrarySourcesTableCompanion(
      id: Value(id),
      kind: Value(kind),
      locator: Value(locator),
      status: Value(status),
      lastSuccessfulScan: lastSuccessfulScan == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulScan),
      scanGeneration: Value(scanGeneration),
    );
  }

  factory LibrarySourcesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibrarySourcesTableData(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      locator: serializer.fromJson<String>(json['locator']),
      status: serializer.fromJson<String>(json['status']),
      lastSuccessfulScan: serializer.fromJson<int?>(json['lastSuccessfulScan']),
      scanGeneration: serializer.fromJson<int>(json['scanGeneration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'locator': serializer.toJson<String>(locator),
      'status': serializer.toJson<String>(status),
      'lastSuccessfulScan': serializer.toJson<int?>(lastSuccessfulScan),
      'scanGeneration': serializer.toJson<int>(scanGeneration),
    };
  }

  LibrarySourcesTableData copyWith({
    String? id,
    String? kind,
    String? locator,
    String? status,
    Value<int?> lastSuccessfulScan = const Value.absent(),
    int? scanGeneration,
  }) => LibrarySourcesTableData(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    locator: locator ?? this.locator,
    status: status ?? this.status,
    lastSuccessfulScan: lastSuccessfulScan.present
        ? lastSuccessfulScan.value
        : this.lastSuccessfulScan,
    scanGeneration: scanGeneration ?? this.scanGeneration,
  );
  LibrarySourcesTableData copyWithCompanion(LibrarySourcesTableCompanion data) {
    return LibrarySourcesTableData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      locator: data.locator.present ? data.locator.value : this.locator,
      status: data.status.present ? data.status.value : this.status,
      lastSuccessfulScan: data.lastSuccessfulScan.present
          ? data.lastSuccessfulScan.value
          : this.lastSuccessfulScan,
      scanGeneration: data.scanGeneration.present
          ? data.scanGeneration.value
          : this.scanGeneration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibrarySourcesTableData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('locator: $locator, ')
          ..write('status: $status, ')
          ..write('lastSuccessfulScan: $lastSuccessfulScan, ')
          ..write('scanGeneration: $scanGeneration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    locator,
    status,
    lastSuccessfulScan,
    scanGeneration,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibrarySourcesTableData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.locator == this.locator &&
          other.status == this.status &&
          other.lastSuccessfulScan == this.lastSuccessfulScan &&
          other.scanGeneration == this.scanGeneration);
}

class LibrarySourcesTableCompanion
    extends UpdateCompanion<LibrarySourcesTableData> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> locator;
  final Value<String> status;
  final Value<int?> lastSuccessfulScan;
  final Value<int> scanGeneration;
  final Value<int> rowid;
  const LibrarySourcesTableCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.locator = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSuccessfulScan = const Value.absent(),
    this.scanGeneration = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibrarySourcesTableCompanion.insert({
    required String id,
    required String kind,
    required String locator,
    this.status = const Value.absent(),
    this.lastSuccessfulScan = const Value.absent(),
    this.scanGeneration = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       locator = Value(locator);
  static Insertable<LibrarySourcesTableData> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? locator,
    Expression<String>? status,
    Expression<int>? lastSuccessfulScan,
    Expression<int>? scanGeneration,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (locator != null) 'locator': locator,
      if (status != null) 'status': status,
      if (lastSuccessfulScan != null)
        'last_successful_scan': lastSuccessfulScan,
      if (scanGeneration != null) 'scan_generation': scanGeneration,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibrarySourcesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? locator,
    Value<String>? status,
    Value<int?>? lastSuccessfulScan,
    Value<int>? scanGeneration,
    Value<int>? rowid,
  }) {
    return LibrarySourcesTableCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      locator: locator ?? this.locator,
      status: status ?? this.status,
      lastSuccessfulScan: lastSuccessfulScan ?? this.lastSuccessfulScan,
      scanGeneration: scanGeneration ?? this.scanGeneration,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(locator.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastSuccessfulScan.present) {
      map['last_successful_scan'] = Variable<int>(lastSuccessfulScan.value);
    }
    if (scanGeneration.present) {
      map['scan_generation'] = Variable<int>(scanGeneration.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibrarySourcesTableCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('locator: $locator, ')
          ..write('status: $status, ')
          ..write('lastSuccessfulScan: $lastSuccessfulScan, ')
          ..write('scanGeneration: $scanGeneration, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TracksTableTable extends TracksTable
    with TableInfo<$TracksTableTable, TracksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleSortMeta = const VerificationMeta(
    'titleSort',
  );
  @override
  late final GeneratedColumn<String> titleSort = GeneratedColumn<String>(
    'title_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistNameMeta = const VerificationMeta(
    'artistName',
  );
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
    'artist_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumTitleMeta = const VerificationMeta(
    'albumTitle',
  );
  @override
  late final GeneratedColumn<String> albumTitle = GeneratedColumn<String>(
    'album_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNoMeta = const VerificationMeta(
    'trackNo',
  );
  @override
  late final GeneratedColumn<int> trackNo = GeneratedColumn<int>(
    'track_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discNoMeta = const VerificationMeta('discNo');
  @override
  late final GeneratedColumn<int> discNo = GeneratedColumn<int>(
    'disc_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkIdMeta = const VerificationMeta(
    'artworkId',
  );
  @override
  late final GeneratedColumn<String> artworkId = GeneratedColumn<String>(
    'artwork_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    titleSort,
    artistName,
    albumTitle,
    albumId,
    durationMs,
    trackNo,
    discNo,
    year,
    artworkId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TracksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_sort')) {
      context.handle(
        _titleSortMeta,
        titleSort.isAcceptableOrUnknown(data['title_sort']!, _titleSortMeta),
      );
    } else if (isInserting) {
      context.missing(_titleSortMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
        _artistNameMeta,
        artistName.isAcceptableOrUnknown(data['artist_name']!, _artistNameMeta),
      );
    }
    if (data.containsKey('album_title')) {
      context.handle(
        _albumTitleMeta,
        albumTitle.isAcceptableOrUnknown(data['album_title']!, _albumTitleMeta),
      );
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('track_no')) {
      context.handle(
        _trackNoMeta,
        trackNo.isAcceptableOrUnknown(data['track_no']!, _trackNoMeta),
      );
    }
    if (data.containsKey('disc_no')) {
      context.handle(
        _discNoMeta,
        discNo.isAcceptableOrUnknown(data['disc_no']!, _discNoMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('artwork_id')) {
      context.handle(
        _artworkIdMeta,
        artworkId.isAcceptableOrUnknown(data['artwork_id']!, _artworkIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TracksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TracksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_sort'],
      )!,
      artistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_name'],
      ),
      albumTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_title'],
      ),
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      trackNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_no'],
      ),
      discNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_no'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      artworkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_id'],
      ),
    );
  }

  @override
  $TracksTableTable createAlias(String alias) {
    return $TracksTableTable(attachedDatabase, alias);
  }
}

class TracksTableData extends DataClass implements Insertable<TracksTableData> {
  final String id;
  final String title;
  final String titleSort;
  final String? artistName;
  final String? albumTitle;
  final String? albumId;
  final int? durationMs;
  final int? trackNo;
  final int? discNo;
  final int? year;
  final String? artworkId;
  const TracksTableData({
    required this.id,
    required this.title,
    required this.titleSort,
    this.artistName,
    this.albumTitle,
    this.albumId,
    this.durationMs,
    this.trackNo,
    this.discNo,
    this.year,
    this.artworkId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['title_sort'] = Variable<String>(titleSort);
    if (!nullToAbsent || artistName != null) {
      map['artist_name'] = Variable<String>(artistName);
    }
    if (!nullToAbsent || albumTitle != null) {
      map['album_title'] = Variable<String>(albumTitle);
    }
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<String>(albumId);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || trackNo != null) {
      map['track_no'] = Variable<int>(trackNo);
    }
    if (!nullToAbsent || discNo != null) {
      map['disc_no'] = Variable<int>(discNo);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || artworkId != null) {
      map['artwork_id'] = Variable<String>(artworkId);
    }
    return map;
  }

  TracksTableCompanion toCompanion(bool nullToAbsent) {
    return TracksTableCompanion(
      id: Value(id),
      title: Value(title),
      titleSort: Value(titleSort),
      artistName: artistName == null && nullToAbsent
          ? const Value.absent()
          : Value(artistName),
      albumTitle: albumTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(albumTitle),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      trackNo: trackNo == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNo),
      discNo: discNo == null && nullToAbsent
          ? const Value.absent()
          : Value(discNo),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      artworkId: artworkId == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkId),
    );
  }

  factory TracksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TracksTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      titleSort: serializer.fromJson<String>(json['titleSort']),
      artistName: serializer.fromJson<String?>(json['artistName']),
      albumTitle: serializer.fromJson<String?>(json['albumTitle']),
      albumId: serializer.fromJson<String?>(json['albumId']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      trackNo: serializer.fromJson<int?>(json['trackNo']),
      discNo: serializer.fromJson<int?>(json['discNo']),
      year: serializer.fromJson<int?>(json['year']),
      artworkId: serializer.fromJson<String?>(json['artworkId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'titleSort': serializer.toJson<String>(titleSort),
      'artistName': serializer.toJson<String?>(artistName),
      'albumTitle': serializer.toJson<String?>(albumTitle),
      'albumId': serializer.toJson<String?>(albumId),
      'durationMs': serializer.toJson<int?>(durationMs),
      'trackNo': serializer.toJson<int?>(trackNo),
      'discNo': serializer.toJson<int?>(discNo),
      'year': serializer.toJson<int?>(year),
      'artworkId': serializer.toJson<String?>(artworkId),
    };
  }

  TracksTableData copyWith({
    String? id,
    String? title,
    String? titleSort,
    Value<String?> artistName = const Value.absent(),
    Value<String?> albumTitle = const Value.absent(),
    Value<String?> albumId = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<int?> trackNo = const Value.absent(),
    Value<int?> discNo = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> artworkId = const Value.absent(),
  }) => TracksTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    titleSort: titleSort ?? this.titleSort,
    artistName: artistName.present ? artistName.value : this.artistName,
    albumTitle: albumTitle.present ? albumTitle.value : this.albumTitle,
    albumId: albumId.present ? albumId.value : this.albumId,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    trackNo: trackNo.present ? trackNo.value : this.trackNo,
    discNo: discNo.present ? discNo.value : this.discNo,
    year: year.present ? year.value : this.year,
    artworkId: artworkId.present ? artworkId.value : this.artworkId,
  );
  TracksTableData copyWithCompanion(TracksTableCompanion data) {
    return TracksTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      titleSort: data.titleSort.present ? data.titleSort.value : this.titleSort,
      artistName: data.artistName.present
          ? data.artistName.value
          : this.artistName,
      albumTitle: data.albumTitle.present
          ? data.albumTitle.value
          : this.albumTitle,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      trackNo: data.trackNo.present ? data.trackNo.value : this.trackNo,
      discNo: data.discNo.present ? data.discNo.value : this.discNo,
      year: data.year.present ? data.year.value : this.year,
      artworkId: data.artworkId.present ? data.artworkId.value : this.artworkId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TracksTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleSort: $titleSort, ')
          ..write('artistName: $artistName, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('albumId: $albumId, ')
          ..write('durationMs: $durationMs, ')
          ..write('trackNo: $trackNo, ')
          ..write('discNo: $discNo, ')
          ..write('year: $year, ')
          ..write('artworkId: $artworkId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    titleSort,
    artistName,
    albumTitle,
    albumId,
    durationMs,
    trackNo,
    discNo,
    year,
    artworkId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TracksTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.titleSort == this.titleSort &&
          other.artistName == this.artistName &&
          other.albumTitle == this.albumTitle &&
          other.albumId == this.albumId &&
          other.durationMs == this.durationMs &&
          other.trackNo == this.trackNo &&
          other.discNo == this.discNo &&
          other.year == this.year &&
          other.artworkId == this.artworkId);
}

class TracksTableCompanion extends UpdateCompanion<TracksTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> titleSort;
  final Value<String?> artistName;
  final Value<String?> albumTitle;
  final Value<String?> albumId;
  final Value<int?> durationMs;
  final Value<int?> trackNo;
  final Value<int?> discNo;
  final Value<int?> year;
  final Value<String?> artworkId;
  final Value<int> rowid;
  const TracksTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.titleSort = const Value.absent(),
    this.artistName = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.albumId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.trackNo = const Value.absent(),
    this.discNo = const Value.absent(),
    this.year = const Value.absent(),
    this.artworkId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksTableCompanion.insert({
    required String id,
    required String title,
    required String titleSort,
    this.artistName = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.albumId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.trackNo = const Value.absent(),
    this.discNo = const Value.absent(),
    this.year = const Value.absent(),
    this.artworkId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       titleSort = Value(titleSort);
  static Insertable<TracksTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? titleSort,
    Expression<String>? artistName,
    Expression<String>? albumTitle,
    Expression<String>? albumId,
    Expression<int>? durationMs,
    Expression<int>? trackNo,
    Expression<int>? discNo,
    Expression<int>? year,
    Expression<String>? artworkId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (titleSort != null) 'title_sort': titleSort,
      if (artistName != null) 'artist_name': artistName,
      if (albumTitle != null) 'album_title': albumTitle,
      if (albumId != null) 'album_id': albumId,
      if (durationMs != null) 'duration_ms': durationMs,
      if (trackNo != null) 'track_no': trackNo,
      if (discNo != null) 'disc_no': discNo,
      if (year != null) 'year': year,
      if (artworkId != null) 'artwork_id': artworkId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? titleSort,
    Value<String?>? artistName,
    Value<String?>? albumTitle,
    Value<String?>? albumId,
    Value<int?>? durationMs,
    Value<int?>? trackNo,
    Value<int?>? discNo,
    Value<int?>? year,
    Value<String?>? artworkId,
    Value<int>? rowid,
  }) {
    return TracksTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      titleSort: titleSort ?? this.titleSort,
      artistName: artistName ?? this.artistName,
      albumTitle: albumTitle ?? this.albumTitle,
      albumId: albumId ?? this.albumId,
      durationMs: durationMs ?? this.durationMs,
      trackNo: trackNo ?? this.trackNo,
      discNo: discNo ?? this.discNo,
      year: year ?? this.year,
      artworkId: artworkId ?? this.artworkId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleSort.present) {
      map['title_sort'] = Variable<String>(titleSort.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (albumTitle.present) {
      map['album_title'] = Variable<String>(albumTitle.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (trackNo.present) {
      map['track_no'] = Variable<int>(trackNo.value);
    }
    if (discNo.present) {
      map['disc_no'] = Variable<int>(discNo.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (artworkId.present) {
      map['artwork_id'] = Variable<String>(artworkId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleSort: $titleSort, ')
          ..write('artistName: $artistName, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('albumId: $albumId, ')
          ..write('durationMs: $durationMs, ')
          ..write('trackNo: $trackNo, ')
          ..write('discNo: $discNo, ')
          ..write('year: $year, ')
          ..write('artworkId: $artworkId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtistsTableTable extends ArtistsTable
    with TableInfo<$ArtistsTableTable, ArtistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortNameMeta = const VerificationMeta(
    'sortName',
  );
  @override
  late final GeneratedColumn<String> sortName = GeneratedColumn<String>(
    'sort_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_name')) {
      context.handle(
        _sortNameMeta,
        sortName.isAcceptableOrUnknown(data['sort_name']!, _sortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sortNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_name'],
      )!,
    );
  }

  @override
  $ArtistsTableTable createAlias(String alias) {
    return $ArtistsTableTable(attachedDatabase, alias);
  }
}

class ArtistsTableData extends DataClass
    implements Insertable<ArtistsTableData> {
  final String id;
  final String name;
  final String sortName;
  const ArtistsTableData({
    required this.id,
    required this.name,
    required this.sortName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_name'] = Variable<String>(sortName);
    return map;
  }

  ArtistsTableCompanion toCompanion(bool nullToAbsent) {
    return ArtistsTableCompanion(
      id: Value(id),
      name: Value(name),
      sortName: Value(sortName),
    );
  }

  factory ArtistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortName: serializer.fromJson<String>(json['sortName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortName': serializer.toJson<String>(sortName),
    };
  }

  ArtistsTableData copyWith({String? id, String? name, String? sortName}) =>
      ArtistsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        sortName: sortName ?? this.sortName,
      );
  ArtistsTableData copyWithCompanion(ArtistsTableCompanion data) {
    return ArtistsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortName: data.sortName.present ? data.sortName.value : this.sortName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortName: $sortName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortName == this.sortName);
}

class ArtistsTableCompanion extends UpdateCompanion<ArtistsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> sortName;
  final Value<int> rowid;
  const ArtistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistsTableCompanion.insert({
    required String id,
    required String name,
    required String sortName,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sortName = Value(sortName);
  static Insertable<ArtistsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sortName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortName != null) 'sort_name': sortName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? sortName,
    Value<int>? rowid,
  }) {
    return ArtistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortName: sortName ?? this.sortName,
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
    if (sortName.present) {
      map['sort_name'] = Variable<String>(sortName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortName: $sortName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackArtistsTableTable extends TrackArtistsTable
    with TableInfo<$TrackArtistsTableTable, TrackArtistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackArtistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('primary'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, artistId, role, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackArtistsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId, artistId};
  @override
  TrackArtistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackArtistsTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TrackArtistsTableTable createAlias(String alias) {
    return $TrackArtistsTableTable(attachedDatabase, alias);
  }
}

class TrackArtistsTableData extends DataClass
    implements Insertable<TrackArtistsTableData> {
  final String trackId;
  final String artistId;
  final String role;
  final int position;
  const TrackArtistsTableData({
    required this.trackId,
    required this.artistId,
    required this.role,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['artist_id'] = Variable<String>(artistId);
    map['role'] = Variable<String>(role);
    map['position'] = Variable<int>(position);
    return map;
  }

  TrackArtistsTableCompanion toCompanion(bool nullToAbsent) {
    return TrackArtistsTableCompanion(
      trackId: Value(trackId),
      artistId: Value(artistId),
      role: Value(role),
      position: Value(position),
    );
  }

  factory TrackArtistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackArtistsTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      artistId: serializer.fromJson<String>(json['artistId']),
      role: serializer.fromJson<String>(json['role']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'artistId': serializer.toJson<String>(artistId),
      'role': serializer.toJson<String>(role),
      'position': serializer.toJson<int>(position),
    };
  }

  TrackArtistsTableData copyWith({
    String? trackId,
    String? artistId,
    String? role,
    int? position,
  }) => TrackArtistsTableData(
    trackId: trackId ?? this.trackId,
    artistId: artistId ?? this.artistId,
    role: role ?? this.role,
    position: position ?? this.position,
  );
  TrackArtistsTableData copyWithCompanion(TrackArtistsTableCompanion data) {
    return TrackArtistsTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      role: data.role.present ? data.role.value : this.role,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackArtistsTableData(')
          ..write('trackId: $trackId, ')
          ..write('artistId: $artistId, ')
          ..write('role: $role, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, artistId, role, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackArtistsTableData &&
          other.trackId == this.trackId &&
          other.artistId == this.artistId &&
          other.role == this.role &&
          other.position == this.position);
}

class TrackArtistsTableCompanion
    extends UpdateCompanion<TrackArtistsTableData> {
  final Value<String> trackId;
  final Value<String> artistId;
  final Value<String> role;
  final Value<int> position;
  final Value<int> rowid;
  const TrackArtistsTableCompanion({
    this.trackId = const Value.absent(),
    this.artistId = const Value.absent(),
    this.role = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackArtistsTableCompanion.insert({
    required String trackId,
    required String artistId,
    this.role = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       artistId = Value(artistId);
  static Insertable<TrackArtistsTableData> custom({
    Expression<String>? trackId,
    Expression<String>? artistId,
    Expression<String>? role,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (artistId != null) 'artist_id': artistId,
      if (role != null) 'role': role,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackArtistsTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? artistId,
    Value<String>? role,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TrackArtistsTableCompanion(
      trackId: trackId ?? this.trackId,
      artistId: artistId ?? this.artistId,
      role: role ?? this.role,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackArtistsTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('artistId: $artistId, ')
          ..write('role: $role, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTableTable extends AlbumsTable
    with TableInfo<$AlbumsTableTable, AlbumsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupingKeyMeta = const VerificationMeta(
    'groupingKey',
  );
  @override
  late final GeneratedColumn<String> groupingKey = GeneratedColumn<String>(
    'grouping_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    albumArtist,
    year,
    groupingKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('grouping_key')) {
      context.handle(
        _groupingKeyMeta,
        groupingKey.isAcceptableOrUnknown(
          data['grouping_key']!,
          _groupingKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_groupingKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      groupingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grouping_key'],
      )!,
    );
  }

  @override
  $AlbumsTableTable createAlias(String alias) {
    return $AlbumsTableTable(attachedDatabase, alias);
  }
}

class AlbumsTableData extends DataClass implements Insertable<AlbumsTableData> {
  final String id;
  final String title;
  final String? albumArtist;
  final int? year;
  final String groupingKey;
  const AlbumsTableData({
    required this.id,
    required this.title,
    this.albumArtist,
    this.year,
    required this.groupingKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || albumArtist != null) {
      map['album_artist'] = Variable<String>(albumArtist);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['grouping_key'] = Variable<String>(groupingKey);
    return map;
  }

  AlbumsTableCompanion toCompanion(bool nullToAbsent) {
    return AlbumsTableCompanion(
      id: Value(id),
      title: Value(title),
      albumArtist: albumArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtist),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      groupingKey: Value(groupingKey),
    );
  }

  factory AlbumsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      albumArtist: serializer.fromJson<String?>(json['albumArtist']),
      year: serializer.fromJson<int?>(json['year']),
      groupingKey: serializer.fromJson<String>(json['groupingKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'albumArtist': serializer.toJson<String?>(albumArtist),
      'year': serializer.toJson<int?>(year),
      'groupingKey': serializer.toJson<String>(groupingKey),
    };
  }

  AlbumsTableData copyWith({
    String? id,
    String? title,
    Value<String?> albumArtist = const Value.absent(),
    Value<int?> year = const Value.absent(),
    String? groupingKey,
  }) => AlbumsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    albumArtist: albumArtist.present ? albumArtist.value : this.albumArtist,
    year: year.present ? year.value : this.year,
    groupingKey: groupingKey ?? this.groupingKey,
  );
  AlbumsTableData copyWithCompanion(AlbumsTableCompanion data) {
    return AlbumsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      year: data.year.present ? data.year.value : this.year,
      groupingKey: data.groupingKey.present
          ? data.groupingKey.value
          : this.groupingKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('year: $year, ')
          ..write('groupingKey: $groupingKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, albumArtist, year, groupingKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.albumArtist == this.albumArtist &&
          other.year == this.year &&
          other.groupingKey == this.groupingKey);
}

class AlbumsTableCompanion extends UpdateCompanion<AlbumsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> albumArtist;
  final Value<int?> year;
  final Value<String> groupingKey;
  final Value<int> rowid;
  const AlbumsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.year = const Value.absent(),
    this.groupingKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsTableCompanion.insert({
    required String id,
    required String title,
    this.albumArtist = const Value.absent(),
    this.year = const Value.absent(),
    required String groupingKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       groupingKey = Value(groupingKey);
  static Insertable<AlbumsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? albumArtist,
    Expression<int>? year,
    Expression<String>? groupingKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (year != null) 'year': year,
      if (groupingKey != null) 'grouping_key': groupingKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? albumArtist,
    Value<int?>? year,
    Value<String>? groupingKey,
    Value<int>? rowid,
  }) {
    return AlbumsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      albumArtist: albumArtist ?? this.albumArtist,
      year: year ?? this.year,
      groupingKey: groupingKey ?? this.groupingKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (groupingKey.present) {
      map['grouping_key'] = Variable<String>(groupingKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('year: $year, ')
          ..write('groupingKey: $groupingKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackLocationsTableTable extends TrackLocationsTable
    with TableInfo<$TrackLocationsTableTable, TrackLocationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackLocationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _locatorKeyMeta = const VerificationMeta(
    'locatorKey',
  );
  @override
  late final GeneratedColumn<String> locatorKey = GeneratedColumn<String>(
    'locator_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<int> modifiedAt = GeneratedColumn<int>(
    'modified_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerVersionMeta = const VerificationMeta(
    'providerVersion',
  );
  @override
  late final GeneratedColumn<String> providerVersion = GeneratedColumn<String>(
    'provider_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _availabilityMeta = const VerificationMeta(
    'availability',
  );
  @override
  late final GeneratedColumn<String> availability = GeneratedColumn<String>(
    'availability',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('available'),
  );
  static const VerificationMeta _lastSeenGenerationMeta =
      const VerificationMeta('lastSeenGeneration');
  @override
  late final GeneratedColumn<int> lastSeenGeneration = GeneratedColumn<int>(
    'last_seen_generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    sourceId,
    locatorKey,
    size,
    modifiedAt,
    providerVersion,
    fingerprint,
    availability,
    lastSeenGeneration,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackLocationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('locator_key')) {
      context.handle(
        _locatorKeyMeta,
        locatorKey.isAcceptableOrUnknown(data['locator_key']!, _locatorKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_locatorKeyMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('provider_version')) {
      context.handle(
        _providerVersionMeta,
        providerVersion.isAcceptableOrUnknown(
          data['provider_version']!,
          _providerVersionMeta,
        ),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    }
    if (data.containsKey('availability')) {
      context.handle(
        _availabilityMeta,
        availability.isAcceptableOrUnknown(
          data['availability']!,
          _availabilityMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_generation')) {
      context.handle(
        _lastSeenGenerationMeta,
        lastSeenGeneration.isAcceptableOrUnknown(
          data['last_seen_generation']!,
          _lastSeenGenerationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenGenerationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceId, locatorKey},
  ];
  @override
  TrackLocationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackLocationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      locatorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator_key'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modified_at'],
      ),
      providerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_version'],
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      ),
      availability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}availability'],
      )!,
      lastSeenGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_generation'],
      )!,
    );
  }

  @override
  $TrackLocationsTableTable createAlias(String alias) {
    return $TrackLocationsTableTable(attachedDatabase, alias);
  }
}

class TrackLocationsTableData extends DataClass
    implements Insertable<TrackLocationsTableData> {
  final String id;
  final String trackId;
  final String sourceId;
  final String locatorKey;
  final int size;
  final int? modifiedAt;
  final String? providerVersion;
  final String? fingerprint;
  final String availability;
  final int lastSeenGeneration;
  const TrackLocationsTableData({
    required this.id,
    required this.trackId,
    required this.sourceId,
    required this.locatorKey,
    required this.size,
    this.modifiedAt,
    this.providerVersion,
    this.fingerprint,
    required this.availability,
    required this.lastSeenGeneration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['source_id'] = Variable<String>(sourceId);
    map['locator_key'] = Variable<String>(locatorKey);
    map['size'] = Variable<int>(size);
    if (!nullToAbsent || modifiedAt != null) {
      map['modified_at'] = Variable<int>(modifiedAt);
    }
    if (!nullToAbsent || providerVersion != null) {
      map['provider_version'] = Variable<String>(providerVersion);
    }
    if (!nullToAbsent || fingerprint != null) {
      map['fingerprint'] = Variable<String>(fingerprint);
    }
    map['availability'] = Variable<String>(availability);
    map['last_seen_generation'] = Variable<int>(lastSeenGeneration);
    return map;
  }

  TrackLocationsTableCompanion toCompanion(bool nullToAbsent) {
    return TrackLocationsTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      sourceId: Value(sourceId),
      locatorKey: Value(locatorKey),
      size: Value(size),
      modifiedAt: modifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedAt),
      providerVersion: providerVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(providerVersion),
      fingerprint: fingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(fingerprint),
      availability: Value(availability),
      lastSeenGeneration: Value(lastSeenGeneration),
    );
  }

  factory TrackLocationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackLocationsTableData(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      locatorKey: serializer.fromJson<String>(json['locatorKey']),
      size: serializer.fromJson<int>(json['size']),
      modifiedAt: serializer.fromJson<int?>(json['modifiedAt']),
      providerVersion: serializer.fromJson<String?>(json['providerVersion']),
      fingerprint: serializer.fromJson<String?>(json['fingerprint']),
      availability: serializer.fromJson<String>(json['availability']),
      lastSeenGeneration: serializer.fromJson<int>(json['lastSeenGeneration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'sourceId': serializer.toJson<String>(sourceId),
      'locatorKey': serializer.toJson<String>(locatorKey),
      'size': serializer.toJson<int>(size),
      'modifiedAt': serializer.toJson<int?>(modifiedAt),
      'providerVersion': serializer.toJson<String?>(providerVersion),
      'fingerprint': serializer.toJson<String?>(fingerprint),
      'availability': serializer.toJson<String>(availability),
      'lastSeenGeneration': serializer.toJson<int>(lastSeenGeneration),
    };
  }

  TrackLocationsTableData copyWith({
    String? id,
    String? trackId,
    String? sourceId,
    String? locatorKey,
    int? size,
    Value<int?> modifiedAt = const Value.absent(),
    Value<String?> providerVersion = const Value.absent(),
    Value<String?> fingerprint = const Value.absent(),
    String? availability,
    int? lastSeenGeneration,
  }) => TrackLocationsTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    sourceId: sourceId ?? this.sourceId,
    locatorKey: locatorKey ?? this.locatorKey,
    size: size ?? this.size,
    modifiedAt: modifiedAt.present ? modifiedAt.value : this.modifiedAt,
    providerVersion: providerVersion.present
        ? providerVersion.value
        : this.providerVersion,
    fingerprint: fingerprint.present ? fingerprint.value : this.fingerprint,
    availability: availability ?? this.availability,
    lastSeenGeneration: lastSeenGeneration ?? this.lastSeenGeneration,
  );
  TrackLocationsTableData copyWithCompanion(TrackLocationsTableCompanion data) {
    return TrackLocationsTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      locatorKey: data.locatorKey.present
          ? data.locatorKey.value
          : this.locatorKey,
      size: data.size.present ? data.size.value : this.size,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      providerVersion: data.providerVersion.present
          ? data.providerVersion.value
          : this.providerVersion,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      availability: data.availability.present
          ? data.availability.value
          : this.availability,
      lastSeenGeneration: data.lastSeenGeneration.present
          ? data.lastSeenGeneration.value
          : this.lastSeenGeneration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackLocationsTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('sourceId: $sourceId, ')
          ..write('locatorKey: $locatorKey, ')
          ..write('size: $size, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('providerVersion: $providerVersion, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('availability: $availability, ')
          ..write('lastSeenGeneration: $lastSeenGeneration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    sourceId,
    locatorKey,
    size,
    modifiedAt,
    providerVersion,
    fingerprint,
    availability,
    lastSeenGeneration,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackLocationsTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.sourceId == this.sourceId &&
          other.locatorKey == this.locatorKey &&
          other.size == this.size &&
          other.modifiedAt == this.modifiedAt &&
          other.providerVersion == this.providerVersion &&
          other.fingerprint == this.fingerprint &&
          other.availability == this.availability &&
          other.lastSeenGeneration == this.lastSeenGeneration);
}

class TrackLocationsTableCompanion
    extends UpdateCompanion<TrackLocationsTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> sourceId;
  final Value<String> locatorKey;
  final Value<int> size;
  final Value<int?> modifiedAt;
  final Value<String?> providerVersion;
  final Value<String?> fingerprint;
  final Value<String> availability;
  final Value<int> lastSeenGeneration;
  final Value<int> rowid;
  const TrackLocationsTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.locatorKey = const Value.absent(),
    this.size = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.providerVersion = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.availability = const Value.absent(),
    this.lastSeenGeneration = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackLocationsTableCompanion.insert({
    required String id,
    required String trackId,
    required String sourceId,
    required String locatorKey,
    required int size,
    this.modifiedAt = const Value.absent(),
    this.providerVersion = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.availability = const Value.absent(),
    required int lastSeenGeneration,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       sourceId = Value(sourceId),
       locatorKey = Value(locatorKey),
       size = Value(size),
       lastSeenGeneration = Value(lastSeenGeneration);
  static Insertable<TrackLocationsTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? sourceId,
    Expression<String>? locatorKey,
    Expression<int>? size,
    Expression<int>? modifiedAt,
    Expression<String>? providerVersion,
    Expression<String>? fingerprint,
    Expression<String>? availability,
    Expression<int>? lastSeenGeneration,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (sourceId != null) 'source_id': sourceId,
      if (locatorKey != null) 'locator_key': locatorKey,
      if (size != null) 'size': size,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (providerVersion != null) 'provider_version': providerVersion,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (availability != null) 'availability': availability,
      if (lastSeenGeneration != null)
        'last_seen_generation': lastSeenGeneration,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackLocationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? sourceId,
    Value<String>? locatorKey,
    Value<int>? size,
    Value<int?>? modifiedAt,
    Value<String?>? providerVersion,
    Value<String?>? fingerprint,
    Value<String>? availability,
    Value<int>? lastSeenGeneration,
    Value<int>? rowid,
  }) {
    return TrackLocationsTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      sourceId: sourceId ?? this.sourceId,
      locatorKey: locatorKey ?? this.locatorKey,
      size: size ?? this.size,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      providerVersion: providerVersion ?? this.providerVersion,
      fingerprint: fingerprint ?? this.fingerprint,
      availability: availability ?? this.availability,
      lastSeenGeneration: lastSeenGeneration ?? this.lastSeenGeneration,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (locatorKey.present) {
      map['locator_key'] = Variable<String>(locatorKey.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<int>(modifiedAt.value);
    }
    if (providerVersion.present) {
      map['provider_version'] = Variable<String>(providerVersion.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (availability.present) {
      map['availability'] = Variable<String>(availability.value);
    }
    if (lastSeenGeneration.present) {
      map['last_seen_generation'] = Variable<int>(lastSeenGeneration.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackLocationsTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('sourceId: $sourceId, ')
          ..write('locatorKey: $locatorKey, ')
          ..write('size: $size, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('providerVersion: $providerVersion, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('availability: $availability, ')
          ..write('lastSeenGeneration: $lastSeenGeneration, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTableTable extends PlaylistsTable
    with TableInfo<$PlaylistsTableTable, PlaylistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaylistsTableTable createAlias(String alias) {
    return $PlaylistsTableTable(attachedDatabase, alias);
  }
}

class PlaylistsTableData extends DataClass
    implements Insertable<PlaylistsTableData> {
  final String id;
  final String name;
  final int createdAt;
  final int updatedAt;
  const PlaylistsTableData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PlaylistsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaylistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  PlaylistsTableData copyWith({
    String? id,
    String? name,
    int? createdAt,
    int? updatedAt,
  }) => PlaylistsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaylistsTableData copyWithCompanion(PlaylistsTableCompanion data) {
    return PlaylistsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsTableCompanion extends UpdateCompanion<PlaylistsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const PlaylistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsTableCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlaylistsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlaylistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistEntriesTableTable extends PlaylistEntriesTable
    with TableInfo<$PlaylistEntriesTableTable, PlaylistEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, playlistId, trackId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistEntriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistEntriesTableTable createAlias(String alias) {
    return $PlaylistEntriesTableTable(attachedDatabase, alias);
  }
}

class PlaylistEntriesTableData extends DataClass
    implements Insertable<PlaylistEntriesTableData> {
  final String id;
  final String playlistId;
  final String trackId;
  final int position;
  const PlaylistEntriesTableData({
    required this.id,
    required this.playlistId,
    required this.trackId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistEntriesTableCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      position: Value(position),
    );
  }

  factory PlaylistEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistEntriesTableData(
      id: serializer.fromJson<String>(json['id']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistEntriesTableData copyWith({
    String? id,
    String? playlistId,
    String? trackId,
    int? position,
  }) => PlaylistEntriesTableData(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
  );
  PlaylistEntriesTableData copyWithCompanion(
    PlaylistEntriesTableCompanion data,
  ) {
    return PlaylistEntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntriesTableData(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistId, trackId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistEntriesTableData &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.position == this.position);
}

class PlaylistEntriesTableCompanion
    extends UpdateCompanion<PlaylistEntriesTableData> {
  final Value<String> id;
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<int> rowid;
  const PlaylistEntriesTableCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistEntriesTableCompanion.insert({
    required String id,
    required String playlistId,
    required String trackId,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       playlistId = Value(playlistId),
       trackId = Value(trackId),
       position = Value(position);
  static Insertable<PlaylistEntriesTableData> custom({
    Expression<String>? id,
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistEntriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? playlistId,
    Value<String>? trackId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return PlaylistEntriesTableCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackUserStateTableTable extends TrackUserStateTable
    with TableInfo<$TrackUserStateTableTable, TrackUserStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackUserStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<int> lastPlayedAt = GeneratedColumn<int>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    favorite,
    playCount,
    lastPlayedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_user_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackUserStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  TrackUserStateTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackUserStateTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_played_at'],
      ),
    );
  }

  @override
  $TrackUserStateTableTable createAlias(String alias) {
    return $TrackUserStateTableTable(attachedDatabase, alias);
  }
}

class TrackUserStateTableData extends DataClass
    implements Insertable<TrackUserStateTableData> {
  final String trackId;
  final bool favorite;
  final int playCount;
  final int? lastPlayedAt;
  const TrackUserStateTableData({
    required this.trackId,
    required this.favorite,
    required this.playCount,
    this.lastPlayedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['favorite'] = Variable<bool>(favorite);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<int>(lastPlayedAt);
    }
    return map;
  }

  TrackUserStateTableCompanion toCompanion(bool nullToAbsent) {
    return TrackUserStateTableCompanion(
      trackId: Value(trackId),
      favorite: Value(favorite),
      playCount: Value(playCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
    );
  }

  factory TrackUserStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackUserStateTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayedAt: serializer.fromJson<int?>(json['lastPlayedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'favorite': serializer.toJson<bool>(favorite),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayedAt': serializer.toJson<int?>(lastPlayedAt),
    };
  }

  TrackUserStateTableData copyWith({
    String? trackId,
    bool? favorite,
    int? playCount,
    Value<int?> lastPlayedAt = const Value.absent(),
  }) => TrackUserStateTableData(
    trackId: trackId ?? this.trackId,
    favorite: favorite ?? this.favorite,
    playCount: playCount ?? this.playCount,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
  );
  TrackUserStateTableData copyWithCompanion(TrackUserStateTableCompanion data) {
    return TrackUserStateTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackUserStateTableData(')
          ..write('trackId: $trackId, ')
          ..write('favorite: $favorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, favorite, playCount, lastPlayedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackUserStateTableData &&
          other.trackId == this.trackId &&
          other.favorite == this.favorite &&
          other.playCount == this.playCount &&
          other.lastPlayedAt == this.lastPlayedAt);
}

class TrackUserStateTableCompanion
    extends UpdateCompanion<TrackUserStateTableData> {
  final Value<String> trackId;
  final Value<bool> favorite;
  final Value<int> playCount;
  final Value<int?> lastPlayedAt;
  final Value<int> rowid;
  const TrackUserStateTableCompanion({
    this.trackId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackUserStateTableCompanion.insert({
    required String trackId,
    this.favorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId);
  static Insertable<TrackUserStateTableData> custom({
    Expression<String>? trackId,
    Expression<bool>? favorite,
    Expression<int>? playCount,
    Expression<int>? lastPlayedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (favorite != null) 'favorite': favorite,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackUserStateTableCompanion copyWith({
    Value<String>? trackId,
    Value<bool>? favorite,
    Value<int>? playCount,
    Value<int?>? lastPlayedAt,
    Value<int>? rowid,
  }) {
    return TrackUserStateTableCompanion(
      trackId: trackId ?? this.trackId,
      favorite: favorite ?? this.favorite,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<int>(lastPlayedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackUserStateTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('favorite: $favorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueEntriesTableTable extends QueueEntriesTable
    with TableInfo<$QueueEntriesTableTable, QueueEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shufflePositionMeta = const VerificationMeta(
    'shufflePosition',
  );
  @override
  late final GeneratedColumn<int> shufflePosition = GeneratedColumn<int>(
    'shuffle_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entryId,
    trackId,
    position,
    shufflePosition,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('shuffle_position')) {
      context.handle(
        _shufflePositionMeta,
        shufflePosition.isAcceptableOrUnknown(
          data['shuffle_position']!,
          _shufflePositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shufflePositionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  QueueEntriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueEntriesTableData(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      shufflePosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shuffle_position'],
      )!,
    );
  }

  @override
  $QueueEntriesTableTable createAlias(String alias) {
    return $QueueEntriesTableTable(attachedDatabase, alias);
  }
}

class QueueEntriesTableData extends DataClass
    implements Insertable<QueueEntriesTableData> {
  final String entryId;
  final String trackId;
  final int position;
  final int shufflePosition;
  const QueueEntriesTableData({
    required this.entryId,
    required this.trackId,
    required this.position,
    required this.shufflePosition,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    map['shuffle_position'] = Variable<int>(shufflePosition);
    return map;
  }

  QueueEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return QueueEntriesTableCompanion(
      entryId: Value(entryId),
      trackId: Value(trackId),
      position: Value(position),
      shufflePosition: Value(shufflePosition),
    );
  }

  factory QueueEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueEntriesTableData(
      entryId: serializer.fromJson<String>(json['entryId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
      shufflePosition: serializer.fromJson<int>(json['shufflePosition']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
      'shufflePosition': serializer.toJson<int>(shufflePosition),
    };
  }

  QueueEntriesTableData copyWith({
    String? entryId,
    String? trackId,
    int? position,
    int? shufflePosition,
  }) => QueueEntriesTableData(
    entryId: entryId ?? this.entryId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
    shufflePosition: shufflePosition ?? this.shufflePosition,
  );
  QueueEntriesTableData copyWithCompanion(QueueEntriesTableCompanion data) {
    return QueueEntriesTableData(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
      shufflePosition: data.shufflePosition.present
          ? data.shufflePosition.value
          : this.shufflePosition,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueEntriesTableData(')
          ..write('entryId: $entryId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('shufflePosition: $shufflePosition')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, trackId, position, shufflePosition);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueEntriesTableData &&
          other.entryId == this.entryId &&
          other.trackId == this.trackId &&
          other.position == this.position &&
          other.shufflePosition == this.shufflePosition);
}

class QueueEntriesTableCompanion
    extends UpdateCompanion<QueueEntriesTableData> {
  final Value<String> entryId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<int> shufflePosition;
  final Value<int> rowid;
  const QueueEntriesTableCompanion({
    this.entryId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.shufflePosition = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueEntriesTableCompanion.insert({
    required String entryId,
    required String trackId,
    required int position,
    required int shufflePosition,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       trackId = Value(trackId),
       position = Value(position),
       shufflePosition = Value(shufflePosition);
  static Insertable<QueueEntriesTableData> custom({
    Expression<String>? entryId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<int>? shufflePosition,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (shufflePosition != null) 'shuffle_position': shufflePosition,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueEntriesTableCompanion copyWith({
    Value<String>? entryId,
    Value<String>? trackId,
    Value<int>? position,
    Value<int>? shufflePosition,
    Value<int>? rowid,
  }) {
    return QueueEntriesTableCompanion(
      entryId: entryId ?? this.entryId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      shufflePosition: shufflePosition ?? this.shufflePosition,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (shufflePosition.present) {
      map['shuffle_position'] = Variable<int>(shufflePosition.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueEntriesTableCompanion(')
          ..write('entryId: $entryId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('shufflePosition: $shufflePosition, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackSessionTableTable extends PlaybackSessionTable
    with TableInfo<$PlaybackSessionTableTable, PlaybackSessionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackSessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queueRevisionMeta = const VerificationMeta(
    'queueRevision',
  );
  @override
  late final GeneratedColumn<int> queueRevision = GeneratedColumn<int>(
    'queue_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentEntryIdMeta = const VerificationMeta(
    'currentEntryId',
  );
  @override
  late final GeneratedColumn<String> currentEntryId = GeneratedColumn<String>(
    'current_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  static const VerificationMeta _shuffleSeedMeta = const VerificationMeta(
    'shuffleSeed',
  );
  @override
  late final GeneratedColumn<int> shuffleSeed = GeneratedColumn<int>(
    'shuffle_seed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isShuffleMeta = const VerificationMeta(
    'isShuffle',
  );
  @override
  late final GeneratedColumn<bool> isShuffle = GeneratedColumn<bool>(
    'is_shuffle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shuffle" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    queueRevision,
    currentEntryId,
    positionMs,
    repeatMode,
    shuffleSeed,
    isShuffle,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_session';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackSessionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('queue_revision')) {
      context.handle(
        _queueRevisionMeta,
        queueRevision.isAcceptableOrUnknown(
          data['queue_revision']!,
          _queueRevisionMeta,
        ),
      );
    }
    if (data.containsKey('current_entry_id')) {
      context.handle(
        _currentEntryIdMeta,
        currentEntryId.isAcceptableOrUnknown(
          data['current_entry_id']!,
          _currentEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('shuffle_seed')) {
      context.handle(
        _shuffleSeedMeta,
        shuffleSeed.isAcceptableOrUnknown(
          data['shuffle_seed']!,
          _shuffleSeedMeta,
        ),
      );
    }
    if (data.containsKey('is_shuffle')) {
      context.handle(
        _isShuffleMeta,
        isShuffle.isAcceptableOrUnknown(data['is_shuffle']!, _isShuffleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackSessionTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackSessionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      queueRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_revision'],
      )!,
      currentEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_entry_id'],
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      shuffleSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shuffle_seed'],
      ),
      isShuffle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shuffle'],
      )!,
    );
  }

  @override
  $PlaybackSessionTableTable createAlias(String alias) {
    return $PlaybackSessionTableTable(attachedDatabase, alias);
  }
}

class PlaybackSessionTableData extends DataClass
    implements Insertable<PlaybackSessionTableData> {
  final String id;
  final int queueRevision;
  final String? currentEntryId;
  final int positionMs;
  final String repeatMode;
  final int? shuffleSeed;
  final bool isShuffle;
  const PlaybackSessionTableData({
    required this.id,
    required this.queueRevision,
    this.currentEntryId,
    required this.positionMs,
    required this.repeatMode,
    this.shuffleSeed,
    required this.isShuffle,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['queue_revision'] = Variable<int>(queueRevision);
    if (!nullToAbsent || currentEntryId != null) {
      map['current_entry_id'] = Variable<String>(currentEntryId);
    }
    map['position_ms'] = Variable<int>(positionMs);
    map['repeat_mode'] = Variable<String>(repeatMode);
    if (!nullToAbsent || shuffleSeed != null) {
      map['shuffle_seed'] = Variable<int>(shuffleSeed);
    }
    map['is_shuffle'] = Variable<bool>(isShuffle);
    return map;
  }

  PlaybackSessionTableCompanion toCompanion(bool nullToAbsent) {
    return PlaybackSessionTableCompanion(
      id: Value(id),
      queueRevision: Value(queueRevision),
      currentEntryId: currentEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentEntryId),
      positionMs: Value(positionMs),
      repeatMode: Value(repeatMode),
      shuffleSeed: shuffleSeed == null && nullToAbsent
          ? const Value.absent()
          : Value(shuffleSeed),
      isShuffle: Value(isShuffle),
    );
  }

  factory PlaybackSessionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackSessionTableData(
      id: serializer.fromJson<String>(json['id']),
      queueRevision: serializer.fromJson<int>(json['queueRevision']),
      currentEntryId: serializer.fromJson<String?>(json['currentEntryId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      shuffleSeed: serializer.fromJson<int?>(json['shuffleSeed']),
      isShuffle: serializer.fromJson<bool>(json['isShuffle']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'queueRevision': serializer.toJson<int>(queueRevision),
      'currentEntryId': serializer.toJson<String?>(currentEntryId),
      'positionMs': serializer.toJson<int>(positionMs),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'shuffleSeed': serializer.toJson<int?>(shuffleSeed),
      'isShuffle': serializer.toJson<bool>(isShuffle),
    };
  }

  PlaybackSessionTableData copyWith({
    String? id,
    int? queueRevision,
    Value<String?> currentEntryId = const Value.absent(),
    int? positionMs,
    String? repeatMode,
    Value<int?> shuffleSeed = const Value.absent(),
    bool? isShuffle,
  }) => PlaybackSessionTableData(
    id: id ?? this.id,
    queueRevision: queueRevision ?? this.queueRevision,
    currentEntryId: currentEntryId.present
        ? currentEntryId.value
        : this.currentEntryId,
    positionMs: positionMs ?? this.positionMs,
    repeatMode: repeatMode ?? this.repeatMode,
    shuffleSeed: shuffleSeed.present ? shuffleSeed.value : this.shuffleSeed,
    isShuffle: isShuffle ?? this.isShuffle,
  );
  PlaybackSessionTableData copyWithCompanion(
    PlaybackSessionTableCompanion data,
  ) {
    return PlaybackSessionTableData(
      id: data.id.present ? data.id.value : this.id,
      queueRevision: data.queueRevision.present
          ? data.queueRevision.value
          : this.queueRevision,
      currentEntryId: data.currentEntryId.present
          ? data.currentEntryId.value
          : this.currentEntryId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      shuffleSeed: data.shuffleSeed.present
          ? data.shuffleSeed.value
          : this.shuffleSeed,
      isShuffle: data.isShuffle.present ? data.isShuffle.value : this.isShuffle,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionTableData(')
          ..write('id: $id, ')
          ..write('queueRevision: $queueRevision, ')
          ..write('currentEntryId: $currentEntryId, ')
          ..write('positionMs: $positionMs, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('shuffleSeed: $shuffleSeed, ')
          ..write('isShuffle: $isShuffle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    queueRevision,
    currentEntryId,
    positionMs,
    repeatMode,
    shuffleSeed,
    isShuffle,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackSessionTableData &&
          other.id == this.id &&
          other.queueRevision == this.queueRevision &&
          other.currentEntryId == this.currentEntryId &&
          other.positionMs == this.positionMs &&
          other.repeatMode == this.repeatMode &&
          other.shuffleSeed == this.shuffleSeed &&
          other.isShuffle == this.isShuffle);
}

class PlaybackSessionTableCompanion
    extends UpdateCompanion<PlaybackSessionTableData> {
  final Value<String> id;
  final Value<int> queueRevision;
  final Value<String?> currentEntryId;
  final Value<int> positionMs;
  final Value<String> repeatMode;
  final Value<int?> shuffleSeed;
  final Value<bool> isShuffle;
  final Value<int> rowid;
  const PlaybackSessionTableCompanion({
    this.id = const Value.absent(),
    this.queueRevision = const Value.absent(),
    this.currentEntryId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.shuffleSeed = const Value.absent(),
    this.isShuffle = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackSessionTableCompanion.insert({
    required String id,
    this.queueRevision = const Value.absent(),
    this.currentEntryId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.shuffleSeed = const Value.absent(),
    this.isShuffle = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<PlaybackSessionTableData> custom({
    Expression<String>? id,
    Expression<int>? queueRevision,
    Expression<String>? currentEntryId,
    Expression<int>? positionMs,
    Expression<String>? repeatMode,
    Expression<int>? shuffleSeed,
    Expression<bool>? isShuffle,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queueRevision != null) 'queue_revision': queueRevision,
      if (currentEntryId != null) 'current_entry_id': currentEntryId,
      if (positionMs != null) 'position_ms': positionMs,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (shuffleSeed != null) 'shuffle_seed': shuffleSeed,
      if (isShuffle != null) 'is_shuffle': isShuffle,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackSessionTableCompanion copyWith({
    Value<String>? id,
    Value<int>? queueRevision,
    Value<String?>? currentEntryId,
    Value<int>? positionMs,
    Value<String>? repeatMode,
    Value<int?>? shuffleSeed,
    Value<bool>? isShuffle,
    Value<int>? rowid,
  }) {
    return PlaybackSessionTableCompanion(
      id: id ?? this.id,
      queueRevision: queueRevision ?? this.queueRevision,
      currentEntryId: currentEntryId ?? this.currentEntryId,
      positionMs: positionMs ?? this.positionMs,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleSeed: shuffleSeed ?? this.shuffleSeed,
      isShuffle: isShuffle ?? this.isShuffle,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (queueRevision.present) {
      map['queue_revision'] = Variable<int>(queueRevision.value);
    }
    if (currentEntryId.present) {
      map['current_entry_id'] = Variable<String>(currentEntryId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (shuffleSeed.present) {
      map['shuffle_seed'] = Variable<int>(shuffleSeed.value);
    }
    if (isShuffle.present) {
      map['is_shuffle'] = Variable<bool>(isShuffle.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionTableCompanion(')
          ..write('id: $id, ')
          ..write('queueRevision: $queueRevision, ')
          ..write('currentEntryId: $currentEntryId, ')
          ..write('positionMs: $positionMs, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('shuffleSeed: $shuffleSeed, ')
          ..write('isShuffle: $isShuffle, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtworksTableTable extends ArtworksTable
    with TableInfo<$ArtworksTableTable, ArtworksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtworksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentHash,
    cacheKey,
    width,
    height,
    byteSize,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artworks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtworksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtworksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtworksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
    );
  }

  @override
  $ArtworksTableTable createAlias(String alias) {
    return $ArtworksTableTable(attachedDatabase, alias);
  }
}

class ArtworksTableData extends DataClass
    implements Insertable<ArtworksTableData> {
  final String id;
  final String contentHash;
  final String cacheKey;
  final int? width;
  final int? height;
  final int byteSize;
  const ArtworksTableData({
    required this.id,
    required this.contentHash,
    required this.cacheKey,
    this.width,
    this.height,
    required this.byteSize,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content_hash'] = Variable<String>(contentHash);
    map['cache_key'] = Variable<String>(cacheKey);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['byte_size'] = Variable<int>(byteSize);
    return map;
  }

  ArtworksTableCompanion toCompanion(bool nullToAbsent) {
    return ArtworksTableCompanion(
      id: Value(id),
      contentHash: Value(contentHash),
      cacheKey: Value(cacheKey),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      byteSize: Value(byteSize),
    );
  }

  factory ArtworksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtworksTableData(
      id: serializer.fromJson<String>(json['id']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contentHash': serializer.toJson<String>(contentHash),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'byteSize': serializer.toJson<int>(byteSize),
    };
  }

  ArtworksTableData copyWith({
    String? id,
    String? contentHash,
    String? cacheKey,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    int? byteSize,
  }) => ArtworksTableData(
    id: id ?? this.id,
    contentHash: contentHash ?? this.contentHash,
    cacheKey: cacheKey ?? this.cacheKey,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    byteSize: byteSize ?? this.byteSize,
  );
  ArtworksTableData copyWithCompanion(ArtworksTableCompanion data) {
    return ArtworksTableData(
      id: data.id.present ? data.id.value : this.id,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtworksTableData(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('byteSize: $byteSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contentHash, cacheKey, width, height, byteSize);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtworksTableData &&
          other.id == this.id &&
          other.contentHash == this.contentHash &&
          other.cacheKey == this.cacheKey &&
          other.width == this.width &&
          other.height == this.height &&
          other.byteSize == this.byteSize);
}

class ArtworksTableCompanion extends UpdateCompanion<ArtworksTableData> {
  final Value<String> id;
  final Value<String> contentHash;
  final Value<String> cacheKey;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int> byteSize;
  final Value<int> rowid;
  const ArtworksTableCompanion({
    this.id = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtworksTableCompanion.insert({
    required String id,
    required String contentHash,
    required String cacheKey,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int byteSize,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contentHash = Value(contentHash),
       cacheKey = Value(cacheKey),
       byteSize = Value(byteSize);
  static Insertable<ArtworksTableData> custom({
    Expression<String>? id,
    Expression<String>? contentHash,
    Expression<String>? cacheKey,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? byteSize,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentHash != null) 'content_hash': contentHash,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (byteSize != null) 'byte_size': byteSize,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtworksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? contentHash,
    Value<String>? cacheKey,
    Value<int?>? width,
    Value<int?>? height,
    Value<int>? byteSize,
    Value<int>? rowid,
  }) {
    return ArtworksTableCompanion(
      id: id ?? this.id,
      contentHash: contentHash ?? this.contentHash,
      cacheKey: cacheKey ?? this.cacheKey,
      width: width ?? this.width,
      height: height ?? this.height,
      byteSize: byteSize ?? this.byteSize,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtworksTableCompanion(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('byteSize: $byteSize, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, schemaVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String key;
  final String valueJson;
  final int schemaVersion;
  const SettingsTableData({
    required this.key,
    required this.valueJson,
    required this.schemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory SettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  SettingsTableData copyWith({
    String? key,
    String? valueJson,
    int? schemaVersion,
  }) => SettingsTableData(
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
    schemaVersion: schemaVersion ?? this.schemaVersion,
  );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, schemaVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.schemaVersion == this.schemaVersion);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int> schemaVersion;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    required String valueJson,
    this.schemaVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson);
  static Insertable<SettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? schemaVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<int>? schemaVersion,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanRunsTableTable extends ScanRunsTable
    with TableInfo<$ScanRunsTableTable, ScanRunsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanRunsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
    'generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countersJsonMeta = const VerificationMeta(
    'countersJson',
  );
  @override
  late final GeneratedColumn<String> countersJson = GeneratedColumn<String>(
    'counters_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    generation,
    status,
    cursor,
    countersJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanRunsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    } else if (isInserting) {
      context.missing(_generationMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('counters_json')) {
      context.handle(
        _countersJsonMeta,
        countersJson.isAcceptableOrUnknown(
          data['counters_json']!,
          _countersJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanRunsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanRunsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      ),
      countersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counters_json'],
      ),
    );
  }

  @override
  $ScanRunsTableTable createAlias(String alias) {
    return $ScanRunsTableTable(attachedDatabase, alias);
  }
}

class ScanRunsTableData extends DataClass
    implements Insertable<ScanRunsTableData> {
  final String id;
  final String sourceId;
  final int generation;
  final String status;
  final String? cursor;
  final String? countersJson;
  const ScanRunsTableData({
    required this.id,
    required this.sourceId,
    required this.generation,
    required this.status,
    this.cursor,
    this.countersJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['generation'] = Variable<int>(generation);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    if (!nullToAbsent || countersJson != null) {
      map['counters_json'] = Variable<String>(countersJson);
    }
    return map;
  }

  ScanRunsTableCompanion toCompanion(bool nullToAbsent) {
    return ScanRunsTableCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      generation: Value(generation),
      status: Value(status),
      cursor: cursor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursor),
      countersJson: countersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(countersJson),
    );
  }

  factory ScanRunsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanRunsTableData(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      generation: serializer.fromJson<int>(json['generation']),
      status: serializer.fromJson<String>(json['status']),
      cursor: serializer.fromJson<String?>(json['cursor']),
      countersJson: serializer.fromJson<String?>(json['countersJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'generation': serializer.toJson<int>(generation),
      'status': serializer.toJson<String>(status),
      'cursor': serializer.toJson<String?>(cursor),
      'countersJson': serializer.toJson<String?>(countersJson),
    };
  }

  ScanRunsTableData copyWith({
    String? id,
    String? sourceId,
    int? generation,
    String? status,
    Value<String?> cursor = const Value.absent(),
    Value<String?> countersJson = const Value.absent(),
  }) => ScanRunsTableData(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    generation: generation ?? this.generation,
    status: status ?? this.status,
    cursor: cursor.present ? cursor.value : this.cursor,
    countersJson: countersJson.present ? countersJson.value : this.countersJson,
  );
  ScanRunsTableData copyWithCompanion(ScanRunsTableCompanion data) {
    return ScanRunsTableData(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      status: data.status.present ? data.status.value : this.status,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      countersJson: data.countersJson.present
          ? data.countersJson.value
          : this.countersJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanRunsTableData(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('generation: $generation, ')
          ..write('status: $status, ')
          ..write('cursor: $cursor, ')
          ..write('countersJson: $countersJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceId, generation, status, cursor, countersJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanRunsTableData &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.generation == this.generation &&
          other.status == this.status &&
          other.cursor == this.cursor &&
          other.countersJson == this.countersJson);
}

class ScanRunsTableCompanion extends UpdateCompanion<ScanRunsTableData> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<int> generation;
  final Value<String> status;
  final Value<String?> cursor;
  final Value<String?> countersJson;
  final Value<int> rowid;
  const ScanRunsTableCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.generation = const Value.absent(),
    this.status = const Value.absent(),
    this.cursor = const Value.absent(),
    this.countersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanRunsTableCompanion.insert({
    required String id,
    required String sourceId,
    required int generation,
    required String status,
    this.cursor = const Value.absent(),
    this.countersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       generation = Value(generation),
       status = Value(status);
  static Insertable<ScanRunsTableData> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<int>? generation,
    Expression<String>? status,
    Expression<String>? cursor,
    Expression<String>? countersJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (generation != null) 'generation': generation,
      if (status != null) 'status': status,
      if (cursor != null) 'cursor': cursor,
      if (countersJson != null) 'counters_json': countersJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanRunsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<int>? generation,
    Value<String>? status,
    Value<String?>? cursor,
    Value<String?>? countersJson,
    Value<int>? rowid,
  }) {
    return ScanRunsTableCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      generation: generation ?? this.generation,
      status: status ?? this.status,
      cursor: cursor ?? this.cursor,
      countersJson: countersJson ?? this.countersJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (countersJson.present) {
      map['counters_json'] = Variable<String>(countersJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanRunsTableCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('generation: $generation, ')
          ..write('status: $status, ')
          ..write('cursor: $cursor, ')
          ..write('countersJson: $countersJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibrarySourcesTableTable librarySourcesTable =
      $LibrarySourcesTableTable(this);
  late final $TracksTableTable tracksTable = $TracksTableTable(this);
  late final $ArtistsTableTable artistsTable = $ArtistsTableTable(this);
  late final $TrackArtistsTableTable trackArtistsTable =
      $TrackArtistsTableTable(this);
  late final $AlbumsTableTable albumsTable = $AlbumsTableTable(this);
  late final $TrackLocationsTableTable trackLocationsTable =
      $TrackLocationsTableTable(this);
  late final $PlaylistsTableTable playlistsTable = $PlaylistsTableTable(this);
  late final $PlaylistEntriesTableTable playlistEntriesTable =
      $PlaylistEntriesTableTable(this);
  late final $TrackUserStateTableTable trackUserStateTable =
      $TrackUserStateTableTable(this);
  late final $QueueEntriesTableTable queueEntriesTable =
      $QueueEntriesTableTable(this);
  late final $PlaybackSessionTableTable playbackSessionTable =
      $PlaybackSessionTableTable(this);
  late final $ArtworksTableTable artworksTable = $ArtworksTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $ScanRunsTableTable scanRunsTable = $ScanRunsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    librarySourcesTable,
    tracksTable,
    artistsTable,
    trackArtistsTable,
    albumsTable,
    trackLocationsTable,
    playlistsTable,
    playlistEntriesTable,
    trackUserStateTable,
    queueEntriesTable,
    playbackSessionTable,
    artworksTable,
    settingsTable,
    scanRunsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_artists', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'artists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_artists', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_locations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'library_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_locations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_user_state', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('queue_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'library_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_runs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LibrarySourcesTableTableCreateCompanionBuilder =
    LibrarySourcesTableCompanion Function({
      required String id,
      required String kind,
      required String locator,
      Value<String> status,
      Value<int?> lastSuccessfulScan,
      Value<int> scanGeneration,
      Value<int> rowid,
    });
typedef $$LibrarySourcesTableTableUpdateCompanionBuilder =
    LibrarySourcesTableCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> locator,
      Value<String> status,
      Value<int?> lastSuccessfulScan,
      Value<int> scanGeneration,
      Value<int> rowid,
    });

final class $$LibrarySourcesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LibrarySourcesTableTable,
          LibrarySourcesTableData
        > {
  $$LibrarySourcesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $TrackLocationsTableTable,
    List<TrackLocationsTableData>
  >
  _trackLocationsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackLocationsTable,
        aliasName: 'library_sources__id__track_locations__source_id',
      );

  $$TrackLocationsTableTableProcessedTableManager get trackLocationsTableRefs {
    final manager = $$TrackLocationsTableTableTableManager(
      $_db,
      $_db.trackLocationsTable,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackLocationsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScanRunsTableTable, List<ScanRunsTableData>>
  _scanRunsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scanRunsTable,
    aliasName: 'library_sources__id__scan_runs__source_id',
  );

  $$ScanRunsTableTableProcessedTableManager get scanRunsTableRefs {
    final manager = $$ScanRunsTableTableTableManager(
      $_db,
      $_db.scanRunsTable,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanRunsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibrarySourcesTableTableFilterComposer
    extends Composer<_$AppDatabase, $LibrarySourcesTableTable> {
  $$LibrarySourcesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSuccessfulScan => $composableBuilder(
    column: $table.lastSuccessfulScan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scanGeneration => $composableBuilder(
    column: $table.scanGeneration,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackLocationsTableRefs(
    Expression<bool> Function($$TrackLocationsTableTableFilterComposer f) f,
  ) {
    final $$TrackLocationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackLocationsTable,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackLocationsTableTableFilterComposer(
            $db: $db,
            $table: $db.trackLocationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scanRunsTableRefs(
    Expression<bool> Function($$ScanRunsTableTableFilterComposer f) f,
  ) {
    final $$ScanRunsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanRunsTable,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanRunsTableTableFilterComposer(
            $db: $db,
            $table: $db.scanRunsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibrarySourcesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LibrarySourcesTableTable> {
  $$LibrarySourcesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSuccessfulScan => $composableBuilder(
    column: $table.lastSuccessfulScan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scanGeneration => $composableBuilder(
    column: $table.scanGeneration,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibrarySourcesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibrarySourcesTableTable> {
  $$LibrarySourcesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get locator =>
      $composableBuilder(column: $table.locator, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get lastSuccessfulScan => $composableBuilder(
    column: $table.lastSuccessfulScan,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scanGeneration => $composableBuilder(
    column: $table.scanGeneration,
    builder: (column) => column,
  );

  Expression<T> trackLocationsTableRefs<T extends Object>(
    Expression<T> Function($$TrackLocationsTableTableAnnotationComposer a) f,
  ) {
    final $$TrackLocationsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackLocationsTable,
          getReferencedColumn: (t) => t.sourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackLocationsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackLocationsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> scanRunsTableRefs<T extends Object>(
    Expression<T> Function($$ScanRunsTableTableAnnotationComposer a) f,
  ) {
    final $$ScanRunsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanRunsTable,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanRunsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.scanRunsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibrarySourcesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibrarySourcesTableTable,
          LibrarySourcesTableData,
          $$LibrarySourcesTableTableFilterComposer,
          $$LibrarySourcesTableTableOrderingComposer,
          $$LibrarySourcesTableTableAnnotationComposer,
          $$LibrarySourcesTableTableCreateCompanionBuilder,
          $$LibrarySourcesTableTableUpdateCompanionBuilder,
          (LibrarySourcesTableData, $$LibrarySourcesTableTableReferences),
          LibrarySourcesTableData,
          PrefetchHooks Function({
            bool trackLocationsTableRefs,
            bool scanRunsTableRefs,
          })
        > {
  $$LibrarySourcesTableTableTableManager(
    _$AppDatabase db,
    $LibrarySourcesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibrarySourcesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibrarySourcesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LibrarySourcesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> locator = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> lastSuccessfulScan = const Value.absent(),
                Value<int> scanGeneration = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibrarySourcesTableCompanion(
                id: id,
                kind: kind,
                locator: locator,
                status: status,
                lastSuccessfulScan: lastSuccessfulScan,
                scanGeneration: scanGeneration,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String locator,
                Value<String> status = const Value.absent(),
                Value<int?> lastSuccessfulScan = const Value.absent(),
                Value<int> scanGeneration = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibrarySourcesTableCompanion.insert(
                id: id,
                kind: kind,
                locator: locator,
                status: status,
                lastSuccessfulScan: lastSuccessfulScan,
                scanGeneration: scanGeneration,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LibrarySourcesTableTable,
                    LibrarySourcesTableData
                  >(table),
                  $$LibrarySourcesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({trackLocationsTableRefs = false, scanRunsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackLocationsTableRefs) db.trackLocationsTable,
                    if (scanRunsTableRefs) db.scanRunsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackLocationsTableRefs)
                        await $_getPrefetchedData<
                          LibrarySourcesTableData,
                          $LibrarySourcesTableTable,
                          TrackLocationsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$LibrarySourcesTableTableReferences
                              ._trackLocationsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LibrarySourcesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackLocationsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scanRunsTableRefs)
                        await $_getPrefetchedData<
                          LibrarySourcesTableData,
                          $LibrarySourcesTableTable,
                          ScanRunsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$LibrarySourcesTableTableReferences
                              ._scanRunsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LibrarySourcesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).scanRunsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LibrarySourcesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibrarySourcesTableTable,
      LibrarySourcesTableData,
      $$LibrarySourcesTableTableFilterComposer,
      $$LibrarySourcesTableTableOrderingComposer,
      $$LibrarySourcesTableTableAnnotationComposer,
      $$LibrarySourcesTableTableCreateCompanionBuilder,
      $$LibrarySourcesTableTableUpdateCompanionBuilder,
      (LibrarySourcesTableData, $$LibrarySourcesTableTableReferences),
      LibrarySourcesTableData,
      PrefetchHooks Function({
        bool trackLocationsTableRefs,
        bool scanRunsTableRefs,
      })
    >;
typedef $$TracksTableTableCreateCompanionBuilder =
    TracksTableCompanion Function({
      required String id,
      required String title,
      required String titleSort,
      Value<String?> artistName,
      Value<String?> albumTitle,
      Value<String?> albumId,
      Value<int?> durationMs,
      Value<int?> trackNo,
      Value<int?> discNo,
      Value<int?> year,
      Value<String?> artworkId,
      Value<int> rowid,
    });
typedef $$TracksTableTableUpdateCompanionBuilder =
    TracksTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> titleSort,
      Value<String?> artistName,
      Value<String?> albumTitle,
      Value<String?> albumId,
      Value<int?> durationMs,
      Value<int?> trackNo,
      Value<int?> discNo,
      Value<int?> year,
      Value<String?> artworkId,
      Value<int> rowid,
    });

final class $$TracksTableTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTableTable, TracksTableData> {
  $$TracksTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $TrackArtistsTableTable,
    List<TrackArtistsTableData>
  >
  _trackArtistsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackArtistsTable,
        aliasName: 'tracks__id__track_artists__track_id',
      );

  $$TrackArtistsTableTableProcessedTableManager get trackArtistsTableRefs {
    final manager = $$TrackArtistsTableTableTableManager(
      $_db,
      $_db.trackArtistsTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackArtistsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TrackLocationsTableTable,
    List<TrackLocationsTableData>
  >
  _trackLocationsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackLocationsTable,
        aliasName: 'tracks__id__track_locations__track_id',
      );

  $$TrackLocationsTableTableProcessedTableManager get trackLocationsTableRefs {
    final manager = $$TrackLocationsTableTableTableManager(
      $_db,
      $_db.trackLocationsTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackLocationsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PlaylistEntriesTableTable,
    List<PlaylistEntriesTableData>
  >
  _playlistEntriesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistEntriesTable,
        aliasName: 'tracks__id__playlist_entries__track_id',
      );

  $$PlaylistEntriesTableTableProcessedTableManager
  get playlistEntriesTableRefs {
    final manager = $$PlaylistEntriesTableTableTableManager(
      $_db,
      $_db.playlistEntriesTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistEntriesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TrackUserStateTableTable,
    List<TrackUserStateTableData>
  >
  _trackUserStateTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackUserStateTable,
        aliasName: 'tracks__id__track_user_state__track_id',
      );

  $$TrackUserStateTableTableProcessedTableManager get trackUserStateTableRefs {
    final manager = $$TrackUserStateTableTableTableManager(
      $_db,
      $_db.trackUserStateTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackUserStateTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $QueueEntriesTableTable,
    List<QueueEntriesTableData>
  >
  _queueEntriesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.queueEntriesTable,
        aliasName: 'tracks__id__queue_entries__track_id',
      );

  $$QueueEntriesTableTableProcessedTableManager get queueEntriesTableRefs {
    final manager = $$QueueEntriesTableTableTableManager(
      $_db,
      $_db.queueEntriesTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _queueEntriesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TracksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleSort => $composableBuilder(
    column: $table.titleSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNo => $composableBuilder(
    column: $table.trackNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNo => $composableBuilder(
    column: $table.discNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkId => $composableBuilder(
    column: $table.artworkId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackArtistsTableRefs(
    Expression<bool> Function($$TrackArtistsTableTableFilterComposer f) f,
  ) {
    final $$TrackArtistsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtistsTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistsTableTableFilterComposer(
            $db: $db,
            $table: $db.trackArtistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackLocationsTableRefs(
    Expression<bool> Function($$TrackLocationsTableTableFilterComposer f) f,
  ) {
    final $$TrackLocationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackLocationsTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackLocationsTableTableFilterComposer(
            $db: $db,
            $table: $db.trackLocationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playlistEntriesTableRefs(
    Expression<bool> Function($$PlaylistEntriesTableTableFilterComposer f) f,
  ) {
    final $$PlaylistEntriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntriesTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistEntriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackUserStateTableRefs(
    Expression<bool> Function($$TrackUserStateTableTableFilterComposer f) f,
  ) {
    final $$TrackUserStateTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackUserStateTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackUserStateTableTableFilterComposer(
            $db: $db,
            $table: $db.trackUserStateTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> queueEntriesTableRefs(
    Expression<bool> Function($$QueueEntriesTableTableFilterComposer f) f,
  ) {
    final $$QueueEntriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueEntriesTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableTableFilterComposer(
            $db: $db,
            $table: $db.queueEntriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleSort => $composableBuilder(
    column: $table.titleSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNo => $composableBuilder(
    column: $table.trackNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNo => $composableBuilder(
    column: $table.discNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkId => $composableBuilder(
    column: $table.artworkId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TracksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleSort =>
      $composableBuilder(column: $table.titleSort, builder: (column) => column);

  GeneratedColumn<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNo =>
      $composableBuilder(column: $table.trackNo, builder: (column) => column);

  GeneratedColumn<int> get discNo =>
      $composableBuilder(column: $table.discNo, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get artworkId =>
      $composableBuilder(column: $table.artworkId, builder: (column) => column);

  Expression<T> trackArtistsTableRefs<T extends Object>(
    Expression<T> Function($$TrackArtistsTableTableAnnotationComposer a) f,
  ) {
    final $$TrackArtistsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackArtistsTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackArtistsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackArtistsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> trackLocationsTableRefs<T extends Object>(
    Expression<T> Function($$TrackLocationsTableTableAnnotationComposer a) f,
  ) {
    final $$TrackLocationsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackLocationsTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackLocationsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackLocationsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> playlistEntriesTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistEntriesTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistEntriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistEntriesTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistEntriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistEntriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> trackUserStateTableRefs<T extends Object>(
    Expression<T> Function($$TrackUserStateTableTableAnnotationComposer a) f,
  ) {
    final $$TrackUserStateTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackUserStateTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackUserStateTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackUserStateTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> queueEntriesTableRefs<T extends Object>(
    Expression<T> Function($$QueueEntriesTableTableAnnotationComposer a) f,
  ) {
    final $$QueueEntriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.queueEntriesTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QueueEntriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.queueEntriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TracksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTableTable,
          TracksTableData,
          $$TracksTableTableFilterComposer,
          $$TracksTableTableOrderingComposer,
          $$TracksTableTableAnnotationComposer,
          $$TracksTableTableCreateCompanionBuilder,
          $$TracksTableTableUpdateCompanionBuilder,
          (TracksTableData, $$TracksTableTableReferences),
          TracksTableData,
          PrefetchHooks Function({
            bool trackArtistsTableRefs,
            bool trackLocationsTableRefs,
            bool playlistEntriesTableRefs,
            bool trackUserStateTableRefs,
            bool queueEntriesTableRefs,
          })
        > {
  $$TracksTableTableTableManager(_$AppDatabase db, $TracksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleSort = const Value.absent(),
                Value<String?> artistName = const Value.absent(),
                Value<String?> albumTitle = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> trackNo = const Value.absent(),
                Value<int?> discNo = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> artworkId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksTableCompanion(
                id: id,
                title: title,
                titleSort: titleSort,
                artistName: artistName,
                albumTitle: albumTitle,
                albumId: albumId,
                durationMs: durationMs,
                trackNo: trackNo,
                discNo: discNo,
                year: year,
                artworkId: artworkId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String titleSort,
                Value<String?> artistName = const Value.absent(),
                Value<String?> albumTitle = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> trackNo = const Value.absent(),
                Value<int?> discNo = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> artworkId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksTableCompanion.insert(
                id: id,
                title: title,
                titleSort: titleSort,
                artistName: artistName,
                albumTitle: albumTitle,
                albumId: albumId,
                durationMs: durationMs,
                trackNo: trackNo,
                discNo: discNo,
                year: year,
                artworkId: artworkId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TracksTableTable, TracksTableData>(table),
                  $$TracksTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                trackArtistsTableRefs = false,
                trackLocationsTableRefs = false,
                playlistEntriesTableRefs = false,
                trackUserStateTableRefs = false,
                queueEntriesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackArtistsTableRefs) db.trackArtistsTable,
                    if (trackLocationsTableRefs) db.trackLocationsTable,
                    if (playlistEntriesTableRefs) db.playlistEntriesTable,
                    if (trackUserStateTableRefs) db.trackUserStateTable,
                    if (queueEntriesTableRefs) db.queueEntriesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackArtistsTableRefs)
                        await $_getPrefetchedData<
                          TracksTableData,
                          $TracksTableTable,
                          TrackArtistsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableTableReferences
                              ._trackArtistsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackArtistsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackLocationsTableRefs)
                        await $_getPrefetchedData<
                          TracksTableData,
                          $TracksTableTable,
                          TrackLocationsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableTableReferences
                              ._trackLocationsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackLocationsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playlistEntriesTableRefs)
                        await $_getPrefetchedData<
                          TracksTableData,
                          $TracksTableTable,
                          PlaylistEntriesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableTableReferences
                              ._playlistEntriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistEntriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackUserStateTableRefs)
                        await $_getPrefetchedData<
                          TracksTableData,
                          $TracksTableTable,
                          TrackUserStateTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableTableReferences
                              ._trackUserStateTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackUserStateTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (queueEntriesTableRefs)
                        await $_getPrefetchedData<
                          TracksTableData,
                          $TracksTableTable,
                          QueueEntriesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableTableReferences
                              ._queueEntriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableTableReferences(
                                db,
                                table,
                                p0,
                              ).queueEntriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TracksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTableTable,
      TracksTableData,
      $$TracksTableTableFilterComposer,
      $$TracksTableTableOrderingComposer,
      $$TracksTableTableAnnotationComposer,
      $$TracksTableTableCreateCompanionBuilder,
      $$TracksTableTableUpdateCompanionBuilder,
      (TracksTableData, $$TracksTableTableReferences),
      TracksTableData,
      PrefetchHooks Function({
        bool trackArtistsTableRefs,
        bool trackLocationsTableRefs,
        bool playlistEntriesTableRefs,
        bool trackUserStateTableRefs,
        bool queueEntriesTableRefs,
      })
    >;
typedef $$ArtistsTableTableCreateCompanionBuilder =
    ArtistsTableCompanion Function({
      required String id,
      required String name,
      required String sortName,
      Value<int> rowid,
    });
typedef $$ArtistsTableTableUpdateCompanionBuilder =
    ArtistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> sortName,
      Value<int> rowid,
    });

final class $$ArtistsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ArtistsTableTable, ArtistsTableData> {
  $$ArtistsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $TrackArtistsTableTable,
    List<TrackArtistsTableData>
  >
  _trackArtistsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackArtistsTable,
        aliasName: 'artists__id__track_artists__artist_id',
      );

  $$TrackArtistsTableTableProcessedTableManager get trackArtistsTableRefs {
    final manager = $$TrackArtistsTableTableTableManager(
      $_db,
      $_db.trackArtistsTable,
    ).filter((f) => f.artistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackArtistsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArtistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ArtistsTableTable> {
  $$ArtistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackArtistsTableRefs(
    Expression<bool> Function($$TrackArtistsTableTableFilterComposer f) f,
  ) {
    final $$TrackArtistsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtistsTable,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistsTableTableFilterComposer(
            $db: $db,
            $table: $db.trackArtistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtistsTableTable> {
  $$ArtistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtistsTableTable> {
  $$ArtistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sortName =>
      $composableBuilder(column: $table.sortName, builder: (column) => column);

  Expression<T> trackArtistsTableRefs<T extends Object>(
    Expression<T> Function($$TrackArtistsTableTableAnnotationComposer a) f,
  ) {
    final $$TrackArtistsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackArtistsTable,
          getReferencedColumn: (t) => t.artistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackArtistsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackArtistsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ArtistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtistsTableTable,
          ArtistsTableData,
          $$ArtistsTableTableFilterComposer,
          $$ArtistsTableTableOrderingComposer,
          $$ArtistsTableTableAnnotationComposer,
          $$ArtistsTableTableCreateCompanionBuilder,
          $$ArtistsTableTableUpdateCompanionBuilder,
          (ArtistsTableData, $$ArtistsTableTableReferences),
          ArtistsTableData,
          PrefetchHooks Function({bool trackArtistsTableRefs})
        > {
  $$ArtistsTableTableTableManager(_$AppDatabase db, $ArtistsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sortName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtistsTableCompanion(
                id: id,
                name: name,
                sortName: sortName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String sortName,
                Value<int> rowid = const Value.absent(),
              }) => ArtistsTableCompanion.insert(
                id: id,
                name: name,
                sortName: sortName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArtistsTableTable, ArtistsTableData>(table),
                  $$ArtistsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackArtistsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trackArtistsTableRefs) db.trackArtistsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trackArtistsTableRefs)
                    await $_getPrefetchedData<
                      ArtistsTableData,
                      $ArtistsTableTable,
                      TrackArtistsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$ArtistsTableTableReferences
                          ._trackArtistsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ArtistsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).trackArtistsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.artistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ArtistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtistsTableTable,
      ArtistsTableData,
      $$ArtistsTableTableFilterComposer,
      $$ArtistsTableTableOrderingComposer,
      $$ArtistsTableTableAnnotationComposer,
      $$ArtistsTableTableCreateCompanionBuilder,
      $$ArtistsTableTableUpdateCompanionBuilder,
      (ArtistsTableData, $$ArtistsTableTableReferences),
      ArtistsTableData,
      PrefetchHooks Function({bool trackArtistsTableRefs})
    >;
typedef $$TrackArtistsTableTableCreateCompanionBuilder =
    TrackArtistsTableCompanion Function({
      required String trackId,
      required String artistId,
      Value<String> role,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$TrackArtistsTableTableUpdateCompanionBuilder =
    TrackArtistsTableCompanion Function({
      Value<String> trackId,
      Value<String> artistId,
      Value<String> role,
      Value<int> position,
      Value<int> rowid,
    });

final class $$TrackArtistsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackArtistsTableTable,
          TrackArtistsTableData
        > {
  $$TrackArtistsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTableTable _trackIdTable(_$AppDatabase db) =>
      db.tracksTable.createAlias('track_artists__track_id__tracks__id');

  $$TracksTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableTableManager(
      $_db,
      $_db.tracksTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ArtistsTableTable _artistIdTable(_$AppDatabase db) =>
      db.artistsTable.createAlias('track_artists__artist_id__artists__id');

  $$ArtistsTableTableProcessedTableManager get artistId {
    final $_column = $_itemColumn<String>('artist_id')!;

    final manager = $$ArtistsTableTableTableManager(
      $_db,
      $_db.artistsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackArtistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackArtistsTableTable> {
  $$TrackArtistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableTableFilterComposer get trackId {
    final $$TracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableFilterComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableTableFilterComposer get artistId {
    final $$ArtistsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableTableFilterComposer(
            $db: $db,
            $table: $db.artistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackArtistsTableTable> {
  $$TrackArtistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableTableOrderingComposer get trackId {
    final $$TracksTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableOrderingComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableTableOrderingComposer get artistId {
    final $$ArtistsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableTableOrderingComposer(
            $db: $db,
            $table: $db.artistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackArtistsTableTable> {
  $$TrackArtistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$TracksTableTableAnnotationComposer get trackId {
    final $$TracksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableTableAnnotationComposer get artistId {
    final $$ArtistsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.artistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackArtistsTableTable,
          TrackArtistsTableData,
          $$TrackArtistsTableTableFilterComposer,
          $$TrackArtistsTableTableOrderingComposer,
          $$TrackArtistsTableTableAnnotationComposer,
          $$TrackArtistsTableTableCreateCompanionBuilder,
          $$TrackArtistsTableTableUpdateCompanionBuilder,
          (TrackArtistsTableData, $$TrackArtistsTableTableReferences),
          TrackArtistsTableData,
          PrefetchHooks Function({bool trackId, bool artistId})
        > {
  $$TrackArtistsTableTableTableManager(
    _$AppDatabase db,
    $TrackArtistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackArtistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackArtistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackArtistsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackArtistsTableCompanion(
                trackId: trackId,
                artistId: artistId,
                role: role,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String artistId,
                Value<String> role = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackArtistsTableCompanion.insert(
                trackId: trackId,
                artistId: artistId,
                role: role,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackArtistsTableTable, TrackArtistsTableData>(
                    table,
                  ),
                  $$TrackArtistsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false, artistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$TrackArtistsTableTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$TrackArtistsTableTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (artistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.artistId,
                        referencedTable: $$TrackArtistsTableTableReferences
                            ._artistIdTable(db),
                        referencedColumn: $$TrackArtistsTableTableReferences
                            ._artistIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackArtistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackArtistsTableTable,
      TrackArtistsTableData,
      $$TrackArtistsTableTableFilterComposer,
      $$TrackArtistsTableTableOrderingComposer,
      $$TrackArtistsTableTableAnnotationComposer,
      $$TrackArtistsTableTableCreateCompanionBuilder,
      $$TrackArtistsTableTableUpdateCompanionBuilder,
      (TrackArtistsTableData, $$TrackArtistsTableTableReferences),
      TrackArtistsTableData,
      PrefetchHooks Function({bool trackId, bool artistId})
    >;
typedef $$AlbumsTableTableCreateCompanionBuilder =
    AlbumsTableCompanion Function({
      required String id,
      required String title,
      Value<String?> albumArtist,
      Value<int?> year,
      required String groupingKey,
      Value<int> rowid,
    });
typedef $$AlbumsTableTableUpdateCompanionBuilder =
    AlbumsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> albumArtist,
      Value<int?> year,
      Value<String> groupingKey,
      Value<int> rowid,
    });

class $$AlbumsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupingKey => $composableBuilder(
    column: $table.groupingKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlbumsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupingKey => $composableBuilder(
    column: $table.groupingKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get groupingKey => $composableBuilder(
    column: $table.groupingKey,
    builder: (column) => column,
  );
}

class $$AlbumsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumsTableTable,
          AlbumsTableData,
          $$AlbumsTableTableFilterComposer,
          $$AlbumsTableTableOrderingComposer,
          $$AlbumsTableTableAnnotationComposer,
          $$AlbumsTableTableCreateCompanionBuilder,
          $$AlbumsTableTableUpdateCompanionBuilder,
          (
            AlbumsTableData,
            BaseReferences<_$AppDatabase, $AlbumsTableTable, AlbumsTableData>,
          ),
          AlbumsTableData,
          PrefetchHooks Function()
        > {
  $$AlbumsTableTableTableManager(_$AppDatabase db, $AlbumsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> albumArtist = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> groupingKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsTableCompanion(
                id: id,
                title: title,
                albumArtist: albumArtist,
                year: year,
                groupingKey: groupingKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> albumArtist = const Value.absent(),
                Value<int?> year = const Value.absent(),
                required String groupingKey,
                Value<int> rowid = const Value.absent(),
              }) => AlbumsTableCompanion.insert(
                id: id,
                title: title,
                albumArtist: albumArtist,
                year: year,
                groupingKey: groupingKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlbumsTableTable, AlbumsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AlbumsTableTable,
                    AlbumsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlbumsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumsTableTable,
      AlbumsTableData,
      $$AlbumsTableTableFilterComposer,
      $$AlbumsTableTableOrderingComposer,
      $$AlbumsTableTableAnnotationComposer,
      $$AlbumsTableTableCreateCompanionBuilder,
      $$AlbumsTableTableUpdateCompanionBuilder,
      (
        AlbumsTableData,
        BaseReferences<_$AppDatabase, $AlbumsTableTable, AlbumsTableData>,
      ),
      AlbumsTableData,
      PrefetchHooks Function()
    >;
typedef $$TrackLocationsTableTableCreateCompanionBuilder =
    TrackLocationsTableCompanion Function({
      required String id,
      required String trackId,
      required String sourceId,
      required String locatorKey,
      required int size,
      Value<int?> modifiedAt,
      Value<String?> providerVersion,
      Value<String?> fingerprint,
      Value<String> availability,
      required int lastSeenGeneration,
      Value<int> rowid,
    });
typedef $$TrackLocationsTableTableUpdateCompanionBuilder =
    TrackLocationsTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> sourceId,
      Value<String> locatorKey,
      Value<int> size,
      Value<int?> modifiedAt,
      Value<String?> providerVersion,
      Value<String?> fingerprint,
      Value<String> availability,
      Value<int> lastSeenGeneration,
      Value<int> rowid,
    });

final class $$TrackLocationsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackLocationsTableTable,
          TrackLocationsTableData
        > {
  $$TrackLocationsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTableTable _trackIdTable(_$AppDatabase db) =>
      db.tracksTable.createAlias('track_locations__track_id__tracks__id');

  $$TracksTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableTableManager(
      $_db,
      $_db.tracksTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LibrarySourcesTableTable _sourceIdTable(_$AppDatabase db) => db
      .librarySourcesTable
      .createAlias('track_locations__source_id__library_sources__id');

  $$LibrarySourcesTableTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$LibrarySourcesTableTableTableManager(
      $_db,
      $_db.librarySourcesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackLocationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackLocationsTableTable> {
  $$TrackLocationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locatorKey => $composableBuilder(
    column: $table.locatorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenGeneration => $composableBuilder(
    column: $table.lastSeenGeneration,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableTableFilterComposer get trackId {
    final $$TracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableFilterComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LibrarySourcesTableTableFilterComposer get sourceId {
    final $$LibrarySourcesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.librarySourcesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibrarySourcesTableTableFilterComposer(
            $db: $db,
            $table: $db.librarySourcesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackLocationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackLocationsTableTable> {
  $$TrackLocationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locatorKey => $composableBuilder(
    column: $table.locatorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenGeneration => $composableBuilder(
    column: $table.lastSeenGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableTableOrderingComposer get trackId {
    final $$TracksTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableOrderingComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LibrarySourcesTableTableOrderingComposer get sourceId {
    final $$LibrarySourcesTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceId,
          referencedTable: $db.librarySourcesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibrarySourcesTableTableOrderingComposer(
                $db: $db,
                $table: $db.librarySourcesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrackLocationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackLocationsTableTable> {
  $$TrackLocationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locatorKey => $composableBuilder(
    column: $table.locatorKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenGeneration => $composableBuilder(
    column: $table.lastSeenGeneration,
    builder: (column) => column,
  );

  $$TracksTableTableAnnotationComposer get trackId {
    final $$TracksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LibrarySourcesTableTableAnnotationComposer get sourceId {
    final $$LibrarySourcesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceId,
          referencedTable: $db.librarySourcesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibrarySourcesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.librarySourcesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrackLocationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackLocationsTableTable,
          TrackLocationsTableData,
          $$TrackLocationsTableTableFilterComposer,
          $$TrackLocationsTableTableOrderingComposer,
          $$TrackLocationsTableTableAnnotationComposer,
          $$TrackLocationsTableTableCreateCompanionBuilder,
          $$TrackLocationsTableTableUpdateCompanionBuilder,
          (TrackLocationsTableData, $$TrackLocationsTableTableReferences),
          TrackLocationsTableData,
          PrefetchHooks Function({bool trackId, bool sourceId})
        > {
  $$TrackLocationsTableTableTableManager(
    _$AppDatabase db,
    $TrackLocationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackLocationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackLocationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackLocationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> locatorKey = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int?> modifiedAt = const Value.absent(),
                Value<String?> providerVersion = const Value.absent(),
                Value<String?> fingerprint = const Value.absent(),
                Value<String> availability = const Value.absent(),
                Value<int> lastSeenGeneration = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackLocationsTableCompanion(
                id: id,
                trackId: trackId,
                sourceId: sourceId,
                locatorKey: locatorKey,
                size: size,
                modifiedAt: modifiedAt,
                providerVersion: providerVersion,
                fingerprint: fingerprint,
                availability: availability,
                lastSeenGeneration: lastSeenGeneration,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String sourceId,
                required String locatorKey,
                required int size,
                Value<int?> modifiedAt = const Value.absent(),
                Value<String?> providerVersion = const Value.absent(),
                Value<String?> fingerprint = const Value.absent(),
                Value<String> availability = const Value.absent(),
                required int lastSeenGeneration,
                Value<int> rowid = const Value.absent(),
              }) => TrackLocationsTableCompanion.insert(
                id: id,
                trackId: trackId,
                sourceId: sourceId,
                locatorKey: locatorKey,
                size: size,
                modifiedAt: modifiedAt,
                providerVersion: providerVersion,
                fingerprint: fingerprint,
                availability: availability,
                lastSeenGeneration: lastSeenGeneration,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $TrackLocationsTableTable,
                    TrackLocationsTableData
                  >(table),
                  $$TrackLocationsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false, sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$TrackLocationsTableTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$TrackLocationsTableTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$TrackLocationsTableTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$TrackLocationsTableTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackLocationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackLocationsTableTable,
      TrackLocationsTableData,
      $$TrackLocationsTableTableFilterComposer,
      $$TrackLocationsTableTableOrderingComposer,
      $$TrackLocationsTableTableAnnotationComposer,
      $$TrackLocationsTableTableCreateCompanionBuilder,
      $$TrackLocationsTableTableUpdateCompanionBuilder,
      (TrackLocationsTableData, $$TrackLocationsTableTableReferences),
      TrackLocationsTableData,
      PrefetchHooks Function({bool trackId, bool sourceId})
    >;
typedef $$PlaylistsTableTableCreateCompanionBuilder =
    PlaylistsTableCompanion Function({
      required String id,
      required String name,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$PlaylistsTableTableUpdateCompanionBuilder =
    PlaylistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$PlaylistsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData
        > {
  $$PlaylistsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlaylistEntriesTableTable,
    List<PlaylistEntriesTableData>
  >
  _playlistEntriesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistEntriesTable,
        aliasName: 'playlists__id__playlist_entries__playlist_id',
      );

  $$PlaylistEntriesTableTableProcessedTableManager
  get playlistEntriesTableRefs {
    final manager = $$PlaylistEntriesTableTableTableManager(
      $_db,
      $_db.playlistEntriesTable,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistEntriesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistEntriesTableRefs(
    Expression<bool> Function($$PlaylistEntriesTableTableFilterComposer f) f,
  ) {
    final $$PlaylistEntriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntriesTable,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistEntriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playlistEntriesTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistEntriesTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistEntriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistEntriesTable,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistEntriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistEntriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaylistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData,
          $$PlaylistsTableTableFilterComposer,
          $$PlaylistsTableTableOrderingComposer,
          $$PlaylistsTableTableAnnotationComposer,
          $$PlaylistsTableTableCreateCompanionBuilder,
          $$PlaylistsTableTableUpdateCompanionBuilder,
          (PlaylistsTableData, $$PlaylistsTableTableReferences),
          PlaylistsTableData,
          PrefetchHooks Function({bool playlistEntriesTableRefs})
        > {
  $$PlaylistsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTableTable, PlaylistsTableData>(table),
                  $$PlaylistsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistEntriesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistEntriesTableRefs) db.playlistEntriesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistEntriesTableRefs)
                    await $_getPrefetchedData<
                      PlaylistsTableData,
                      $PlaylistsTableTable,
                      PlaylistEntriesTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableTableReferences
                          ._playlistEntriesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistEntriesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTableTable,
      PlaylistsTableData,
      $$PlaylistsTableTableFilterComposer,
      $$PlaylistsTableTableOrderingComposer,
      $$PlaylistsTableTableAnnotationComposer,
      $$PlaylistsTableTableCreateCompanionBuilder,
      $$PlaylistsTableTableUpdateCompanionBuilder,
      (PlaylistsTableData, $$PlaylistsTableTableReferences),
      PlaylistsTableData,
      PrefetchHooks Function({bool playlistEntriesTableRefs})
    >;
typedef $$PlaylistEntriesTableTableCreateCompanionBuilder =
    PlaylistEntriesTableCompanion Function({
      required String id,
      required String playlistId,
      required String trackId,
      required int position,
      Value<int> rowid,
    });
typedef $$PlaylistEntriesTableTableUpdateCompanionBuilder =
    PlaylistEntriesTableCompanion Function({
      Value<String> id,
      Value<String> playlistId,
      Value<String> trackId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$PlaylistEntriesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistEntriesTableTable,
          PlaylistEntriesTableData
        > {
  $$PlaylistEntriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTableTable _playlistIdTable(_$AppDatabase db) => db
      .playlistsTable
      .createAlias('playlist_entries__playlist_id__playlists__id');

  $$PlaylistsTableTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableTableManager(
      $_db,
      $_db.playlistsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TracksTableTable _trackIdTable(_$AppDatabase db) =>
      db.tracksTable.createAlias('playlist_entries__track_id__tracks__id');

  $$TracksTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableTableManager(
      $_db,
      $_db.tracksTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTableTable> {
  $$PlaylistEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableTableFilterComposer get playlistId {
    final $$PlaylistsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TracksTableTableFilterComposer get trackId {
    final $$TracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableFilterComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTableTable> {
  $$PlaylistEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableTableOrderingComposer get playlistId {
    final $$PlaylistsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableOrderingComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TracksTableTableOrderingComposer get trackId {
    final $$TracksTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableOrderingComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTableTable> {
  $$PlaylistEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaylistsTableTableAnnotationComposer get playlistId {
    final $$PlaylistsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TracksTableTableAnnotationComposer get trackId {
    final $$TracksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistEntriesTableTable,
          PlaylistEntriesTableData,
          $$PlaylistEntriesTableTableFilterComposer,
          $$PlaylistEntriesTableTableOrderingComposer,
          $$PlaylistEntriesTableTableAnnotationComposer,
          $$PlaylistEntriesTableTableCreateCompanionBuilder,
          $$PlaylistEntriesTableTableUpdateCompanionBuilder,
          (PlaylistEntriesTableData, $$PlaylistEntriesTableTableReferences),
          PlaylistEntriesTableData,
          PrefetchHooks Function({bool playlistId, bool trackId})
        > {
  $$PlaylistEntriesTableTableTableManager(
    _$AppDatabase db,
    $PlaylistEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaylistEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> playlistId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistEntriesTableCompanion(
                id: id,
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String playlistId,
                required String trackId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistEntriesTableCompanion.insert(
                id: id,
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PlaylistEntriesTableTable,
                    PlaylistEntriesTableData
                  >(table),
                  $$PlaylistEntriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$PlaylistEntriesTableTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$PlaylistEntriesTableTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$PlaylistEntriesTableTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$PlaylistEntriesTableTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistEntriesTableTable,
      PlaylistEntriesTableData,
      $$PlaylistEntriesTableTableFilterComposer,
      $$PlaylistEntriesTableTableOrderingComposer,
      $$PlaylistEntriesTableTableAnnotationComposer,
      $$PlaylistEntriesTableTableCreateCompanionBuilder,
      $$PlaylistEntriesTableTableUpdateCompanionBuilder,
      (PlaylistEntriesTableData, $$PlaylistEntriesTableTableReferences),
      PlaylistEntriesTableData,
      PrefetchHooks Function({bool playlistId, bool trackId})
    >;
typedef $$TrackUserStateTableTableCreateCompanionBuilder =
    TrackUserStateTableCompanion Function({
      required String trackId,
      Value<bool> favorite,
      Value<int> playCount,
      Value<int?> lastPlayedAt,
      Value<int> rowid,
    });
typedef $$TrackUserStateTableTableUpdateCompanionBuilder =
    TrackUserStateTableCompanion Function({
      Value<String> trackId,
      Value<bool> favorite,
      Value<int> playCount,
      Value<int?> lastPlayedAt,
      Value<int> rowid,
    });

final class $$TrackUserStateTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackUserStateTableTable,
          TrackUserStateTableData
        > {
  $$TrackUserStateTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTableTable _trackIdTable(_$AppDatabase db) =>
      db.tracksTable.createAlias('track_user_state__track_id__tracks__id');

  $$TracksTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableTableManager(
      $_db,
      $_db.tracksTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackUserStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackUserStateTableTable> {
  $$TrackUserStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableTableFilterComposer get trackId {
    final $$TracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableFilterComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackUserStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackUserStateTableTable> {
  $$TrackUserStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableTableOrderingComposer get trackId {
    final $$TracksTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableOrderingComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackUserStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackUserStateTableTable> {
  $$TrackUserStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  $$TracksTableTableAnnotationComposer get trackId {
    final $$TracksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackUserStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackUserStateTableTable,
          TrackUserStateTableData,
          $$TrackUserStateTableTableFilterComposer,
          $$TrackUserStateTableTableOrderingComposer,
          $$TrackUserStateTableTableAnnotationComposer,
          $$TrackUserStateTableTableCreateCompanionBuilder,
          $$TrackUserStateTableTableUpdateCompanionBuilder,
          (TrackUserStateTableData, $$TrackUserStateTableTableReferences),
          TrackUserStateTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$TrackUserStateTableTableTableManager(
    _$AppDatabase db,
    $TrackUserStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackUserStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackUserStateTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackUserStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackUserStateTableCompanion(
                trackId: trackId,
                favorite: favorite,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                Value<bool> favorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackUserStateTableCompanion.insert(
                trackId: trackId,
                favorite: favorite,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $TrackUserStateTableTable,
                    TrackUserStateTableData
                  >(table),
                  $$TrackUserStateTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$TrackUserStateTableTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$TrackUserStateTableTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackUserStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackUserStateTableTable,
      TrackUserStateTableData,
      $$TrackUserStateTableTableFilterComposer,
      $$TrackUserStateTableTableOrderingComposer,
      $$TrackUserStateTableTableAnnotationComposer,
      $$TrackUserStateTableTableCreateCompanionBuilder,
      $$TrackUserStateTableTableUpdateCompanionBuilder,
      (TrackUserStateTableData, $$TrackUserStateTableTableReferences),
      TrackUserStateTableData,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$QueueEntriesTableTableCreateCompanionBuilder =
    QueueEntriesTableCompanion Function({
      required String entryId,
      required String trackId,
      required int position,
      required int shufflePosition,
      Value<int> rowid,
    });
typedef $$QueueEntriesTableTableUpdateCompanionBuilder =
    QueueEntriesTableCompanion Function({
      Value<String> entryId,
      Value<String> trackId,
      Value<int> position,
      Value<int> shufflePosition,
      Value<int> rowid,
    });

final class $$QueueEntriesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $QueueEntriesTableTable,
          QueueEntriesTableData
        > {
  $$QueueEntriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTableTable _trackIdTable(_$AppDatabase db) =>
      db.tracksTable.createAlias('queue_entries__track_id__tracks__id');

  $$TracksTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableTableManager(
      $_db,
      $_db.tracksTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QueueEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $QueueEntriesTableTable> {
  $$QueueEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shufflePosition => $composableBuilder(
    column: $table.shufflePosition,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableTableFilterComposer get trackId {
    final $$TracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableFilterComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueEntriesTableTable> {
  $$QueueEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shufflePosition => $composableBuilder(
    column: $table.shufflePosition,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableTableOrderingComposer get trackId {
    final $$TracksTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableOrderingComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueEntriesTableTable> {
  $$QueueEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get shufflePosition => $composableBuilder(
    column: $table.shufflePosition,
    builder: (column) => column,
  );

  $$TracksTableTableAnnotationComposer get trackId {
    final $$TracksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.tracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueEntriesTableTable,
          QueueEntriesTableData,
          $$QueueEntriesTableTableFilterComposer,
          $$QueueEntriesTableTableOrderingComposer,
          $$QueueEntriesTableTableAnnotationComposer,
          $$QueueEntriesTableTableCreateCompanionBuilder,
          $$QueueEntriesTableTableUpdateCompanionBuilder,
          (QueueEntriesTableData, $$QueueEntriesTableTableReferences),
          QueueEntriesTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$QueueEntriesTableTableTableManager(
    _$AppDatabase db,
    $QueueEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueEntriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> shufflePosition = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueEntriesTableCompanion(
                entryId: entryId,
                trackId: trackId,
                position: position,
                shufflePosition: shufflePosition,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String trackId,
                required int position,
                required int shufflePosition,
                Value<int> rowid = const Value.absent(),
              }) => QueueEntriesTableCompanion.insert(
                entryId: entryId,
                trackId: trackId,
                position: position,
                shufflePosition: shufflePosition,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueEntriesTableTable, QueueEntriesTableData>(
                    table,
                  ),
                  $$QueueEntriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$QueueEntriesTableTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$QueueEntriesTableTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QueueEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueEntriesTableTable,
      QueueEntriesTableData,
      $$QueueEntriesTableTableFilterComposer,
      $$QueueEntriesTableTableOrderingComposer,
      $$QueueEntriesTableTableAnnotationComposer,
      $$QueueEntriesTableTableCreateCompanionBuilder,
      $$QueueEntriesTableTableUpdateCompanionBuilder,
      (QueueEntriesTableData, $$QueueEntriesTableTableReferences),
      QueueEntriesTableData,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$PlaybackSessionTableTableCreateCompanionBuilder =
    PlaybackSessionTableCompanion Function({
      required String id,
      Value<int> queueRevision,
      Value<String?> currentEntryId,
      Value<int> positionMs,
      Value<String> repeatMode,
      Value<int?> shuffleSeed,
      Value<bool> isShuffle,
      Value<int> rowid,
    });
typedef $$PlaybackSessionTableTableUpdateCompanionBuilder =
    PlaybackSessionTableCompanion Function({
      Value<String> id,
      Value<int> queueRevision,
      Value<String?> currentEntryId,
      Value<int> positionMs,
      Value<String> repeatMode,
      Value<int?> shuffleSeed,
      Value<bool> isShuffle,
      Value<int> rowid,
    });

class $$PlaybackSessionTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackSessionTableTable> {
  $$PlaybackSessionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queueRevision => $composableBuilder(
    column: $table.queueRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentEntryId => $composableBuilder(
    column: $table.currentEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shuffleSeed => $composableBuilder(
    column: $table.shuffleSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShuffle => $composableBuilder(
    column: $table.isShuffle,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackSessionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackSessionTableTable> {
  $$PlaybackSessionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queueRevision => $composableBuilder(
    column: $table.queueRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentEntryId => $composableBuilder(
    column: $table.currentEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shuffleSeed => $composableBuilder(
    column: $table.shuffleSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShuffle => $composableBuilder(
    column: $table.isShuffle,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackSessionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackSessionTableTable> {
  $$PlaybackSessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get queueRevision => $composableBuilder(
    column: $table.queueRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentEntryId => $composableBuilder(
    column: $table.currentEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shuffleSeed => $composableBuilder(
    column: $table.shuffleSeed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isShuffle =>
      $composableBuilder(column: $table.isShuffle, builder: (column) => column);
}

class $$PlaybackSessionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackSessionTableTable,
          PlaybackSessionTableData,
          $$PlaybackSessionTableTableFilterComposer,
          $$PlaybackSessionTableTableOrderingComposer,
          $$PlaybackSessionTableTableAnnotationComposer,
          $$PlaybackSessionTableTableCreateCompanionBuilder,
          $$PlaybackSessionTableTableUpdateCompanionBuilder,
          (
            PlaybackSessionTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaybackSessionTableTable,
              PlaybackSessionTableData
            >,
          ),
          PlaybackSessionTableData,
          PrefetchHooks Function()
        > {
  $$PlaybackSessionTableTableTableManager(
    _$AppDatabase db,
    $PlaybackSessionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackSessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackSessionTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaybackSessionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> queueRevision = const Value.absent(),
                Value<String?> currentEntryId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<int?> shuffleSeed = const Value.absent(),
                Value<bool> isShuffle = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackSessionTableCompanion(
                id: id,
                queueRevision: queueRevision,
                currentEntryId: currentEntryId,
                positionMs: positionMs,
                repeatMode: repeatMode,
                shuffleSeed: shuffleSeed,
                isShuffle: isShuffle,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> queueRevision = const Value.absent(),
                Value<String?> currentEntryId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<int?> shuffleSeed = const Value.absent(),
                Value<bool> isShuffle = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackSessionTableCompanion.insert(
                id: id,
                queueRevision: queueRevision,
                currentEntryId: currentEntryId,
                positionMs: positionMs,
                repeatMode: repeatMode,
                shuffleSeed: shuffleSeed,
                isShuffle: isShuffle,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PlaybackSessionTableTable,
                    PlaybackSessionTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaybackSessionTableTable,
                    PlaybackSessionTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackSessionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackSessionTableTable,
      PlaybackSessionTableData,
      $$PlaybackSessionTableTableFilterComposer,
      $$PlaybackSessionTableTableOrderingComposer,
      $$PlaybackSessionTableTableAnnotationComposer,
      $$PlaybackSessionTableTableCreateCompanionBuilder,
      $$PlaybackSessionTableTableUpdateCompanionBuilder,
      (
        PlaybackSessionTableData,
        BaseReferences<
          _$AppDatabase,
          $PlaybackSessionTableTable,
          PlaybackSessionTableData
        >,
      ),
      PlaybackSessionTableData,
      PrefetchHooks Function()
    >;
typedef $$ArtworksTableTableCreateCompanionBuilder =
    ArtworksTableCompanion Function({
      required String id,
      required String contentHash,
      required String cacheKey,
      Value<int?> width,
      Value<int?> height,
      required int byteSize,
      Value<int> rowid,
    });
typedef $$ArtworksTableTableUpdateCompanionBuilder =
    ArtworksTableCompanion Function({
      Value<String> id,
      Value<String> contentHash,
      Value<String> cacheKey,
      Value<int?> width,
      Value<int?> height,
      Value<int> byteSize,
      Value<int> rowid,
    });

class $$ArtworksTableTableFilterComposer
    extends Composer<_$AppDatabase, $ArtworksTableTable> {
  $$ArtworksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtworksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtworksTableTable> {
  $$ArtworksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtworksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtworksTableTable> {
  $$ArtworksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);
}

class $$ArtworksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtworksTableTable,
          ArtworksTableData,
          $$ArtworksTableTableFilterComposer,
          $$ArtworksTableTableOrderingComposer,
          $$ArtworksTableTableAnnotationComposer,
          $$ArtworksTableTableCreateCompanionBuilder,
          $$ArtworksTableTableUpdateCompanionBuilder,
          (
            ArtworksTableData,
            BaseReferences<
              _$AppDatabase,
              $ArtworksTableTable,
              ArtworksTableData
            >,
          ),
          ArtworksTableData,
          PrefetchHooks Function()
        > {
  $$ArtworksTableTableTableManager(_$AppDatabase db, $ArtworksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtworksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtworksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtworksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtworksTableCompanion(
                id: id,
                contentHash: contentHash,
                cacheKey: cacheKey,
                width: width,
                height: height,
                byteSize: byteSize,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contentHash,
                required String cacheKey,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required int byteSize,
                Value<int> rowid = const Value.absent(),
              }) => ArtworksTableCompanion.insert(
                id: id,
                contentHash: contentHash,
                cacheKey: cacheKey,
                width: width,
                height: height,
                byteSize: byteSize,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArtworksTableTable, ArtworksTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ArtworksTableTable,
                    ArtworksTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtworksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtworksTableTable,
      ArtworksTableData,
      $$ArtworksTableTableFilterComposer,
      $$ArtworksTableTableOrderingComposer,
      $$ArtworksTableTableAnnotationComposer,
      $$ArtworksTableTableCreateCompanionBuilder,
      $$ArtworksTableTableUpdateCompanionBuilder,
      (
        ArtworksTableData,
        BaseReferences<_$AppDatabase, $ArtworksTableTable, ArtworksTableData>,
      ),
      ArtworksTableData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String key,
      required String valueJson,
      Value<int> schemaVersion,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<int> schemaVersion,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsTableData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $SettingsTableTable,
              SettingsTableData
            >,
          ),
          SettingsTableData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion(
                key: key,
                valueJson: valueJson,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                Value<int> schemaVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                key: key,
                valueJson: valueJson,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTableTable, SettingsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsTableTable,
                    SettingsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsTableData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsTableData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>,
      ),
      SettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$ScanRunsTableTableCreateCompanionBuilder =
    ScanRunsTableCompanion Function({
      required String id,
      required String sourceId,
      required int generation,
      required String status,
      Value<String?> cursor,
      Value<String?> countersJson,
      Value<int> rowid,
    });
typedef $$ScanRunsTableTableUpdateCompanionBuilder =
    ScanRunsTableCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<int> generation,
      Value<String> status,
      Value<String?> cursor,
      Value<String?> countersJson,
      Value<int> rowid,
    });

final class $$ScanRunsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ScanRunsTableTable, ScanRunsTableData> {
  $$ScanRunsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LibrarySourcesTableTable _sourceIdTable(_$AppDatabase db) => db
      .librarySourcesTable
      .createAlias('scan_runs__source_id__library_sources__id');

  $$LibrarySourcesTableTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$LibrarySourcesTableTableTableManager(
      $_db,
      $_db.librarySourcesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScanRunsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScanRunsTableTable> {
  $$ScanRunsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countersJson => $composableBuilder(
    column: $table.countersJson,
    builder: (column) => ColumnFilters(column),
  );

  $$LibrarySourcesTableTableFilterComposer get sourceId {
    final $$LibrarySourcesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.librarySourcesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibrarySourcesTableTableFilterComposer(
            $db: $db,
            $table: $db.librarySourcesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanRunsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanRunsTableTable> {
  $$ScanRunsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countersJson => $composableBuilder(
    column: $table.countersJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibrarySourcesTableTableOrderingComposer get sourceId {
    final $$LibrarySourcesTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceId,
          referencedTable: $db.librarySourcesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibrarySourcesTableTableOrderingComposer(
                $db: $db,
                $table: $db.librarySourcesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScanRunsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanRunsTableTable> {
  $$ScanRunsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<String> get countersJson => $composableBuilder(
    column: $table.countersJson,
    builder: (column) => column,
  );

  $$LibrarySourcesTableTableAnnotationComposer get sourceId {
    final $$LibrarySourcesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceId,
          referencedTable: $db.librarySourcesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibrarySourcesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.librarySourcesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScanRunsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanRunsTableTable,
          ScanRunsTableData,
          $$ScanRunsTableTableFilterComposer,
          $$ScanRunsTableTableOrderingComposer,
          $$ScanRunsTableTableAnnotationComposer,
          $$ScanRunsTableTableCreateCompanionBuilder,
          $$ScanRunsTableTableUpdateCompanionBuilder,
          (ScanRunsTableData, $$ScanRunsTableTableReferences),
          ScanRunsTableData,
          PrefetchHooks Function({bool sourceId})
        > {
  $$ScanRunsTableTableTableManager(_$AppDatabase db, $ScanRunsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanRunsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanRunsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanRunsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<String?> countersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanRunsTableCompanion(
                id: id,
                sourceId: sourceId,
                generation: generation,
                status: status,
                cursor: cursor,
                countersJson: countersJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required int generation,
                required String status,
                Value<String?> cursor = const Value.absent(),
                Value<String?> countersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanRunsTableCompanion.insert(
                id: id,
                sourceId: sourceId,
                generation: generation,
                status: status,
                cursor: cursor,
                countersJson: countersJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanRunsTableTable, ScanRunsTableData>(table),
                  $$ScanRunsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$ScanRunsTableTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$ScanRunsTableTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScanRunsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanRunsTableTable,
      ScanRunsTableData,
      $$ScanRunsTableTableFilterComposer,
      $$ScanRunsTableTableOrderingComposer,
      $$ScanRunsTableTableAnnotationComposer,
      $$ScanRunsTableTableCreateCompanionBuilder,
      $$ScanRunsTableTableUpdateCompanionBuilder,
      (ScanRunsTableData, $$ScanRunsTableTableReferences),
      ScanRunsTableData,
      PrefetchHooks Function({bool sourceId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibrarySourcesTableTableTableManager get librarySourcesTable =>
      $$LibrarySourcesTableTableTableManager(_db, _db.librarySourcesTable);
  $$TracksTableTableTableManager get tracksTable =>
      $$TracksTableTableTableManager(_db, _db.tracksTable);
  $$ArtistsTableTableTableManager get artistsTable =>
      $$ArtistsTableTableTableManager(_db, _db.artistsTable);
  $$TrackArtistsTableTableTableManager get trackArtistsTable =>
      $$TrackArtistsTableTableTableManager(_db, _db.trackArtistsTable);
  $$AlbumsTableTableTableManager get albumsTable =>
      $$AlbumsTableTableTableManager(_db, _db.albumsTable);
  $$TrackLocationsTableTableTableManager get trackLocationsTable =>
      $$TrackLocationsTableTableTableManager(_db, _db.trackLocationsTable);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(_db, _db.playlistsTable);
  $$PlaylistEntriesTableTableTableManager get playlistEntriesTable =>
      $$PlaylistEntriesTableTableTableManager(_db, _db.playlistEntriesTable);
  $$TrackUserStateTableTableTableManager get trackUserStateTable =>
      $$TrackUserStateTableTableTableManager(_db, _db.trackUserStateTable);
  $$QueueEntriesTableTableTableManager get queueEntriesTable =>
      $$QueueEntriesTableTableTableManager(_db, _db.queueEntriesTable);
  $$PlaybackSessionTableTableTableManager get playbackSessionTable =>
      $$PlaybackSessionTableTableTableManager(_db, _db.playbackSessionTable);
  $$ArtworksTableTableTableManager get artworksTable =>
      $$ArtworksTableTableTableManager(_db, _db.artworksTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$ScanRunsTableTableTableManager get scanRunsTable =>
      $$ScanRunsTableTableTableManager(_db, _db.scanRunsTable);
}
