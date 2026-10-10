import 'package:test/test.dart';
import 'package:trippick_server/src/generated/protocol.dart';
import 'package:trippick_server/src/places/summary_service.dart';

void main() {
  test('finds the activist a deed site is named after', () {
    expect(SummaryService.activistOf('이재명 의거지'), '이재명');
    expect(SummaryService.activistOf('경성 부민관 폭탄 의거지'), isNull);
    expect(SummaryService.activistOf('명동'), isNull);
  });

  test('always calls the activist "의사"', () {
    String fix(String s) => SummaryService.withHonorific(
      ReviewSummary(good: s, bad: '', tip: ''),
      '이재명',
    ).good;
    expect(fix('1909년 이재명이 이완용을 처단하려 한 현장'), '1909년 이재명 의사가 이완용을 처단하려 한 현장');
    expect(fix('이재명 지사가 의거한 곳'), '이재명 의사가 의거한 곳');
    expect(fix('청년지사 이재명이 의거한 곳'), '이재명 의사가 의거한 곳');
    expect(fix('이재명 의사 의거지'), '이재명 의사 의거지');
    expect(fix('이재명은 독립운동가다'), '이재명 의사는 독립운동가다');
    expect(fix('이재명 의거가 일어난 곳'), '이재명 의사 의거가 일어난 곳');
  });
}
