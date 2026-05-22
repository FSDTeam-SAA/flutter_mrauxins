import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../models/otp_verify.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // New database name
  static const String _newDbName = '212Messanger.db';
  // Old database name (keep as constant for reference)
  static const String _oldDbName = 'telegram_clone.db';
  static const int _databaseVersion = 4;

  // Create or open the database
  // Future<Database> _initDatabase() async {
  //   String path = join(await getDatabasesPath(), 'telegram_clone.db');
  //   return await openDatabase(
  //     path,
  //     version: _databaseVersion, // Incremented version number
  //     onCreate: _createDatabase,
  //     onUpgrade: _onUpgrade, // Add the onUpgrade callback
  //   );
  // }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final oldPath = join(databasesPath, _oldDbName);
    final newPath = join(databasesPath, _newDbName);

    // Check if old database exists
    final oldDbExists = await databaseExists(oldPath);

    // Check if new database exists
    final newDbExists = await databaseExists(newPath);

    if (oldDbExists && !newDbExists) {
      // Migrate from old to new database
      await _migrateDatabase(oldPath, newPath);
    }

    // Open the new database
    return await openDatabase(
      newPath,
      version: _databaseVersion, // Your current version
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _migrateDatabase(String oldPath, String newPath) async {
    try {
      // 1. Open the old database
      final oldDb = await openDatabase(oldPath);

      // 2. Create the new database with the same structure
      final newDb = await openDatabase(
        newPath,
        version: _databaseVersion,
        onCreate: _createDatabase,
      );

      // 3. Migrate data table by table
      await _migrateTable(oldDb, newDb, 'login_data');
      await _migrateTable(oldDb, newDb, 'contacts');
      await _migrateTable(oldDb, newDb, 'settings');
      await _migrateTable(oldDb, newDb, 'messages');

      // 4. Close both databases
      // await oldDb.close();
      // await newDb.close();

      // 5. Delete the old database
      await deleteDatabase(oldPath);

      print('Database migration completed successfully');
    } catch (e) {
      print('Error during database migration: $e');
      // If migration fails, the app will continue with the old database
      // You might want to implement a retry mechanism or fallback
    }
  }

  Future<void> _migrateTable(
      Database source, Database target, String tableName) async {
    // Check if table exists in source
    final tables = await source.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");

    if (tables.isEmpty) return;

    // Get all data from source table
    final data = await source.query(tableName);

    // Insert into target table
    final batch = target.batch();
    for (final row in data) {
      batch.insert(tableName, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  // Create tables
  Future<void> _createDatabase(Database db, int version) async {
    print("create Table==>$version");
    await db.execute('''
      CREATE TABLE login_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        _id TEXT,
        email TEXT,
        phone TEXT,
        name TEXT,
        userName TEXT,
        isVerified INTEGER,
        providerId TEXT,
        providerName TEXT,
        isOnline INTEGER,
        lastSeen TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        __v INTEGER,
        profilePicture TEXT,
        privateKey TEXT,
        publicKey TEXT,
        profilePrivacy TEXT,
        bio TEXT,
        countryISOCode TEXT,
        countryCode TEXT,
        isProfileSetUp INTEGER,
        isStopNotification INTEGER,
        isEmailVerify INTEGER,
        isPhoneVerify INTEGER,
        isMuteNotification INTEGER,
        chatId TEXT,
        isBlocked INTEGER,
        youBlocked INTEGER,
        messageAutoDeleteTime INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        _id TEXT,
        email TEXT UNIQUE,
        phone TEXT UNIQUE,
        name TEXT,
        userName TEXT,
        isOnline INTEGER,
        isRegistered INTEGER,
        lastSeen TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        __v INTEGER,
        profilePicture TEXT,
        bio TEXT,
        countryISOCode TEXT,
        countryCode TEXT,
        chatId TEXT,
        isBlocked INTEGER,
        youBlocked INTEGER,
        messageAutoDeleteTime INTEGER,
        nickName TEXT,
        isActiveNickname INTEGER
      )
    ''');
    await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    await db.execute('''
  CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    _id TEXT,
    message_id TEXT UNIQUE,
    chat_id TEXT,
    sender TEXT,
    content TEXT,
    type TEXT,
    is_deleted INTEGER DEFAULT 0,
    is_read INTEGER DEFAULT 0,
    is_sent INTEGER DEFAULT 0,
    is_edited INTEGER DEFAULT 0,
    is_pinned INTEGER DEFAULT 0,
    created_at TEXT,
    local_path TEXT,
    upload_status TEXT DEFAULT 'sent', -- 'pending', 'uploading', 'sent', 'failed'
    upload_progress REAL DEFAULT 0,
    file_ids TEXT, -- JSON array
    files TEXT, -- JSON array of FileElement
    reply_to TEXT, -- JSON of MessageModel
    reactions TEXT, -- JSON array
    system_message TEXT, -- JSON of SystemMessage
    disappearing_messages INTEGER,
    user_id TEXT, -- To handle multi-user scenario
    server_sync INTEGER DEFAULT 0, -- 0 = not synced, 1 = synced
    forwarded INTEGER
  )
''');

// Add index for faster queries
    await db.execute('CREATE INDEX idx_messages_chat_id ON messages(chat_id)');
    await db.execute('CREATE INDEX idx_messages_user_id ON messages(user_id)');
    await db.execute(
        'CREATE INDEX idx_messages_upload_status ON messages(upload_status)');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      print(
          "onUpgrade: oldVersion: $oldVersion newVersion: $newVersion ${oldVersion <= newVersion}");
      showMessage(
          "onUpgrade: oldVersion: $oldVersion newVersion: $newVersion ${oldVersion <= newVersion}");
      if (oldVersion < newVersion) {
        db.execute('ALTER TABLE login_data ADD COLUMN profilePrivacy TEXT;');
        db.execute('ALTER TABLE login_data ADD COLUMN isEmailVerify INTEGER;');
        db.execute('ALTER TABLE login_data ADD COLUMN isPhoneVerify INTEGER;');

        db.execute('ALTER TABLE messages ADD COLUMN _id TEXT;');

        db.execute('ALTER TABLE login_data ADD COLUMN chatId TEXT;');
        db.execute('ALTER TABLE login_data ADD COLUMN isBlocked INTEGER;');
        db.execute('ALTER TABLE login_data ADD COLUMN youBlocked INTEGER;');
        db.execute(
            'ALTER TABLE login_data ADD COLUMN messageAutoDeleteTime INTEGER;');
        // db.execute('ALTER TABLE login_data ADD COLUMN nickName TEXT;');
        // db.execute(
        //     'ALTER TABLE login_data ADD COLUMN isActiveNickname INTEGER;');

        db.execute('ALTER TABLE contacts ADD COLUMN chatId TEXT;');
        db.execute('ALTER TABLE contacts ADD COLUMN isBlocked INTEGER;');
        db.execute('ALTER TABLE contacts ADD COLUMN youBlocked INTEGER;');
        db.execute(
            'ALTER TABLE contacts ADD COLUMN messageAutoDeleteTime INTEGER;');
        db.execute('ALTER TABLE contacts ADD COLUMN nickName TEXT;');
        db.execute('ALTER TABLE contacts ADD COLUMN isActiveNickname INTEGER;');

        //messages table
        db.execute('ALTER TABLE messages ADD COLUMN forwarded INTEGER;');
      }
      if (oldVersion <= 4) {
        await db.execute('''
  CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    _id TEXT,
    message_id TEXT UNIQUE,
    chat_id TEXT,
    sender TEXT,
    content TEXT,
    type TEXT,
    is_deleted INTEGER DEFAULT 0,
    is_read INTEGER DEFAULT 0,
    is_sent INTEGER DEFAULT 0,
    is_edited INTEGER DEFAULT 0,
    is_pinned INTEGER DEFAULT 0,
    created_at TEXT,
    local_path TEXT,
    upload_status TEXT DEFAULT 'sent', -- 'pending', 'uploading', 'sent', 'failed'
    upload_progress REAL DEFAULT 0,
    file_ids TEXT, -- JSON array
    files TEXT, -- JSON array of FileElement
    reply_to TEXT, -- JSON of MessageModel
    reactions TEXT, -- JSON array
    system_message TEXT, -- JSON of SystemMessage
    disappearing_messages INTEGER,
    user_id TEXT, -- To handle multi-user scenario,
    server_sync INTEGER DEFAULT 0, -- 0 = not synced, 1 = synced
    forwarded INTEGER
  )
''');

// Add index for faster queries
        await db
            .execute('CREATE INDEX idx_messages_chat_id ON messages(chat_id)');
        await db
            .execute('CREATE INDEX idx_messages_user_id ON messages(user_id)');
        await db.execute(
            'CREATE INDEX idx_messages_upload_status ON messages(upload_status)');
      }
    } on Exception catch (e, st) {
      showMessage("Error in DatabaseHelper _onUpgrade $e $st");
    }
  }

  Future<void> ensureTablesExist() async {
    final db = await database;
    try {
      // Check if messages table exists
      final messagesTable = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='messages'");

      if (messagesTable.isEmpty) {
        // Recreate all tables if messages table is missing
        debugPrint('Messages table missing, recreating database schema');
        await _createDatabase(db, _databaseVersion);
      }
    } catch (e, st) {
      debugPrint('Error verifying tables: $e\n$st');
      // If verification fails, recreate the entire database
      await db.close();
      _database = null;
      await _initDatabase();
    }
  }

  // Save base URL to the database
  Future<void> saveBaseURL(String baseURL) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'base_url', 'value': baseURL},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve base URL from the database
  Future<String?> getBaseURL() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['base_url'],
    );
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  // Save token to the database
  Future<void> saveToken(
    String token,
  ) async {
    final db = await database;

    await db.insert(
      'settings',
      {
        'key': 'api_token',
        'value': token,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve token from the database
  Future<String?> getToken() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['api_token'],
    );
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  Future<void> saveRefreshToken(String token) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'refresh_token', 'value': token},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve token from the database
  Future<String?> getRefreshToken() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['refresh_token'],
    );
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  // Update base URL in the database
  Future<int> updateBaseURL(String newBaseURL) async {
    final db = await database;
    return await db.update(
      'settings',
      {'value': newBaseURL},
      where: 'key = ?',
      whereArgs: ['base_url'],
    );
  }

  // Update token in the database
  Future<int> updateToken(String newToken) async {
    final db = await database;
    return await db.update(
      'settings',
      {'value': newToken},
      where: 'key = ?',
      whereArgs: ['api_token'],
    );
  }

  // Save saveKeepLoggedIn to the database
  Future<void> saveKeepLoggedIn(
      bool value, String username, String password) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'keep_logged_in', 'value': value ? "true" : "false"},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (value) {
      await saveUserName(username);
      await savePassword(password);
    }
  }

  // Retrieve saveKeepLoggedIn from the database
  Future<bool> getKeepLoggedIn() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['keep_logged_in'],
    );
    return result.isNotEmpty
        ? (result.first['value'] as String) == "true"
            ? true
            : false
        : false;
  }

  // Save username to the database
  Future<void> saveUserName(String username) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'username', 'value': username},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve username from the database
  Future<String> getUserName() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['username'],
    );
    return result.isNotEmpty ? result.first['value'] as String : "";
  }

  // Save password to the database
  Future<void> savePassword(String password) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'password', 'value': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve password from the database
  Future<String> getPassword() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['password'],
    );
    return result.isNotEmpty ? result.first['value'] as String : "";
  }

  // Insert LoginResponse into the database
  Future<int> insertLoginData(UserData user) async {
    final db = await database;
    var data;
    try {
      AppPreference.setPrivateKey(user.privateKey ?? "");
      AppPreference.setPublicKey(user.publicKey ?? "");
      await ensureTablesExist();
      data = user.toDbJson();
      showMessage("DB Insert ==> $data");

      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='login_data'");

      if (tables.isNotEmpty) {
        showMessage("Table 'login_data' does not exist.");
        await db.delete(
            'login_data'); // Return without deleting if table doesn't exist
      }

      int index = await db.insert('login_data', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      await AppPreference.setUserId(user.sId);
      return index;
    } catch (e, st) {
      showMessage('Error in insertLoginData ${e.toString()} $st');
    }
    return -1;
  }

  /// **Delete Contact by Phone Number**
  Future<void> deleteContactByPhone(String phone) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'phone = ?',
      whereArgs: [phone],
    );
  }

  // Update LoginResponse in the database
  Future<int> updateLoginData(UserData user) async {
    final db = await database;

    showMessage("Upate user ==> ${user.toDbJson()}");

    final data = user.toDbJson();

    // Assuming we're updating the first row (you can use WHERE clause if needed)
    return await db.update(
      'login_data',
      data,
      where: 'id = ?', // Assuming there's only one row with id = 1
      whereArgs: [1], // Adjust the ID based on your logic
    );
  }

  // Future<ContactUser?> getContactByPhone(String phone) async {
  //   final db = await database;
  //   final maps = await db.query(
  //     'contacts',
  //     where: 'phone = ?',
  //     whereArgs: [phone],
  //   );
  //   if (maps.isNotEmpty) {
  //     return ContactUser.fromDbJson(maps.first);
  //   }
  //   return null;
  // }
  Future<ContactUser?> getContactByPhone(String phone, String email) async {
    final db = await database;
    String normalizedPhone =
        Utils.removeSpaceAndSpecialCharectorsFromString(phone);
    if (normalizedPhone.isEmpty && email.isNotEmpty) {
      final List<Map<String, dynamic>> maps = await db.query(
        'contacts',
        where: 'email LIKE ?',
        whereArgs: ['%$email'],
      );

      if (maps.isNotEmpty) {
        log("getContactByPhone $email  ${maps.first['email']}  ${maps.first['name']}");
        return ContactUser.fromDbJson(maps.first);
      }
    } else {
      final List<Map<String, dynamic>> maps = await db.query(
        'contacts',
        where: 'phone LIKE ?',
        whereArgs: ['%$normalizedPhone'],
      );

      if (maps.isNotEmpty) {
        log("getContactByPhone $normalizedPhone  ${maps.first['phone']}  ${maps.first['name']}");
        return ContactUser.fromDbJson(maps.first);
      }
    }
    return null;
  }

  Future<bool> getContactById(String id) async {
    final db = await database;
    if (id.isEmpty) return false;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: '_id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      log("getContactId ${maps.first['phone']}  ${maps.first['name']}");
      return true;
    }
    return false;
  }

  // Future<void> insertContact(ContactUser contact) async {
  //   final db = await database;
  //   await db.insert('contacts', contact.toDbJson(),
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  // }

//   Future<void> insertContact(ContactUser contact) async {
//   final db = await database;

//   // Find an existing contact where the phone number ends with the new contact's phone
//   ContactUser? existingContact = await db.query(
//     'contacts',
//     where: 'phone LIKE ?',
//     whereArgs: ['%${contact.phone}'], // Search for numbers ending with the given phone
//   ).then((result) => result.isNotEmpty ? ContactUser.fromDbJson(result.first) : null);

//   if (existingContact != null) {
//     // Update the existing contact if found
//     await db.update(
//       'contacts',
//       contact.toDbJson(),
//       where: 'phone = ?', // Update the matching contact
//       whereArgs: [existingContact.phone],
//     );
//   } else {
//     // Otherwise, insert as a new contact
//     await db.insert('contacts', contact.toDbJson(),
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }
// }
  Future<void> insertContact(ContactUser contact) async {
    if ((contact.phone ?? '').isEmpty) return;
    final db = await database;
    await db.insert('contacts', contact.toDbJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateLocalContact(String phone, String name) async {
    final db = await database;
    await db.update('contacts', {'name': name},
        where: 'phone LIKE ?', whereArgs: ['%${phone}']);
  }

  Future<void> updateContact(ContactUser contact) async {
    final db = await database;
    int update = await db.update(
      'contacts',
      contact.toDbJson(),
      where: 'phone LIKE ?',
      whereArgs: [
        '%${contact.phone}'
      ], // Matches any number ending with contact.phone
    );
    if (contact.phone == "7573060530") {
      showMessage("updateContact $update");
    }
  }

  Future<List<ContactUser>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts',
        orderBy:
            "(CASE WHEN lastSeen IS NULL OR lastSeen = '' THEN 1 ELSE 0 END), lastSeen DESC, name ASC");

    return List.generate(maps.length, (i) => ContactUser.fromDbJson(maps[i]));
  }

  Future<List<ContactUser>> searchContacts(
      String searchQuery, int limit, int offset) async {
    final db = await database;
    // final result = await db.query(
    //   'contacts',
    //   where: 'name LIKE ?',
    //   orderBy:
    //       "(CASE WHEN lastSeen IS NULL OR lastSeen = '' THEN 1 ELSE 0 END), lastSeen DESC, name ASC",
    //   whereArgs: ['%$searchQuery%'],
    //   limit: limit,
    // );
    final result = await db.query(
      'contacts',
      where: '''
      (name IS NOT NULL AND name LIKE ?) OR 
      (userName IS NOT NULL AND userName LIKE ?) OR 
      (email IS NOT NULL AND email LIKE ?) OR 
      (phone IS NOT NULL AND phone LIKE ?)
    ''',
      whereArgs: [
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%'
      ],
      orderBy: '''
      (CASE WHEN lastSeen IS NULL OR lastSeen = '' THEN 1 ELSE 0 END), 
      lastSeen DESC, 
      name ASC
    ''',
      // limit: limit,
      // offset: offset,
    );
    return result.map((c) => ContactUser.fromDbJson(c)).toList();
  }

  // Retrieve LoginResponse from the database
  Future<UserData?> getLoginData() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('login_data');

    if (result.isNotEmpty) {
      final row = result.first;
      return UserData.fromDbJson(row);
      // return _convertFromMap(row);
    }
    return null;
  }

  // Future<List<ContactUser>> getAllContacts() async {
  //   final db = await database;

  //   final dbContact = await db.query('contacts');

  //   return List.from(dbContact
  //       .map(
  //         (e) => ContactUser.fromDbJson(e),
  //       )
  //       .toList());
  // }

  // Delete LoginResponse from the database
  Future<int> deleteLoginData() async {
    final db = await database;
    // Check if contacts table exists
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='contacts'");

    if (tables.isNotEmpty) {
      showMessage("Table 'contacts' does not exist.");
      await db
          .delete('contacts'); // Return without deleting if table doesn't exist
    }
    final messagesTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='messages'");

    if (messagesTable.isNotEmpty) {
      showMessage("Table 'contacts' does not exist.");
      await db
          .delete('messages'); // Return without deleting if table doesn't exist
    }
    return await db.delete('login_data');
  }

  Future<int> deleteAllContacts() async {
    final db = await database;
    return await db.delete('contacts');
  }

  // Helper method to convert LoginResponse to a Map for SQLite
  Map<String, dynamic> _convertToMap(LoginResponse loginResponse) {
    return {
      'access_token': loginResponse.accessToken,
      'refresh_token': loginResponse.refreshToken,
      'menu_options': jsonEncode(
          loginResponse.menuOptions.map((option) => option.toJson()).toList()),
      'profile': jsonEncode(loginResponse.profile.toJson()),
    };
  }

  // Helper method to convert SQLite row back to LoginResponse
}

class AppPreference {
  static late SharedPreferences _prefs;

  static Future<void> initMySharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> clearSharedPreferences() async {
    await _prefs.clear();

    return;
  }

  static Future setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static Future setAgoraAppId(String value) async {
    await _prefs.setString(LocalDbConstants.agoraAppId, value);
  }

  static Future setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  static String getString(String key) {
    final String? value = _prefs.getString(key);
    return value ?? "";
  }

  static List<String> getStringList(String key) {
    final List<String>? value = _prefs.getStringList(key);
    return value ?? [];
  }

  static Future setBoolean(String key, {required bool value}) async {
    await _prefs.setBool(key, value);
  }

  static bool getBoolean(String key) {
    final bool? value = _prefs.getBool(key);
    return value ?? true;
  }

  static bool isContactPermissionGrant() {
    final bool? value = _prefs.getBool(LocalDbConstants.contactPermission);
    return value ?? false;
  }

  static Future setLong(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double getLong(String key) {
    final double? value = _prefs.getDouble(key);
    return value ?? 0.0;
  }

  static Future setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int getInt(String key) {
    final int? value = _prefs.getInt(key);
    return value ?? 0;
  }

  static String getAgoraAppId() {
    return _prefs.getString(LocalDbConstants.agoraAppId) ?? "";
  }

  static Future setPrivateKey(String value) async {
    await _prefs.setString(LocalDbConstants.privateKey, value);
  }

  static Future setPublicKey(String value) async {
    await _prefs.setString(LocalDbConstants.publicKey, value);
  }

  static String getPrivateKey() {
    final String? value = _prefs.getString(LocalDbConstants.privateKey);
    return value ?? "";
  }

  static String getPublicKey() {
    final String? value = _prefs.getString(LocalDbConstants.publicKey);
    return value ?? "";
  }

  static Future setLanguage(String value) async {
    showMessage("Set language $value");
    await _prefs.setString(LocalDbConstants.languageKey, value);
  }

  static String getLanguage() {
    final String? value = _prefs.getString(LocalDbConstants.languageKey);

    if (value != null) {
      return value;
    }

    // Get system language
    String systemLocale = Platform.localeName;

    // Default to Czech if system locale is Czech, otherwise English
    return systemLocale.startsWith("cs") ? "cs" : "en";
  }
  // static Future setUserToken(String token) async {
  //   await _prefs.setString(Constants.keyToken, token);
  // }

  // static Future setUserAccessToken(String token) async {
  //   await _prefs.setString(LocalDbConstants.accessToken, token);
  // }

  // static String getUserAccessToken() {
  //   return _prefs.getString(LocalDbConstants.accessToken) ?? '';
  // }

  static Future setUserRefreshToken(String token) async {
    await _prefs.setString(LocalDbConstants.refreshToken, token);
  }

  static String getUserRefreshToken() {
    return _prefs.getString(LocalDbConstants.refreshToken) ?? '';
  }

  static String getFCMToken() {
    return _prefs.getString(LocalDbConstants.firebaseToken) ?? '';
  }

  // static Future setUser(UserData user) async {
  //   // user?.refreshToken = "";
  //   await _prefs.setString(Constants.keyUser, jsonEncode(user));
  // }

  // static String? getUserToken() {
  //   return _prefs.get(Constants.keyToken) as String?;
  // }

  // static Future<void> saveOfflineMessage(String messageId, int index) async {
  //   //  final prefs = await SharedPreferences.getInstance();
  //   List<String> getSaveOfflineMessageList = await getSaveOfflineMessage(index);
  //   if (!getSaveOfflineMessageList.contains(messageId)) {
  //     getSaveOfflineMessageList.add(messageId);
  //   } else {
  //     showMessage("saveOfflineMessage currently is added messageId");
  //   }
  //   await _prefs.setStringList('OfflineMessageList', getSaveOfflineMessageList);
  // }

  // static Future<void> setAllOfflineMessage(List<String> messageIds) async {
  //   await _prefs.setStringList('OfflineMessageList', messageIds);
  // }

  // static Future<List<String>> getSaveOfflineMessage(int index) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> list = prefs.getStringList('OfflineMessageList') ?? [];
  //   showMessage("getSaveOfflineMessage $index called $list");
  //   return list;
  // }

  // static bool isUserLogin() {
  //   final String? getToken = getUserToken();
  //   return getToken != null && getToken.isNotEmpty;
  // }

  // static Future setLanguage(String value) async {
  //   showMessage("Set language $value");
  //   await _prefs.setString(Constants.languageKey, value);
  // }

  // static String getLanguage() {
  //   final String? value = _prefs.getString(Constants.languageKey);
  //   return value ?? (Platform.localeName == "fr_FR" ? "fr" : "en");
  // }

  static Future setPhoneVerify() async {
    showMessage(
        "shouldShowVerificationPromptForPhone setPhoneVerify ${DateTime.now().toIso8601String()}");
    final currentDate = DateTime.now().toIso8601String();
    await _prefs.setString(LocalDbConstants.phoneVerify, currentDate);
  }

  static Future setEmailVerify() async {
    final currentDate = DateTime.now().toIso8601String();
    showMessage(
        "shouldShowVerificationPromptFor setEmailVerify ${currentDate}");
    await _prefs.setString(LocalDbConstants.emailVerify, currentDate);
  }

  static bool shouldShowVerificationPromptForPhone() {
    final savedDateString = _prefs.getString(LocalDbConstants.phoneVerify);

    if (savedDateString == null) {
      // No saved date, show prompt by default
      return true;
    }

    final savedDate = DateTime.parse(savedDateString).toLocal();
    final currentDate = DateTime.now();

    // Calculate the difference in days
    final difference = currentDate.difference(savedDate).inDays;
    showMessage(
        "shouldShowVerificationPromptForPhone $difference ${savedDateString}");
    // Show prompt if 30 days have passed
    return difference >= 30;
  }

  static bool shouldShowVerificationPromptForEmail() {
    final savedDateString = _prefs.getString(LocalDbConstants.emailVerify);

    if (savedDateString == null) {
      // No saved date, show prompt by default
      return true;
    }

    final savedDate = DateTime.parse(savedDateString).toLocal();
    final currentDate = DateTime.now();

    // Calculate the difference in days
    final difference = currentDate.difference(savedDate).inDays;
    showMessage(
        "shouldShowVerificationPromptForEmail $difference ${savedDateString}");
    // Show prompt if 30 days have passed
    return difference >= 30;
  }

  static Future<void> setUserId(String? sId) async {
    await _prefs.setString(LocalDbConstants.currentUserId, sId ?? "");
  }

  static String getCurrentUserId() {
    final String? value = _prefs.getString(LocalDbConstants.currentUserId);
    return value ?? "";
  }
}

final class LocalDbConstants {
  static final String agoraAppId = 'agora_app_id';
  static final String publicKey = '_publicKey';
  static final String privateKey = '_privateKey';
  static final String firebaseToken = 'fcmToken';
  static final String languageKey = 'LanguageKey';
  static final String phoneVerify = 'phoneVerify';
  static final String emailVerify = 'emailVerify';
  static final String currentUserId = 'currentUserId';
  static final String contactPermission = 'contactPermission';
  static final String accessToken = 'accessToken';
  static final String refreshToken = 'refreshToken';
}



// ,
//         // chatId TEXT,
//         // isBlocked INTEGER,
//         // youBlocked INTEGER