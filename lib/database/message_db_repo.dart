import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/services/encryption_service.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class MessageRepository {
  final DatabaseHelper dbHelper;

  MessageRepository(this.dbHelper);

  // Helper method to get database instance
  Future<Database> get _db async {
    final db = await dbHelper.database;
    await dbHelper.ensureTablesExist();
    return db;
  }

  // Convert MessageModel to map for database
  Map<String, dynamic> _messageToMap(MessageModel message, String userId) {
    return {
      '_id': message.id,
      'message_id': message.messageId,
      'chat_id': message.chatId,
      'sender': jsonEncode(message.sender?.toJson()),
      'content': message.content,
      'type': message.type,
      'is_deleted': message.isDeleted == true ? 1 : 0,
      'is_read': message.isRead == true ? 1 : 0,
      'is_sent': message.isSent == true ? 1 : 0,
      'is_edited': message.isEditedMessage == true ? 1 : 0,
      'is_pinned': message.pinned == true ? 1 : 0,
      'created_at': message.createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'local_path': message.localPath,
      'upload_status': _uploadStatusToString(message.uploadStatus),
      'upload_progress': message.uploadProgress,
      'file_ids': jsonEncode(message.fileIds ?? []),
      'files':
          jsonEncode(message.files?.map((f) => f.toDbJson()).toList() ?? []),
      'reply_to': message.replyTo != null
          ? jsonEncode(message.replyTo!.toJson())
          : null,
      'reactions': jsonEncode(message.reactions ?? []),
      'system_message': message.systemMessage != null
          ? jsonEncode(message.systemMessage!.toJson())
          : null,
      'disappearing_messages': message.disAppearingMessages,
      'user_id': userId,
      'server_sync': 0, // Default to not synced
      'forwarded': (message.forwarded ?? false) ? 1 : 0
    };
  }

  // Convert database map to MessageModel
  MessageModel _mapToMessage(Map<String, dynamic> map, String aesKey) {
    String decryptedContent = "";
    // String  decryptedContent = map['content'] ?? "";
    if (aesKey.isEmpty) {
      decryptedContent = map['content'] ?? "";
    } else if (((map['content'] as String?) ?? "").isNotEmpty) {
      final encryptionService = EncryptionHelper();
      showMessage("_mapToMessage ${aesKey} == ${map['content']}");
      // decryptedAESKey = encryptionService.decryptAESKey(
      //   aesKey,
      // );

      decryptedContent =
          encryptionService.decryptMessage(map['content'], aesKey);
    }
    return MessageModel(
        chatId: map['chat_id'],
        sender: map['sender'] != null
            ? Sender.fromJson(jsonDecode(map['sender']))
            : null,
        content: decryptedContent,
        type: map['type'],
        isDeleted: map['is_deleted'] == 1,
        isRead: map['is_read'] == 1,
        isSent: map['is_sent'] == 1,
        isEditedMessage: map['is_edited'] == 1,
        pinned: map['is_pinned'] == 1,
        id: map['_id'].toString(),
        messageId: map['message_id'],
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : DateTime.now(),
        localPath: map['local_path'],
        uploadStatus: _stringToUploadStatus(map['upload_status']),
        uploadProgress: map['upload_progress'],
        fileIds: map['file_ids'] != null
            ? List<String>.from(jsonDecode(map['file_ids']))
            : null,
        files: map['files'] != null
            ? List<FileElement>.from(
                jsonDecode(map['files']).map((x) => FileElement.fromJson(x)))
            : null,
        replyTo: map['reply_to'] != null
            ? MessageModel.fromJson(jsonDecode(map['reply_to']), '')
            : null,
        reactions: map['reactions'] != null
            ? List<String>.from(jsonDecode(map['reactions']))
            : null,
        systemMessage: map['system_message'] != null
            ? SystemMessage.fromJson(jsonDecode(map['system_message']))
            : null,
        disAppearingMessages: map['disappearing_messages'],
        forwarded: map['forwarded'] == 1 ? true : false);
  }

  String _uploadStatusToString(MessageUploadStatus? status) {
    return status?.name ?? 'sent';
  }

  MessageUploadStatus _stringToUploadStatus(String status) {
    switch (status) {
      case 'pending':
        return MessageUploadStatus.pending;
      case 'uploading':
        return MessageUploadStatus.uploading;
      case 'sent':
        return MessageUploadStatus.sent;
      case 'failed':
        return MessageUploadStatus.failed;
      default:
        return MessageUploadStatus.sent;
    }
  }

  // Insert or update a message
  Future<int> saveMessage(MessageModel message, String userId) async {
    final db = await _db;
    try {
      return await db.insert(
        'messages',
        _messageToMap(message, userId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving message: $e');
      rethrow;
    }
  }

  // Get messages for a chat with pagination

  Future<List<MessageModel>> getMessages({
    required String chatId,
    required String userId,
    required String aesKey,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _db;
    try {
      print("getMessages==> $offset $limit");
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'chat_id = ? AND user_id = ?',
        whereArgs: [chatId, userId],
        orderBy: 'created_at DESC, id DESC', // Ensure consistent ordering
        limit: limit,
        offset: offset,
      );
      return maps
          .map(
            (e) => _mapToMessage(e, aesKey),
          )
          .toList();
    } catch (e) {
      print('Error getting messages: $e');
      rethrow;
    }
  }

  // Get pending uploads for a user
  Future<List<MessageModel>> getPendingUploads({
    required String chatId,
    required String userId,
    required String aesKey,
  }) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'upload_status IN (?, ?, ?) AND chat_id = ? AND user_id = ?',
        whereArgs: ['pending', 'failed', 'uploading', chatId, userId],
        orderBy: 'created_at ASC',
      );
      return maps
          .map(
            (e) => _mapToMessage(e, aesKey),
          )
          .toList();
    } catch (e) {
      print('Error getting pending uploads: $e');
      rethrow;
    }
  }

  // Update message upload status
  Future<void> updateUploadStatus({
    required String messageId,
    required MessageUploadStatus status,
    double? progress,
    String? userId,
  }) async {
    final db = await _db;
    try {
      await db.update(
        'messages',
        {
          'upload_status': _uploadStatusToString(status),
          if (progress != null) 'upload_progress': progress,
          if (status == MessageUploadStatus.sent) 'server_sync': 1,
        },
        where: 'message_id = ? AND user_id = ?',
        whereArgs: [messageId, userId],
      );
    } catch (e) {
      print('Error updating upload status: $e');
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatId,
    required List<String> messageIds,
    required String userId,
  }) async {
    final db = await _db;
    try {
      await db.update(
        'messages',
        {'is_read': 1},
        where:
            'chat_id = ? AND message_id IN (${List.filled(messageIds.length, '?').join(',')} AND user_id = ?',
        whereArgs: [
          ...[chatId],
          ...messageIds,
          userId
        ],
      );
    } catch (e) {
      print('Error marking messages as read: $e');
      rethrow;
    }
  }

  // Delete a message
  Future<void> deleteMessage({
    required String messageId,
    // required String userId,
    bool deleteForEveryone = true,
  }) async {
    final db = await _db;
    try {
      if (deleteForEveryone) {
        await db.delete(
          'messages',
          where: 'message_id = ?',
          // where: 'message_id = ? AND user_id = ?',
          whereArgs: [
            messageId,
          ],
        );
      } else {
        await db.update(
          'messages',
          {'is_deleted': 1},
          where: 'message_id = ?',
          // where: 'message_id = ? AND user_id = ?',
          whereArgs: [
            messageId,
          ],
        );
      }
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  // Clear all messages for a chat
  Future<void> clearChat({
    required String chatId,
    // required String userId,
  }) async {
    final db = await _db;
    try {
      await db.delete(
        'messages',
        where: 'chat_id = ?',
        // where: 'chat_id = ? AND user_id = ?',
        whereArgs: [
          chatId,
        ],
      );
    } catch (e) {
      print('Error clearing chat: $e');
      // rethrow;
    }
  }

  // Clear all messages for current user (on logout)
  Future<void> clearAllMessages(String userId) async {
    final db = await _db;
    try {
      await db.delete(
        'messages',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error clearing all messages: $e');
      rethrow;
    }
  }

  // Search messages
  Future<List<MessageModel>> searchMessages({
    required String query,
    required String chatId,
    required String userId,
    required String aesKey,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'chat_id = ? AND user_id = ? AND content LIKE ?',
        whereArgs: [chatId, userId, '%$query%'],
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      return maps
          .map(
            (e) => _mapToMessage(e, aesKey),
          )
          .toList();
    } catch (e) {
      print('Error searching messages: $e');
      rethrow;
    }
  }

  // Get pinned messages for a chat
  Future<List<MessageModel>> getPinnedMessages(
      {required String chatId,
      required String userId,
      required String aesKey}) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'chat_id = ? AND user_id = ? AND is_pinned = 1',
        whereArgs: [chatId, userId],
        orderBy: 'created_at DESC',
      );
      return maps
          .map(
            (e) => _mapToMessage(e, aesKey),
          )
          .toList();
    } catch (e) {
      print('Error getting pinned messages: $e');
      rethrow;
    }
  }

  // Update message content (for editing)
  Future<void> updateMessageContent({
    required String messageId,
    required String newContent,
    required String userId,
  }) async {
    final db = await _db;
    try {
      await db.update(
        'messages',
        {
          'content': newContent,
          'is_edited': 1,
        },
        where: 'message_id = ? AND user_id = ?',
        whereArgs: [messageId, userId],
      );
    } catch (e) {
      print('Error updating message content: $e');
      rethrow;
    }
  }

  // Add reaction to a message
  Future<void> addReaction({
    required String messageId,
    required List<String> reactions,
    required String userId,
  }) async {
    final db = await _db;
    try {
      // First get current reactions
      // final message = await db.query(
      //   'messages',
      //   where: 'message_id = ? AND user_id = ?',
      //   whereArgs: [messageId, userId],
      //   limit: 1,
      // );

      // if (message.isNotEmpty) {
      //   List<String> reactions = [];
      //   if (message.first['reactions'] != null) {
      //     reactions = List<String>.from(
      //         jsonDecode(message.first['reactions'].toString()));
      //   }
      //   reactions.add(reaction);

      //   await db.update(
      //     'messages',
      //     {
      //       'reactions': jsonEncode(reactions),
      //     },
      //     where: 'message_id = ? AND user_id = ?',
      //     whereArgs: [messageId, userId],
      //   );
      // }
      await db.update(
        'messages',
        {
          'reactions': jsonEncode(reactions),
        },
        where: 'message_id = ? AND user_id = ?',
        whereArgs: [messageId, userId],
      );
    } catch (e) {
      print('Error adding reaction: $e');
      rethrow;
    }
  }

  // Toggle pin status of a message
  Future<void> togglePinMessage({
    required String messageId,
    required bool pinned,
    required String userId,
  }) async {
    final db = await _db;
    try {
      await db.update(
        'messages',
        {
          'is_pinned': pinned ? 1 : 0,
        },
        where: 'message_id = ? AND user_id = ?',
        whereArgs: [messageId, userId],
      );
    } catch (e) {
      print('Error toggling pin status: $e');
      rethrow;
    }
  }

  // Get message by ID
  Future<MessageModel?> getMessageById(
      {required String messageId,
      required String userId,
      required String aesKey}) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'message_id = ? AND user_id = ?',
        whereArgs: [messageId, userId],
        limit: 1,
      );
      return maps.isNotEmpty ? _mapToMessage(maps.first, aesKey) : null;
    } catch (e) {
      print('Error getting message by ID: $e');
      rethrow;
    }
  }

  // Batch insert messages (for initial sync)
  Future<void> batchInsertMessages({
    required List<MessageModel> messages,
    required String userId,
  }) async {
    final db = await _db;
    final batch = db.batch();
    try {
      for (final message in messages) {
        batch.insert(
          'messages',
          _messageToMap(message, userId),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print('Error in batch insert messages: $e');
      rethrow;
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String newContent,
    required String chatId,
  }) async {
    final db = await _db;
    try {
      await db.update(
        'messages',
        {
          'content': newContent,
          'is_edited': 1,
        },
        where: 'message_id = ? AND chat_id = ?',
        whereArgs: [messageId, chatId],
      );
    } catch (e) {
      print('Error editing message: $e');
      rethrow;
    }
  }
}
