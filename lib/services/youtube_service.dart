import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeVideoModel {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String? duration;

  const YoutubeVideoModel({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    this.duration,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  factory YoutubeVideoModel.fromSearchItem(Map<String, dynamic> item) {
    final snippet = item['snippet'] as Map<String, dynamic>;
    final videoId = (item['id'] as Map<String, dynamic>)['videoId'] as String;
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>;
    final thumbUrl =
        (thumbnails['medium'] as Map<String, dynamic>?)?['url'] as String? ??
        (thumbnails['default'] as Map<String, dynamic>)['url'] as String;

    return YoutubeVideoModel(
      videoId: videoId,
      title: snippet['title'] as String,
      channelTitle: snippet['channelTitle'] as String,
      thumbnailUrl: thumbUrl,
    );
  }
}

class YoutubeService {
  static const String _apiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<List<YoutubeVideoModel>> searchVideos(
    String query, {
    int maxResults = 10,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('YouTube API key is not configured.');
    }
    try {
      final uri = Uri.parse(
        '$_baseUrl/search?part=snippet&q=${Uri.encodeComponent(query)}'
        '&type=video&maxResults=$maxResults&key=$_apiKey',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('YouTube API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List;
      return items
          .map(
            (item) =>
                YoutubeVideoModel.fromSearchItem(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
