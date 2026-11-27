# A sketch of the MediaSource contract

Kotlin-style pseudocode. This is a starting point for ADR-0003, not a finished
decision: adapt it to the chosen stack but keep the meaning.

## Model

```kotlin
// The identifier of a connected source: "telegram:main", "s3:home-nas".
@JvmInline value class SourceId(val value: String)

// A collection = a book or an album. For Telegram it is a channel, for S3 a prefix (a "folder").
data class Collection(
    val ref: CollectionRef,          // a reference opaque to the core, only the source understands it
    val title: String,
    val coverRef: ArtworkRef?,
    val trackCountHint: Int?,
)

data class Track(
    val ref: TrackRef,               // an opaque reference for reopening
    val key: TrackKey,               // a STABLE key for positions and history (see ADR-0004)
    val title: String,
    val order: Int,                  // the order inside the collection, computed by the source
    val durationMs: Long?,           // may be unknown until opened
    val sizeBytes: Long?,
    val mimeType: String?,
)

// A stable key: it must not depend on temporary ids, tokens or presigned links.
// Telegram: "tg:{chatId}:{messageId}:{remoteUniqueId}"; S3: "s3:{bucket}:{key}:{etag}".
@JvmInline value class TrackKey(val value: String)
```

## Contract

```kotlin
interface MediaSource {
    val id: SourceId
    val capabilities: SourceCapabilities

    /** The connection state: authorization needed, connected, error. */
    val state: Flow<SourceState>

    suspend fun listCollections(): List<Collection>
    suspend fun listTracks(collection: CollectionRef): List<Track>

    /**
     * Open the byte stream of a track starting at offset.
     * Must support an arbitrary offset (seeking without downloading the whole file)
     * if capabilities.seekable == true.
     */
    suspend fun open(track: TrackRef, offset: Long): MediaStream
}

interface MediaStream : Closeable {
    val totalSize: Long?             // null if unknown
    suspend fun read(buffer: ByteArray, off: Int, len: Int): Int   // -1 = end
}

data class SourceCapabilities(
    val seekable: Boolean,
    val supportsOfflineDownload: Boolean,
    val requiresInteractiveAuth: Boolean,   // Telegram: a code from SMS or the app; S3: no
)

sealed interface SourceState {
    data object Connected : SourceState
    data class NeedsAuth(val step: AuthStep) : SourceState   // the authorization steps are a separate sub-contract
    data class Unavailable(val reason: String, val retryAfterMs: Long?) : SourceState
}
```

## Questions ADR-0003 must close

1. **Authorization.** The interactive Telegram authorization (phone → code →
   2FA password) must not leak into the core as "the Telegram one". An option:
   a common sub-contract `AuthFlow` with form steps that the UI renders generically.
2. **Errors.** A single hierarchy: `NotFound`, `AuthRequired`,
   `RateLimited(retryAfter)`, `Network`, `Unknown`. The source translates its
   own errors (for example FLOOD_WAIT) into it.
3. **Track order.** Who determines it and how to override it (manual sorting later?).
4. **Changes in the source.** How the core learns that a chapter was added to a
   channel (is polling when the collection is opened enough for the MVP?).
5. **The link to the player.** The player gets the data through an adapter from
   `MediaStream` to the API of the chosen player (for example a custom
   `DataSource` in Media3). The adapter lives in `core-player` and knows only
   the contract.

## Check with three implementations

| Requirement | TDLib on the phone | S3 presigned | Our own server gateway |
|---|---|---|---|
| listCollections | channels filtered by a rule | prefixes | the gateway's HTTP API |
| open(offset) | downloadFile with an offset + reading a part of the file | HTTP Range | HTTP Range |
| TrackKey | chat+message+remoteUniqueId | bucket+key+etag | the same as for Telegram |
| auth | interactive | keys in the settings | the gateway token |

If a row cannot be filled in without a stretch, the contract has to change.
