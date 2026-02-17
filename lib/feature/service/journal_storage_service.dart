import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../model/journal_model.dart';
import 'auth_service.dart';

class JournalStorageService {
  static const String _baseJournalKey = 'trading_journals';
  static const String _baseFolderKey = 'journal_folders';
  final GetStorage _storage = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  static String get journalKey {
    final uid = AuthService().currentUid;
    return uid != null ? '${_baseJournalKey}_$uid' : _baseJournalKey;
  }

  static String get folderKey {
    final uid = AuthService().currentUid;
    return uid != null ? '${_baseFolderKey}_$uid' : _baseFolderKey;
  }

  // Collection references
  CollectionReference<Map<String, dynamic>>? get _userJournalsCollection {
    final uid = _auth.currentUid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('journals');
  }

  CollectionReference<Map<String, dynamic>>? get _userFoldersCollection {
    final uid = _auth.currentUid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('folders');
  }

  // Cache for deserialized data
  List<JournalModel>? _cachedJournals;
  List<JournalFolderModel>? _cachedFolders;
  String? _journalsHash;
  String? _foldersHash;

  // Journal Methods
  Future<void> saveJournal(JournalModel journal) async {
    List<dynamic> journals = _storage.read(journalKey) ?? [];
    journals.insert(0, journal.toJson());
    await _storage.write(journalKey, journals);
    _invalidateJournalsCache();

    // Sync to Firestore
    try {
      final collection = _userJournalsCollection;
      if (collection != null) {
        await collection.doc(journal.id).set(journal.toJson());
      }
    } catch (e) {
      print("Error syncing journal: $e");
    }
  }

  List<JournalModel> getAllJournals() {
    List<dynamic> journalsJson = _storage.read(journalKey) ?? [];
    final currentHash = journalsJson.length.toString();

    if (_cachedJournals != null && _journalsHash == currentHash) {
      return List.from(_cachedJournals!);
    }

    _cachedJournals = journalsJson
        .map((json) => JournalModel.fromJson(json as Map<String, dynamic>))
        .toList();
    _journalsHash = currentHash;

    return List.from(_cachedJournals!);
  }

  Future<void> migrateLegacyData() async {
    final uid = _auth.currentUid;
    if (uid == null) return;

    print("Checking legacy journals for migration...");

    // Migrate Journals
    final legacyJournals = _storage.read(_baseJournalKey);
    final currentJournals = _storage.read(journalKey);
    if (legacyJournals != null &&
        (currentJournals == null ||
            (currentJournals is List && currentJournals.isEmpty))) {
      await _storage.write(journalKey, legacyJournals);
      print("SUCCESS: Migrated legacy journals for user: $uid");
    }

    // Migrate Folders
    final legacyFolders = _storage.read(_baseFolderKey);
    final currentFolders = _storage.read(folderKey);
    if (legacyFolders != null &&
        (currentFolders == null ||
            (currentFolders is List && currentFolders.isEmpty))) {
      await _storage.write(folderKey, legacyFolders);
      print("SUCCESS: Migrated legacy folders for user: $uid");
    }
  }

  Future<void> syncFromFirestore() async {
    print("Syncing journals from Firestore...");
    try {
      await migrateLegacyData(); // Migrate before syncing

      final journalsCol = _userJournalsCollection;
      if (journalsCol != null) {
        final snapshot = await journalsCol.get();
        print("Firestore journals found: ${snapshot.docs.length}");
        if (snapshot.docs.isNotEmpty) {
          final journals = snapshot.docs.map((doc) => doc.data()).toList();
          await _storage.write(journalKey, journals);
          print("Updated local journals from cloud.");
          _invalidateJournalsCache();
        }
      }

      final foldersCol = _userFoldersCollection;
      if (foldersCol != null) {
        final snapshot = await foldersCol.get();
        print("Firestore folders found: ${snapshot.docs.length}");
        if (snapshot.docs.isNotEmpty) {
          final folders = snapshot.docs.map((doc) => doc.data()).toList();
          await _storage.write(folderKey, folders);
          print("Updated local folders from cloud.");
          _invalidateFoldersCache();
        }
      }

      print("Firestore sync check complete, pushing any new local data...");
      await pushToFirestore();
    } catch (e) {
      print("Error fetching journals/folders: $e");
    }
  }

  Future<void> pushToFirestore() async {
    try {
      final jCol = _userJournalsCollection;
      final fCol = _userFoldersCollection;
      if (jCol == null || fCol == null) {
        print("Push aborted: Journal/Folder collection null.");
        return;
      }

      final folders = getAllFolders();
      print("Local folders to push: ${folders.length}");
      for (var f in folders) {
        await fCol.doc(f.id).set(f.toJson());
        print("Uploaded folder: ${f.id}");
      }

      final journals = getAllJournals();
      print("Local journals to push: ${journals.length}");
      for (var j in journals) {
        await jCol.doc(j.id).set(j.toJson());
        print("Uploaded journal: ${j.id}");
      }
      print("Successfully pushed journals and folders to Firestore.");
    } catch (e) {
      print("Error pushing journals to Firestore: $e");
    }
  }

  List<JournalModel> getJournalsByFolder(String folderId) {
    return getAllJournals().where((j) => j.folderId == folderId).toList();
  }

  List<JournalModel> getTradingJournals() {
    return getAllJournals().where((j) => j.type == 'plan_day').toList();
  }

  // Folder Methods
  Future<void> saveFolder(JournalFolderModel folder) async {
    List<dynamic> folders = _storage.read(folderKey) ?? [];
    folders.add(folder.toJson());
    await _storage.write(folderKey, folders);
    _invalidateFoldersCache();

    // Sync to Firestore
    try {
      final collection = _userFoldersCollection;
      if (collection != null) {
        await collection.doc(folder.id).set(folder.toJson());
      }
    } catch (e) {
      print("Error syncing folder: $e");
    }
  }

  List<JournalFolderModel> getAllFolders() {
    List<dynamic> foldersJson = _storage.read(folderKey) ?? [];
    final currentHash = foldersJson.length.toString();

    if (_cachedFolders != null && _foldersHash == currentHash) {
      return List.from(_cachedFolders!);
    }

    _cachedFolders = foldersJson
        .map(
          (json) => JournalFolderModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    _foldersHash = currentHash;

    return List.from(_cachedFolders!);
  }

  Future<void> deleteJournal(String id) async {
    List<dynamic> journalsJson = _storage.read(journalKey) ?? [];
    journalsJson.removeWhere((json) => json['id'] == id);
    await _storage.write(journalKey, journalsJson);
    _invalidateJournalsCache();

    try {
      final collection = _userJournalsCollection;
      if (collection != null) {
        await collection.doc(id).delete();
      }
    } catch (e) {
      print("Error deleting journal: $e");
    }
  }

  Future<void> deleteFolder(String id) async {
    List<dynamic> foldersJson = _storage.read(folderKey) ?? [];
    foldersJson.removeWhere((json) => json['id'] == id);
    await _storage.write(folderKey, foldersJson);
    _invalidateFoldersCache();

    try {
      final collection = _userFoldersCollection;
      if (collection != null) {
        await collection.doc(id).delete();
      }
    } catch (e) {
      print("Error deleting folder: $e");
    }

    // Optional: Delete all journals in that folder
    List<dynamic> journalsJson = _storage.read(journalKey) ?? [];
    final toDelete = journalsJson
        .where((json) => json['folderId'] == id)
        .toList();
    journalsJson.removeWhere((json) => json['folderId'] == id);
    await _storage.write(journalKey, journalsJson);
    _invalidateJournalsCache();

    for (var journal in toDelete) {
      try {
        await _userJournalsCollection?.doc(journal['id']).delete();
      } catch (e) {}
    }
  }

  Future<void> clearAll() async {
    await _storage.remove(journalKey);
    await _storage.remove(folderKey);
    _invalidateJournalsCache();
    _invalidateFoldersCache();

    // Clear Firestore
    // Note: Usually we don't clear entire collections on the client side this way,
    // but follow-up logic for a full reset.
  }

  void _invalidateJournalsCache() {
    _cachedJournals = null;
    _journalsHash = null;
  }

  void _invalidateFoldersCache() {
    _cachedFolders = null;
    _foldersHash = null;
  }
}
