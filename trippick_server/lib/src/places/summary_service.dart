import 'dart:convert';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';

class SummaryResult {
  SummaryResult({
    required this.ko,
    required this.en,
    required this.nameEn,
    required this.factsEn,
    required this.tags,
  });
  final ReviewSummary ko;
  final ReviewSummary en;
  final String nameEn;
  final Map<String, String> factsEn;
  final List<String> tags;
}

/// Summarizes text with Groq (OpenAI-compatible API).
/// Both prompts forbid anything not stated in the given source text.
class SummaryService {
  SummaryService(this.apiKey, {String model = 'openai/gpt-oss-120b'})
    : models = [model, ..._fallbackModels.where((m) => m != model)];

  final String apiKey;

  /// Tried in order: when one model's free daily token limit is used up,
  /// the next one (with its own limit) takes over.
  final List<String> models;

  static const _fallbackModels = ['openai/gpt-oss-20b', 'qwen/qwen3.8-27b'];

  /// Models whose daily limit ran out, and when to try them again.
  static final _exhaustedUntil = <String, DateTime>{};

  /// Bump when the prompts change so existing summaries are redone.
  static const version = 2;

  static const tastes = {'healing', 'activity', 'food', 'photo'};

  static const _accuracy = '''
정확성 규칙 (가장 중요):
- 제공된 내용에 적힌 사실만 쓴다. 원문에 없는 주차장 위치, 가격, 혼잡 시간, 추천 시간대 등을 지어내거나 추측하지 않는다.
- 원문의 사실을 부풀리거나 바꾸지 않는다. "~하기 위해", "~하려고"는 시도이지 성공이 아니다.
- "준비시간", "브레이크타임", "휴게시간"은 영업하지 않는 시간이다. 그 시간에 방문하라고 쓰지 않는다.
- "상시 개방", "연중무휴", "주차 가능"처럼 주의할 필요가 없는 내용은 bad에 쓰지 않는다.
- 특정 건물이 아니라 넓은 지역·특구·거리·골목·코스이면 운영시간과 휴무일을 언급하지 않는다.
- 의거를 일으킨 독립운동가는 이름 뒤에 "의사"를 붙인다 (예: 안중근 의사, 윤봉길 의사). 다른 역사 인물도 원문의 호칭(열사, 선생 등)을 붙인다. 영어에서는 신분을 밝힌다 (예: independence activist An Jung-geun). 현대의 동명이인과 헷갈리지 않게 한다.
- 근거가 없는 항목은 빈 문자열 ""로 둔다. 억지로 채우지 않는다.''';

  static const _format = '''
- 각 항목은 한 문장. 한국어 50자, 영어 90자 이내. en은 ko와 같은 내용을 자연스러운 영어로 쓴다.
- name_en: 장소의 영어 이름. 공식 영문명이 없으면 뜻이 통하게 번역한다 (예: 경복궁 → Gyeongbokgung Palace, ○○ 의거지 → Site of ○○'s Patriotic Deed). 가게 상호는 로마자로 쓴다.
- facts_en: "이용 정보"의 각 값을 영어로 옮긴다. 키는 그대로 둔다. 없으면 {}.
- tags: 근거가 있는 것만 고른다: healing(조용함/경치/휴식), activity(체험/활동), food(이 장소에서 음식을 먹는 곳), photo(사진/뷰).
- 아래 JSON 형식으로만 답한다:
{"ko": {"good": "...", "bad": "...", "tip": "..."},
 "en": {"good": "...", "bad": "...", "tip": "..."},
 "name_en": "English name",
 "facts_en": {"hours": "..."},
 "tags": ["healing"]}''';

  static const _officialPrompt =
      '''너는 여행 앱의 장소 안내 편집자다. 공식 관광 정보(또는 위키백과·지도 정보)만 보고 여행자에게 정확한 3줄 요약을 쓴다.
$_accuracy

항목:
- good: 이 장소의 가장 큰 특징이나 볼거리. 반드시 쓴다.
- bad: 방문 전에 알아둘 제약 (휴무일, 브레이크타임, 주차 불가, 요금, 예약, 대기 등). 없으면 "".
- tip: good·bad와 겹치지 않는, 원문에 근거한 구체적인 팁. 없으면 "".
$_format''';

  static const _reviewPrompt =
      '''너는 여행 장소 리뷰 요약가다. 사용자 리뷰만 보고 3줄로 요약한다.
$_accuracy

항목:
- good: 리뷰에서 공통적으로 칭찬한 점
- bad: 리뷰에서 지적된 아쉬운 점. 없으면 "".
- tip: 리뷰에 나온 실용적인 팁. 없으면 "".
$_format''';

  static const _namePrompt =
      '''장소 이름을 영어로 옮긴다. 공식 영문명이 없으면 뜻이 통하게 번역하고, 가게 상호는 로마자로 쓴다.
JSON으로만 답한다: {"name_en": "..."}''';

  /// English name only, for places with nothing official to summarize.
  Future<String?> translateName(Place place) async {
    final content = await _complete(
      _namePrompt,
      '장소: ${place.name} (${place.address})',
    );
    if (content == null) return null;
    final json = _json(content);
    final name = '${json['name_en'] ?? ''}'.trim();
    return name.isEmpty ? null : name;
  }

  Future<SummaryResult?> summarizeOfficial(Place place) {
    final facts = (place.facts ?? const {}).entries
        .where((e) => e.key != 'contentTypeId' && !e.key.startsWith('_'))
        .map((e) => '- ${e.key}: ${e.value}')
        .join('\n');
    final overview = place.overview ?? '';
    final text = overview.length > 1000
        ? overview.substring(0, 1000)
        : overview;
    final area = place.facts?['_area'] == 'true' ? ' (넓은 지역)' : '';
    return _call(
      _officialPrompt,
      '장소: ${place.name}$area (${place.address})\n'
      '소개:\n$text\n이용 정보:\n$facts',
    );
  }

  Future<SummaryResult?> summarizeReviews(
    Place place,
    List<UserReview> reviews,
  ) {
    final text = reviews
        .take(30)
        .map((r) => '- (${r.rating}/5) ${r.text}')
        .join('\n');
    return _call(_reviewPrompt, '장소: ${place.name}\n리뷰:\n$text');
  }

  /// Returns null if the model keeps answering in a broken format.
  Future<SummaryResult?> _call(String system, String user) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final content = await _complete(system, user);
      if (content == null) return null;
      try {
        return _parse(content);
      } catch (_) {
        // Malformed JSON from the model; retry.
      }
    }
    return null;
  }

  /// One chat completion, waiting out per-minute limits and moving to the
  /// next model when a daily limit is used up. Null if every model is out.
  Future<String?> _complete(String system, String user) async {
    for (final model in models) {
      final until = _exhaustedUntil[model];
      if (until != null && DateTime.now().isBefore(until)) continue;

      for (var attempt = 0; attempt < 6; attempt++) {
        final res = await http.post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'temperature': 0.2,
            if (model.startsWith('openai/gpt-oss')) 'reasoning_effort': 'low',
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': system},
              {'role': 'user', 'content': user},
            ],
          }),
        );
        if (res.statusCode == 400 &&
            res.body.contains('json_validate_failed')) {
          // The model occasionally produces invalid JSON; just try again.
          continue;
        }
        if (res.statusCode == 429) {
          if (res.body.contains('per day')) {
            _exhaustedUntil[model] = DateTime.now().add(
              const Duration(hours: 1),
            );
            break;
          }
          // Per-minute limit: wait as long as the API asks.
          final wait = int.tryParse(res.headers['retry-after'] ?? '') ?? 10;
          await Future.delayed(Duration(seconds: wait + 1));
          continue;
        }
        if (res.statusCode != 200) {
          throw Exception('Groq API ($model) ${res.statusCode}: ${res.body}');
        }
        final json =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        return json['choices'][0]['message']['content'] as String;
      }
    }
    return null;
  }

  static Map<String, dynamic> _json(String content) =>
      jsonDecode(
            content.substring(
              content.indexOf('{'),
              content.lastIndexOf('}') + 1,
            ),
          )
          as Map<String, dynamic>;

  static SummaryResult _parse(String content) {
    final json = _json(content);
    // "No info" placeholders are dropped so the app can hide the line.
    String line(Object? v) {
      final s = '${v ?? ''}'.trim();
      return RegExp(
            r'^(정보 없음|없음|no info\.?|n/a|null)$',
            caseSensitive: false,
          ).hasMatch(s)
          ? ''
          : s;
    }

    ReviewSummary summary(Map<String, dynamic> m) => ReviewSummary(
      good: line(m['good']),
      bad: line(m['bad']),
      tip: line(m['tip']),
    );
    final factsEn = json['facts_en'];
    return SummaryResult(
      ko: summary(json['ko'] as Map<String, dynamic>),
      en: summary(json['en'] as Map<String, dynamic>),
      nameEn: '${json['name_en'] ?? ''}'.trim(),
      factsEn: {
        if (factsEn is Map)
          for (final e in factsEn.entries)
            if ('${e.value}'.trim().isNotEmpty) '${e.key}': '${e.value}'.trim(),
      },
      tags: [
        for (final t in (json['tags'] as List? ?? const []))
          if (tastes.contains(t)) t as String,
      ],
    );
  }
}
