import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

class OpenRouterService {
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'deepseek/deepseek-v4-flash:free';
  static const String _apiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  static const String systemPrompt = '''
You are an intelligent AI task scheduler assistant. Your job is to have a natural, 
conversational interview with the user to understand their schedule, goals, commitments, 
and preferences — then generate a personalized daily timetable.

You must:
- Ask questions naturally, one or two at a time — like ChatGPT, not a form
- Gather information about: wake time, sleep time, study/work subjects, exam dates, 
  weak areas, break preferences, workout habits, meals, and productivity patterns
- Reason about workload balancing, burnout prevention, focus duration, and urgency
- Continue the conversation until you have enough context to generate a high-quality schedule
- When you have sufficient information, output ONLY a valid JSON array of tasks

The JSON format you MUST use when generating the timetable (and ONLY when ready):
[
  {
    "title": "Task name",
    "description": "Brief description",
    "category": "Study|Work|Health|Personal",
    "startTime": "HH:MM",
    "endTime": "HH:MM",
    "day": "Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday"
  }
]

IMPORTANT: Output ONLY the JSON array when generating the timetable — no other text before or after.
For all other responses, output normal conversational text — never JSON.
Start by warmly greeting the user and asking about their goals and schedule.
''';

  /// Streams a response from OpenRouter. Calls [onChunk] for each streamed token.
  Future<String> streamCompletion({
    required List<ChatMessageModel> messages,
    required void Function(String chunk) onChunk,
    required void Function() onDone,
    required void Function(String error) onError,
  }) async {
    final buffer = StringBuffer();
    StreamSubscription<List<int>>? subscription;

    if (_apiKey.isEmpty) {
      onError(
        'OpenRouter API key is not configured. Please add OPENROUTER_API_KEY.',
      );
      return '';
    }

    try {
      final apiMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => m.toApiMap()),
      ];

      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://taskschedu2468.builtwithrocket.new',
        'X-Title': 'Task Scheduler',
      });
      request.body = jsonEncode({
        'model': _model,
        'messages': apiMessages,
        'stream': true,
        'temperature': 0.7,
        'max_tokens': 2048,
      });

      final client = http.Client();
      final response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        String errorMsg;
        try {
          final decoded = jsonDecode(body) as Map<String, dynamic>;
          final errObj = decoded['error'] as Map<String, dynamic>?;
          errorMsg =
              errObj?['message'] as String? ??
              'API error ${response.statusCode}';
        } catch (_) {
          errorMsg = 'API error ${response.statusCode}: $body';
        }
        if (response.statusCode == 401) {
          errorMsg = 'Invalid API key. Please check your OpenRouter API key.';
        } else if (response.statusCode == 429) {
          errorMsg = 'Rate limit or quota exceeded. Please try again later.';
        } else if (response.statusCode == 400) {
          errorMsg = 'Bad request: $errorMsg';
        }
        onError(errorMsg);
        client.close();
        return '';
      }

      final completer = Completer<String>();

      subscription = response.stream.listen(
        (chunk) {
          final lines = utf8.decode(chunk).split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6).trim();
              if (data == '[DONE]') continue;
              try {
                final json = jsonDecode(data) as Map<String, dynamic>;
                final choices = json['choices'] as List?;
                if (choices != null && choices.isNotEmpty) {
                  final delta = choices[0]['delta'] as Map<String, dynamic>?;
                  final content = delta?['content'] as String?;
                  if (content != null) {
                    buffer.write(content);
                    onChunk(content);
                  }
                }
              } catch (_) {
                // Skip malformed SSE chunks
              }
            }
          }
        },
        onDone: () {
          onDone();
          client.close();
          if (!completer.isCompleted) {
            completer.complete(buffer.toString());
          }
        },
        onError: (e) {
          final msg = e.toString().contains('SocketException')
              ? 'No internet connection. Please check your network.'
              : 'Connection error: ${e.toString()}';
          onError(msg);
          client.close();
          if (!completer.isCompleted) {
            completer.complete(buffer.toString());
          }
        },
        cancelOnError: true,
      );

      return completer.future;
    } catch (e) {
      subscription?.cancel();
      final msg = e.toString().contains('SocketException')
          ? 'No internet connection. Please check your network.'
          : 'Unexpected error: ${e.toString()}';
      onError(msg);
      return buffer.toString();
    }
  }

  /// Attempts to detect and parse a JSON timetable from an AI response.
  static List<Map<String, dynamic>>? tryParseTaskJson(String response) {
    final trimmed = response.trim();
    if (!trimmed.startsWith('[') && !trimmed.startsWith('{')) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .where(
              (m) =>
                  m.containsKey('title') &&
                  m.containsKey('startTime') &&
                  m.containsKey('endTime'),
            )
            .toList();
      }
    } catch (_) {
      // Not valid JSON — treat as normal text
    }
    return null;
  }
}
