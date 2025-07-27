class Sermon {
  final String id;
  final String title;
  final String speaker;
  final DateTime date;
  final String? audioUrl;
  final String? videoUrl;
  final String? transcript;
  final String? thumbnailUrl;
  final List<String> tags;
  final String series;
  final String biblePassage;

  Sermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.date,
    this.audioUrl,
    this.videoUrl,
    this.transcript,
    this.thumbnailUrl,
    this.tags = const [],
    required this.series,
    required this.biblePassage,
  });

  Sermon copyWith({
    String? id,
    String? title,
    String? speaker,
    DateTime? date,
    String? audioUrl,
    String? videoUrl,
    String? transcript,
    String? thumbnailUrl,
    List<String>? tags,
    String? series,
    String? biblePassage,
  }) {
    return Sermon(
      id: id ?? this.id,
      title: title ?? this.title,
      speaker: speaker ?? this.speaker,
      date: date ?? this.date,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      transcript: transcript ?? this.transcript,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      series: series ?? this.series,
      biblePassage: biblePassage ?? this.biblePassage,
    );
  }
}