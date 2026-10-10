import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'client.dart';
import 'data/location.dart';
import 'data/place_repository.dart';
import 'models/place_view.dart';
import 'l10n.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/saved_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  // 한글 글꼴을 먼저 받아 둬서 첫 화면에 글자가 네모로 깨지지 않게 함
  await GoogleFonts.pendingFonts([
    for (final w in [
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    ])
      GoogleFonts.notoSansKr(fontWeight: w),
  ]);
  runApp(const HannunApp());
}

class HannunApp extends StatelessWidget {
  const HannunApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 언어에 따라 브라우저 탭 제목도 한눈에여행 / Hannun Travel 로 바뀜
    return ValueListenableBuilder(
      valueListenable: lang,
      builder: (context, _, _) => MaterialApp(
        onGenerateTitle: (_) => t('app_name'),
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  bool _loading = true;
  Object? _error;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await loadPlaces();
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('loadPlaces failed: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e;
        });
      }
    }
  }

  // 언어가 바뀌면 화면 전체를 다시 그림 (탭·필터 상태는 유지)
  void _onLang() => setState(() {});

  @override
  void initState() {
    super.initState();
    lang.addListener(_onLang);
    placesStore.addListener(_onLang);
    // 위치가 바뀌면 (현재 위치 확인, 지역 선택) 그 주변 장소를 다시 불러옴
    locationStore.addListener(_load);
    _start();
  }

  /// 처음 실행: 현재 위치를 시도하고, 안 되면 추천 지역으로 시작.
  Future<void> _start() async {
    final result = await useCurrentLocation();
    if (result == LocateResult.ok) return; // listener loads places
    await _load();
    if (!mounted) return;
    final message = switch (result) {
      LocateResult.denied => t('loc_denied'),
      _ => t('loc_failed'),
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    lang.removeListener(_onLang);
    placesStore.removeListener(_onLang);
    locationStore.removeListener(_load);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final places = _loading || _error != null ? null : placesStore.value;

    return Scaffold(
      body: places == null || places.isEmpty
          ? _status()
          : IndexedStack(
              index: _tab,
              children: [
                HomeScreen(places: places),
                MapScreen(places: places),
                SavedScreen(places: places),
                Center(child: Text(t('coming_soon'), style: AppText.body)),
              ],
            ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.ink,
          unselectedItemColor: AppColors.faint,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: t('tab_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map_rounded),
              label: t('tab_map'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark_border),
              activeIcon: const Icon(Icons.bookmark),
              label: t('tab_saved'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: t('tab_my'),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading / error / not-ready-yet screen.
  Widget _status() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 16),
            Text(
              t('loading_area'),
              style: AppText.small,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t(_error != null ? 'load_error' : 'preparing'),
              style: AppText.name,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              t(_error != null ? 'load_error_sub' : 'preparing_sub'),
              style: AppText.small,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _load, child: Text(t('retry'))),
          ],
        ),
      ),
    );
  }
}
