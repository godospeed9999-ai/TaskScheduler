import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

class OpenRouterService {
static const String _baseUrl =
'https://openrouter.ai/api/v1/chat/completions';

static const String _apiKey =
'YOUR_OPENROUTER_API_KEY';

static const String _model =
'deepseek/deepseek-v4-flash:free';

static const String systemPrompt = '''
You are an intelligent AI task scheduler assistant. Your job is to have a natural,
conversational interview with the user to understand their schedule, goals, commitments,
and preferences — then generate a personalized daily timetable.

You must:

* Ask questions naturally, one or two at a time — like ChatGPT, not a form
* Gather information about: wake time, sleep time, study/work subjects, exam dates,
  weak areas, break preferences, workout habits, meals, and productivity patterns
* Reason about workload balancing, burnout prevention, focus duration, and urgency
* Continue the conversation until you have enough context to generate a high-quality schedule
* When you have sufficient information, output ONLY a valid JSON array of tasks

The JSON format you MUST use when generating the timetable:
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

IMPORTANT:

* Output ONLY JSON when generating timetable
* Otherwise speak normally like ChatGPT
* Start by greeting user and asking about goals and schedule
  ''';

  Future<String> streamCompletion({
  required List<ChatMessageModel> messages,
  required void Function(String chunk) onChunk,
  required void Function() onDone,
  required void Function(String error) onError,
  }) async {

  try {
  final apiMessages = [
  {
  'role': 'system',
  'content': systemPrompt,
  },
  ...messages.map((m) => m.toApiMap()),
  ];

  ```
  final response = await http.post(
    Uri.parse(_baseUrl),
    headers: {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
      'HTTP-Referer':
          'https://taskschedu2468.builtwithrocket.new',
      'X-Title': 'Task Scheduler',
    },
    body: jsonEncode({
      'model': _model,
      'messages': apiMessages,
      'stream': false,
      'temperature': 0.7,
      'max_tokens': 2048,
    }),
  );

  print("========== OPENROUTER DEBUG ==========");
  print("STATUS CODE: ${response.statusCode}");
  print("BODY: ${response.body}");
  print("======================================");

  if (response.statusCode == 200) {

    final data =
        jsonDecode(response.body);

    final content =
        data['choices'][0]['message']['content'];

    onChunk(content);
    onDone();

    return content;

  } else {

    onError(
      'API ERROR: ${response.body}',
    );

    return '';
  }
  ```

  } catch (e) {

  ```
  print("OPENROUTER ERROR: $e");

  onError(
    'ERROR: $e',
  );

  return '';
  ```

  }
  }

  static List<Map<String, dynamic>>?
  tryParseTaskJson(String response) {

  final trimmed = response.trim();

  if (!trimmed.startsWith('[') &&
  !trimmed.startsWith('{')) {
  return null;
  }

  try {

  ```
  final decoded =
      jsonDecode(trimmed);

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
  ```

  } catch (_) {}

  return null;
  }
  }
