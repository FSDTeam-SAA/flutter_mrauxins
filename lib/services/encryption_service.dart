import 'dart:convert';
import 'dart:developer';

import 'package:basic_utils/basic_utils.dart';
import 'package:convert/convert.dart'; // Provides base16 decoding
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:two_one_two_messenger/database/local_db.dart';

class EncryptionHelper {
  static final EncryptionHelper _instance = EncryptionHelper._internal();

  factory EncryptionHelper() {
    return _instance;
  }

  EncryptionHelper._internal();

  /// Decrypts the AES key using the user's RSA private key
  String decryptAESKey(String encryptedAESKeyHex) {
    try {
      // Retrieve private key from secure storage
      String storedPrivateKey = AppPreference.getPrivateKey();
      log("Stored Private Key === $storedPrivateKey");

      if (storedPrivateKey.isEmpty) {
        throw Exception("Private key not loaded");
      }

      // Parse the private key properly
      final rsaPrivateKey = _parseRSAPrivateKey(storedPrivateKey);

      // Decode the encrypted AES key from hex
      final encryptedBytes = Uint8List.fromList(hex.decode(encryptedAESKeyHex));

      // Decrypt AES key using RSA-OAEP
      final decryptor = OAEPEncoding(RSAEngine())
        ..init(false, PrivateKeyParameter<RSAPrivateKey>(rsaPrivateKey));

      final decryptedBytes = decryptor.process(encryptedBytes);

      log("Decrypted AES Key (Raw) === ${hex.encode(decryptedBytes)}");

      return utf8.decode(decryptedBytes).trim();
    } catch (e, st) {
      throw Exception("Failed to decrypt AES Key: $e\n$st");
    }
  }

  /// Parses an RSA Private Key from a hex string
  RSAPrivateKey _parseRSAPrivateKey(String hexKey) {
    // Convert hex to bytes
    Uint8List keyBytes = Uint8List.fromList(hex.decode(hexKey));

    // Decode the private key from DER format
    final privateKey = CryptoUtils.rsaPrivateKeyFromDERBytes(keyBytes);

    return RSAPrivateKey(
      privateKey.modulus!,
      privateKey.privateExponent!,
      privateKey.p,
      privateKey.q,
    );
  }

  /// Encrypts a message using AES-GCM
  String encryptMessage(String message, String aesKey) {
    if (message.isEmpty) return "";
    final rawKeyBytes = Uint8List.fromList(utf8.encode(aesKey));
    if (rawKeyBytes.length < 32) {
      throw Exception(
          "Cannot encrypt message: conversation key is missing or invalid");
    }
    final keyBytes = rawKeyBytes.sublist(0, 32);
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromLength(16); // Generate IV dynamically

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    final encrypted = encrypter.encrypt(message, iv: iv);

    return jsonEncode({
      'cipher': encrypted.base64,
      'iv': iv.base64,
    });
  }

  /// Decrypts a message using AES-GCM
  String decryptMessage(String encryptedJson, String aesKey) {
    try {
      final Map<String, dynamic> data;

      // Try to parse as JSON
      try {
        data = jsonDecode(encryptedJson);
      } catch (e) {
        // If JSON parsing fails, assume it's plain text
        return encryptedJson;
      }
      // Check if this is actually an encrypted message structure
      if (data['iv'] == null || data['cipher'] == null) {
        return encryptedJson; // Not properly structured encrypted message
      }
      final rawKeyBytes = Uint8List.fromList(utf8.encode(aesKey));
      if (rawKeyBytes.length < 32) {
        throw Exception(
            "Cannot decrypt message: conversation key is missing or invalid");
      }
      final keyBytes = rawKeyBytes.sublist(0, 32);
      final key = encrypt.Key(keyBytes);
      final iv = encrypt.IV.fromBase64(data['iv']);

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
      final decrypted = encrypter
          .decrypt(encrypt.Encrypted.fromBase64(data['cipher']), iv: iv);

      return decrypted;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint("Failed to decrypt message: $e $st");
      }
      return encryptedJson;
    }
  }
}
