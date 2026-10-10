import 'dart:convert';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';

class SummaryResult {
  SummaryResult({
    required this.ko,
    required this.en,
    required this.nameEn,
    required this.tags,
  });
  final ReviewSummary ko;
  final ReviewSummary en;
  final String nameEn;
  final List<String> tags;
}

/// Summarizes text with Groq (OpenAI-compatible API).
/// Both prompts forbid anything not stated in the given source text.
class SummaryService {
  SummaryService(this.apiKey, {this.model = 'openai/gpt-oss-120b'});

  final String apiKey;
  final String model;

  static const tastes = {'healing', 'activity', 'food', 'photo'};

  static const _common = '''
- 반드시 아래에 제공된 내용만 근거로 쓴다. 제공된 내용에 없는 사실(가격, 메뉴, 시간 등)은 절대 지어내지 않는다.
- 근거가 없는 항목은 "정보 없음" (영어는 "No info")이라고 쓴다.
- 각 항목은 한 문장. 한국어는 45자, 영어는 80자 이내.
- name_en: 장소의 영어 이름. 공식 영문명을 모르면 로마자 표기로 쓴다.
- tags: 근거가 있는 것만 고른다: healing(조용함/경치/휴식), activity(체험/활동), food(음식/맛), photo(사진/뷰).
- 아래 JSON 형식으로만 답한다:
{"ko": {"good": "...", "bad": "...", "tip": "..."},
 "en": {"good": "...", "bad": "...", "tip": "..."},
 "name_en": "English name",
 "tags": ["healing"]}''';

  static const _officialPrompt =
      '''너는 여행지 안내 요약가다. 공식 관광 정보(또는 위키백과·지도 정보)를 여행자 관점의 3줄로 요약한다.
- good: 이 장소의 가장 큰 특징이나 볼거리
- bad: 방문 전에 알아둘 점 (휴무일, 운영시간 제약, 주차, 요금, 예약 등)
- tip: 방문에 도움이 되는 팁
$_common''';

  static const _reviewPrompt = '''너는 여행 장소 리뷰 요약가다. 사용자 리뷰를 3줄로 요약한다.
- good: 리뷰에서 공통적으로 칭찬한 점
- bad: 리뷰에서 지적된 아쉬운 점
- tip: 리뷰에 나온 실용적인 팁
$_common''';

  Future<SummaryResult?> summarizeOfficial(Place place) {
    final facts = (place.facts ?? const {}).entries
        .where((e) => e.key != 'contentTypeId' && !e.key.startsWith('_'))
        .map((e) => '- ${e.key}: ${e.value}')
        .join('\n');
    final overview = place.overview ?? '';
    final text = overview.length > 1500
        ? overview.substring(0, 1500)
        : overview;
    return _call(
      _officialPrompt,
      '장소: ${place.name} (${place.address})\n소개:\n$text\n이용 정보:\n$facts',
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
    final body = jsonEncode({
      'model': model,
      'temperature': 0.2,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': user},
      ],
    });

    for (var attempt = 0; attempt < 4; attempt++) {
      final res = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (res.statusCode == 400 && res.body.contains('json_validate_failed')) {
        // The model occasionally produces invalid JSON; just try again.
        continue;
      }
      if (res.statusCode == 429) {
        // Free tier rate limit: wait and retry.
        await Future.delayed(Duration(seconds: 10 * (attempt + 1)));
        continue;
      }
      if (res.statusCode != 200) {
        throw Exception('Groq API ${res.statusCode}: ${res.body}');
      }
      try {
        final json =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        return _parse(json['choices'][0]['message']['content'] as String);
      } catch (_) {
        // Malformed JSON from the model; retry.
      }
    }
    return null;
  }

  static SummaryResult _parse(String content) {
    final json =
        jsonDecode(
              content.substring(
                content.indexOf('{'),
                content.lastIndexOf('}') + 1,
              ),
            )
            as Map<String, dynamic>;
    ReviewSummary summary(Map<String, dynamic> m) => ReviewSummary(
      good: '${m['good']}'.trim(),
      bad: '${m['bad']}'.trim(),
      tip: '${m['tip']}'.trim(),
    );
    return SummaryResult(
      ko: summary(json['ko'] as Map<String, dynamic>),
      en: summary(json['en'] as Map<String, dynamic>),
      nameEn: '${json['name_en'] ?? ''}'.trim(),
      tags: [
        for (final t in (json['tags'] as List? ?? const []))
          if (tastes.contains(t)) t as String,
      ],
    );
  }
}
