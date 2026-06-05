import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:audio_service/audio_service.dart';

class EcodiAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {

  final AudioPlayer _player = AudioPlayer();

  EcodiAudioHandler() {
    _init();
  }

  // ─── Initialisation ───────────────────────────────────
  void _init() {
    // Transmettre l'état du player à audio_service
    _player.playbackEventStream.listen(_broadcastState);

    // Quand un audio se termine → passer au suivant
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  // ─── Charger un audio ─────────────────────────────────
  Future<void> loadAudio({
    required String url,
    required String title,
    required String courseTitle,
    required String imageUrl,
    Duration? initialPosition,
  }) async {
    // Créer le MediaItem (métadonnées pour la notification)
    final mediaItem = MediaItem(
      id: url,
      title: title,
      album: courseTitle,
      artUri: Uri.parse(imageUrl),
    );

    // Informer audio_service du média en cours
    this.mediaItem.add(mediaItem);

    // Charger dans just_audio
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(url)),
      initialPosition: initialPosition,
    );
  }

  // ─── Contrôles de base ────────────────────────────────
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  // ─── Vitesse ──────────────────────────────────────────
  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  // ─── Suivant / Précédent ──────────────────────────────
  @override
  Future<void> skipToNext() async {
    final currentIndex = queue.value.indexWhere(
      (item) => item.id == mediaItem.value?.id,
    );

    if (currentIndex < queue.value.length - 1) {
      final next = queue.value[currentIndex + 1];
      await skipToQueueItem(currentIndex + 1);
      await loadAudio(
        url: next.id,
        title: next.title,
        courseTitle: next.album ?? '',
        imageUrl: next.artUri?.toString() ?? '',
      );
      await play();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // Si > 3 secondes → retour au début
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    final currentIndex = queue.value.indexWhere(
      (item) => item.id == mediaItem.value?.id,
    );

    if (currentIndex > 0) {
      final prev = queue.value[currentIndex - 1];
      await skipToQueueItem(currentIndex - 1);
      await loadAudio(
        url: prev.id,
        title: prev.title,
        courseTitle: prev.album ?? '',
        imageUrl: prev.artUri?.toString() ?? '',
      );
      await play();
    }
  }

  // ─── Avance / Recul 15 secondes ───────────────────────
  Future<void> seekForward15() async {
    final newPos = _player.position + const Duration(seconds: 15);
    final duration = _player.duration ?? Duration.zero;
    await seek(newPos > duration ? duration : newPos);
  }

  Future<void> seekBackward15() async {
    final newPos = _player.position - const Duration(seconds: 15);
    await seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  // ─── Streams publics ─────────────────────────────────
Stream<Duration> get positionStream => _player.positionStream;

Stream<Duration?> get durationStream => _player.durationStream;

Stream<just_audio.PlayerState> get playerStateStream =>
    _player.playerStateStream;

Duration get position => _player.position;

Duration? get duration => _player.duration;

bool get playing => _player.playing;

  // ─── Diffuser l'état vers audio_service ──────────────
  void _broadcastState(PlaybackEvent event) {
    final isPlaying = _player.playing;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        isPlaying ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (_player.processingState) {
        ProcessingState.idle     => AudioProcessingState.idle,
        ProcessingState.loading  => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready    => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: isPlaying,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
  }

  // ─── Charger la playlist complète ─────────────────────
  Future<void> loadQueue(List<MediaItem> items) async {
    queue.add(items);
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
  }
}