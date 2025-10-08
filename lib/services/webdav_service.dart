import 'dart:io';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path_provider/path_provider.dart';
import '../models/app_settings.dart';

class WebdavService {
  webdav.Client? _client;
  AppSettings? _settings;

  static const String _syncFolderName = 'ServiceTracker';

  /// Initialize WebDAV client with credentials
  void initialize(AppSettings settings) {
    if (!settings.hasWebdavCredentials) {
      _client = null;
      _settings = null;
      return;
    }

    _settings = settings;
    _client = webdav.newClient(
      settings.webdavUrl!,
      user: settings.webdavUsername!,
      password: settings.webdavPassword!,
      debug: false,
    );
  }

  /// Validate WebDAV connection and credentials
  Future<bool> validateConnection(String url, String username, String password) async {
    try {
      final testClient = webdav.newClient(
        url,
        user: username,
        password: password,
        debug: false,
      );

      // Try to ping the server
      await testClient.ping();
      return true;
    } catch (e) {
      print('WebDAV validation error: $e');
      return false;
    }
  }

  /// Check if client is initialized
  bool get isInitialized => _client != null && _settings != null;

  /// Ensure sync folder exists on WebDAV server
  Future<void> _ensureSyncFolderExists() async {
    if (_client == null) return;

    try {
      // Check if folder exists
      final exists = await _client!.readDir('/');
      final folderExists = exists.any((item) => 
        item.name?.contains(_syncFolderName) ?? false
      );

      if (!folderExists) {
        // Create the folder
        await _client!.mkdir(_syncFolderName);
        print('Created sync folder: $_syncFolderName');
      }
    } catch (e) {
      print('Error ensuring sync folder exists: $e');
      // Try to create it anyway
      try {
        await _client!.mkdir(_syncFolderName);
      } catch (createError) {
        print('Error creating sync folder: $createError');
      }
    }
  }

  /// Upload a file to WebDAV server
  Future<bool> uploadFile(String localFilePath, String remoteFileName) async {
    if (_client == null || !isInitialized) {
      print('WebDAV client not initialized');
      return false;
    }

    try {
      await _ensureSyncFolderExists();

      final file = File(localFilePath);
      if (!await file.exists()) {
        print('Local file does not exist: $localFilePath');
        return false;
      }

      final fileBytes = await file.readAsBytes();
      final remotePath = '$_syncFolderName/$remoteFileName';

      await _client!.write(remotePath, fileBytes);
      print('Uploaded file: $remotePath');
      return true;
    } catch (e) {
      print('Error uploading file $remoteFileName: $e');
      return false;
    }
  }

  /// Download a file from WebDAV server
  Future<bool> downloadFile(String remoteFileName, String localFilePath) async {
    if (_client == null || !isInitialized) {
      print('WebDAV client not initialized');
      return false;
    }

    try {
      final remotePath = '$_syncFolderName/$remoteFileName';
      final fileBytes = await _client!.read(remotePath);

      final file = File(localFilePath);
      await file.writeAsBytes(fileBytes);
      print('Downloaded file: $remotePath');
      return true;
    } catch (e) {
      print('Error downloading file $remoteFileName: $e');
      return false;
    }
  }

  /// Sync all car data files to WebDAV server
  Future<Map<String, bool>> syncToServer() async {
    if (_client == null || !isInitialized) {
      return {};
    }

    final directory = await getApplicationDocumentsDirectory();
    final results = <String, bool>{};

    try {
      // Get all JSON files in the directory
      final files = directory.listSync()
          .where((item) => item is File && item.path.endsWith('.json'))
          .cast<File>();

      for (final file in files) {
        final fileName = file.path.split('/').last;
        final success = await uploadFile(file.path, fileName);
        results[fileName] = success;
      }

      print('Sync to server completed: ${results.length} files processed');
    } catch (e) {
      print('Error syncing to server: $e');
    }

    return results;
  }

  /// Sync all car data files from WebDAV server
  Future<Map<String, bool>> syncFromServer() async {
    if (_client == null || !isInitialized) {
      return {};
    }

    final directory = await getApplicationDocumentsDirectory();
    final results = <String, bool>{};

    try {
      await _ensureSyncFolderExists();

      // List all files in the sync folder
      final remoteFiles = await _client!.readDir(_syncFolderName);

      for (final remoteFile in remoteFiles) {
        final fileName = remoteFile.name;
        if (fileName == null || !fileName.endsWith('.json')) continue;

        final localPath = '${directory.path}/$fileName';
        final success = await downloadFile(fileName, localPath);
        results[fileName] = success;
      }

      print('Sync from server completed: ${results.length} files processed');
    } catch (e) {
      print('Error syncing from server: $e');
    }

    return results;
  }

  /// Auto-sync a single file to server (called after each save operation)
  Future<void> autoSyncFile(String fileName) async {
    if (_client == null || !isInitialized) {
      return;
    }

    if (_settings?.autoSync != true) {
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/$fileName';
      await uploadFile(localPath, fileName);
    } catch (e) {
      print('Auto-sync failed for $fileName: $e');
      // Don't throw - auto-sync should be silent
    }
  }

  /// Get sync status info
  Future<Map<String, dynamic>> getSyncStatus() async {
    if (_client == null || !isInitialized) {
      return {
        'connected': false,
        'fileCount': 0,
      };
    }

    try {
      await _client!.ping();
      
      await _ensureSyncFolderExists();
      final remoteFiles = await _client!.readDir(_syncFolderName);
      final jsonFiles = remoteFiles.where((f) => 
        f.name?.endsWith('.json') ?? false
      ).length;

      return {
        'connected': true,
        'fileCount': jsonFiles,
      };
    } catch (e) {
      print('Error getting sync status: $e');
      return {
        'connected': false,
        'fileCount': 0,
        'error': e.toString(),
      };
    }
  }

  /// Clear client (logout)
  void clear() {
    _client = null;
    _settings = null;
  }
}

