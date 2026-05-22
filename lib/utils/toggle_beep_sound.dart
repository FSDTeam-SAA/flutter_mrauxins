import 'package:just_audio/just_audio.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class ToggleSound {
  static AudioPlayer? player;

  static Future<void> callRingEnable() async {
    try {
      player ??= AudioPlayer();
      showMessage("ring step ------- 1");
      await player!.setAsset(SoundAssets.bellStandardCall);
      showMessage("ring step ------- 2");
      await player!.setLoopMode(LoopMode.one);
      showMessage("ring step ------- 3");
      await player!.play();
      showMessage("ring step ------- 4");
    } catch (e, st) {
      showMessage('Error enabling call ring: $e, $st');
    }
  }

  static Future<void> callRingDisable() async {
    try {
      if (player != null) {
        await player!.stop();
        await player!.dispose();
        player = null; // Reset the player
      }
    } catch (e) {
      showMessage('Error disabling call ring: $e');
    }
  }

  static Future<void> sendBeep() async {
    try {
      final tempPlayer = AudioPlayer(); // Use a temporary player for beep
      await tempPlayer.setAsset(SoundAssets.sendBeep);
      await tempPlayer.play();
      await tempPlayer.dispose();
    } catch (e) {
      showMessage('Error playing send beep sound: $e');
    }
  }
}
