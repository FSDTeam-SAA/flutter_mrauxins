import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:two_one_two_messenger/database/local_db.dart';

/// Shared across every message bubble on screen so `StackedReactions` (which
/// reads live from a `ReactionsController`) stays in sync without threading a
/// controller instance through every widget in the chat tree.
final ReactionsController chatReactionsController =
    ReactionsController(currentUserId: AppPreference.getCurrentUserId());

/// The backend only tracks per-user reaction attribution server-side; the
/// wire format (and thus [MessageModel.reactions]) is a flat, unattributed
/// list of emoji. These placeholder [Reaction]s exist only so `StackedReactions`
/// can render the current emoji set - `userId` is never matched against the
/// real current user, so `hasUserReacted`/toggle-off never fires, which is
/// fine since the backend has no "remove reaction" capability either.
List<Reaction> synthesizeReactions(List<String>? emojis) {
  if (emojis == null || emojis.isEmpty) return [];
  final now = DateTime.now();
  return [
    for (var i = 0; i < emojis.length; i++)
      Reaction(emoji: emojis[i], userId: 'unattributed-$i', timestamp: now),
  ];
}
