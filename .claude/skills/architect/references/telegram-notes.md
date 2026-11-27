# Telegram notes for the architect

Check the details against the current TDLib documentation
(core.telegram.org/tdlib): the API changes, these are only pointers.

## Why TDLib and not the Bot API
- Without a self-hosted Bot API server the Bot API downloads files only up to
  20 MB; audiobook chapters are often larger.
- A bot sees only the chats it was added to; it is more convenient for the user
  to work with their own channels directly.
- TDLib works on behalf of the user (MTProto) and supports partial downloads
  and a cache. The downside: it needs interactive authorization and our own
  `api_id`/`api_hash` from my.telegram.org.

## Secrets and data
- `api_id` and `api_hash` are the app's secrets. Not in git: local.properties,
  environment variables or a file from .gitignore. For CI, the CI secrets.
- The TDLib database and file directory live in the app's internal storage.
  The encryption key of the TDLib database is kept in the system key store
  (Keystore/Keychain).
- TDLib logs are verbose by default and may contain too much. In release use
  the minimum level.

## Reading channels
- The chat list → the "channels" filter (the rule for which channels count as
  books is a CPO/architect decision: all, a Telegram folder, a title prefix,
  manual selection).
- Tracks: search the chat messages with the audio filter (TDLib has an audio
  filter for chat search). MP3s sent "as a file" may arrive as a document, not
  as audio; account for both types.
- Order: by message id (the order of publication). The file name and tags are
  the fallback.

## Streaming and seeking
- TDLib can download a part of a file from a given offset and read the part
  already downloaded. The `MediaStream` adapter requests the needed range and
  waits for the file state update.
- A file identifier in TDLib is local to the session. For `TrackKey` use
  chatId + messageId + the remote unique id of the file.
- The TDLib cache grows. A cleanup policy is needed (a size limit, never delete
  what was downloaded "for offline").

## Limits and risks
- FLOOD_WAIT: the server asks to wait N seconds. Translate it into
  `RateLimited(retryAfter)`, do not hammer with retries. Do not make mass
  requests at startup (for example, do not load all messages of all channels at once).
- The Telegram API terms of use: do not abuse, do not pose as the official
  client. For personal use the risk is low, but the PRD lists it under "Risks".

## Testing
- Unit and integration tests above `source-api` run only on `source-fake`.
- Contract tests on `source-telegram` are a separate set, run by hand with a
  test account and a test channel. The sign-in data comes only from the environment.
- For UI development `source-fake` with a couple of local MP3s in the test
  assets is enough.
