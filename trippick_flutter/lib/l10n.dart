import 'package:flutter/foundation.dart';

enum Lang { ko, en }

/// 현재 언어. 바뀌면 앱 전체가 다시 그려집니다.
final lang = ValueNotifier<Lang>(Lang.ko);

String t(String key, {Object? n}) {
  final s = _strings[key]?[lang.value.index] ?? key;
  return n == null ? s : s.replaceAll('{n}', '$n');
}

const _strings = <String, List<String>>{
  'app_name': ['한눈에여행', 'Hannun Travel'],
  'search_hint': ['장소, 맛집, 놀거리 검색', 'Search places, food, activities'],
  'cat_all': ['전체', 'All'],
  'cat_sight': ['명소', 'Sights'],
  'cat_food': ['맛집', 'Food'],
  'cat_activity': ['놀거리', 'Activities'],
  'taste_healing': ['힐링', 'Relaxing'],
  'taste_activity': ['액티비티', 'Active'],
  'taste_food': ['맛집 탐방', 'Foodie'],
  'taste_photo': ['사진 명소', 'Photo spots'],
  'for_you': ['취향에 맞는 장소', 'Picked for you'],
  'for_you_sub': [
    '공식 관광 정보와 여행자 리뷰를 바탕으로 골랐어요',
    'Based on official tourism info and traveler reviews',
  ],
  'nearby': ['내 주변 장소', 'Places nearby'],
  'reviews': ['블로그 리뷰 {n}', '{n} reviews'],
  'summary': ['리뷰 요약', 'Review summary'],
  'summary_basis': ['리뷰 {n}개 기반', 'From {n} reviews'],
  'good': ['좋아요', 'Pros'],
  'bad': ['아쉬워요', 'Cons'],
  'tip': ['팁', 'Tip'],
  'highlight': ['한눈 요약', 'At a glance'],
  'highlight_basis': ['한국관광공사 정보 기반', 'From official tourism info'],
  'hl_good': ['특징', 'Highlight'],
  'hl_bad': ['알아둘 점', 'Good to know'],
  'no_summary': [
    '아직 요약할 정보가 없어요. 첫 리뷰를 남겨주세요',
    'No summary yet — be the first to review',
  ],
  'reviews_title': ['리뷰', 'Reviews'],
  'write_review': ['리뷰 쓰기', 'Write a review'],
  'review_empty': ['아직 리뷰가 없어요', 'No reviews yet'],
  'review_need_more': [
    '리뷰가 {n}개 더 모이면 AI가 요약해 드려요',
    '{n} more reviews to unlock the AI summary',
  ],
  'review_name': ['닉네임', 'Nickname'],
  'review_text': [
    '어땠나요? 다른 여행자에게 도움이 되는 이야기를 남겨주세요',
    'How was it? Share something useful for other travelers',
  ],
  'review_submit': ['등록', 'Post'],
  'review_too_short': ['5자 이상 써주세요', 'Please write at least 5 characters'],
  'review_failed': ['등록하지 못했어요. 다시 시도해 주세요', "Couldn't post. Please try again"],
  'review_done': ['리뷰를 등록했어요', 'Review posted'],
  'info': ['이용 정보', 'Visitor info'],
  'about': ['소개', 'About'],
  'source_tour': [
    '관광정보 제공: 한국관광공사',
    'Tourism info: Korea Tourism Organization',
  ],
  'fact_hours': ['운영시간', 'Hours'],
  'fact_closed': ['휴무일', 'Closed'],
  'fact_parking': ['주차', 'Parking'],
  'fact_fee': ['요금', 'Fee'],
  'fact_season': ['이용 시기', 'Season'],
  'fact_experience': ['체험', 'Experience'],
  'fact_duration': ['관람 소요', 'Duration'],
  'fact_reservation': ['예약', 'Reservation'],
  'fact_signature': ['대표 메뉴', 'Signature'],
  'fact_menu': ['메뉴', 'Menu'],
  'fact_takeout': ['포장', 'Takeout'],
  'korean_only': ['', 'Details are provided in Korean'],
  'tab_home': ['홈', 'Home'],
  'tab_map': ['지도', 'Map'],
  'tab_saved': ['저장', 'Saved'],
  'tab_my': ['MY', 'Me'],
  'empty': ['조건에 맞는 장소가 없어요', 'No places match your filters'],
  'saved_empty': ['저장한 장소가 없어요', 'No saved places yet'],
  'saved_empty_sub': [
    '마음에 드는 장소의 북마크를 눌러보세요',
    'Tap the bookmark on any place to save it',
  ],
  'coming_soon': ['준비 중이에요', 'Coming soon'],
  'count': ['{n}곳', '{n}'],
  'load_error': ['서버에 연결하지 못했어요', "Couldn't reach the server"],
  'load_error_sub': ['잠시 후 다시 시도해 주세요', 'Please try again in a moment'],
  'preparing': ['장소 정보를 준비하고 있어요', 'Getting places ready'],
  'preparing_sub': [
    '처음 가는 지역이라 장소를 모으고 있어요. 잠시 후 자동으로 새로고침돼요',
    'Gathering places for a new area. This page refreshes automatically',
  ],
  'retry': ['다시 시도', 'Retry'],
  'pick_location': ['어디 주변을 볼까요?', 'Where do you want to explore?'],
  'use_current': ['현재 위치', 'My current location'],
  'loc_denied': [
    '위치 권한이 없어 기본 위치로 보여드려요',
    'Location is off — showing a featured area',
  ],
  'loc_outside': [
    '한국 밖이라 추천 지역을 보여드려요',
    "You're outside Korea — showing a featured area",
  ],
  'loc_failed': ['현재 위치를 찾지 못했어요', "Couldn't get your location"],
  'featured_areas': ['추천 지역 · 한국', 'Featured · Korea'],
  'abroad': ['추천 지역 · 해외', 'Featured · Abroad'],
  'highlight_basis_osm': [
    '위키백과·오픈스트리트맵 정보 기반',
    'From Wikipedia & OpenStreetMap',
  ],
  'source_osm': [
    '장소 정보: © OpenStreetMap 기여자 · 소개: 위키백과 (CC BY-SA)',
    'Places © OpenStreetMap contributors · Descriptions: Wikipedia (CC BY-SA)',
  ],
  'open_google': ['구글 지도에서 보기', 'Open in Google Maps'],
  'fact_website': ['웹사이트', 'Website'],
  'loading_area': [
    '주변 장소를 모으고 있어요\n처음 가는 지역은 10~30초 걸려요',
    'Gathering places nearby\nA new area takes 10–30 seconds the first time',
  ],
  'open_map': ['카카오맵에서 보기', 'Open in Kakao Map'],
  'lang_toggle': ['EN', '한국어'],
};
