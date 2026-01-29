import 'package:get_storage/get_storage.dart';
import '../model/journal_model.dart';

class JournalStorageService {
  static const String _journalKey = 'trading_journals';
  static const String _folderKey = 'journal_folders';
  final GetStorage _storage = GetStorage();

  // Journal Methods
  Future<void> saveJournal(JournalModel journal) async {
    List<dynamic> journals = _storage.read(_journalKey) ?? [];
    journals.insert(0, journal.toJson());
    await _storage.write(_journalKey, journals);
  }

  List<JournalModel> getAllJournals() {
    List<dynamic> journalsJson = _storage.read(_journalKey) ?? [];
    return journalsJson.map((json) => JournalModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  List<JournalModel> getJournalsByFolder(String folderId) {
    return getAllJournals().where((j) => j.folderId == folderId).toList();
  }

  List<JournalModel> getTradingJournals() {
    return getAllJournals().where((j) => j.type == 'plan_day').toList();
  }

  // Folder Methods
  Future<void> saveFolder(JournalFolderModel folder) async {
    List<dynamic> folders = _storage.read(_folderKey) ?? [];
    folders.add(folder.toJson());
    await _storage.write(_folderKey, folders);
  }

  List<JournalFolderModel> getAllFolders() {
    List<dynamic> foldersJson = _storage.read(_folderKey) ?? [];
    return foldersJson.map((json) => JournalFolderModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> deleteJournal(String id) async {
    List<dynamic> journalsJson = _storage.read(_journalKey) ?? [];
    journalsJson.removeWhere((json) => json['id'] == id);
    await _storage.write(_journalKey, journalsJson);
  }

  Future<void> deleteFolder(String id) async {
    List<dynamic> foldersJson = _storage.read(_folderKey) ?? [];
    foldersJson.removeWhere((json) => json['id'] == id);
    await _storage.write(_folderKey, foldersJson);
    
    // Optional: Delete all journals in that folder
    List<dynamic> journalsJson = _storage.read(_journalKey) ?? [];
    journalsJson.removeWhere((json) => json['folderId'] == id);
    await _storage.write(_journalKey, journalsJson);
  }

  Future<void> clearAll() async {
    await _storage.remove(_journalKey);
    await _storage.remove(_folderKey);
  }
}
