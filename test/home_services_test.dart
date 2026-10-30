import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:la_fuerza_del_ocultismo/services/auth_service.dart';
import 'package:la_fuerza_del_ocultismo/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_fuerza_del_ocultismo/screens/home_screen.dart';
import 'package:la_fuerza_del_ocultismo/screens/tarot_screen.dart';
import 'package:la_fuerza_del_ocultismo/screens/horoscopo_screen.dart';
import 'package:la_fuerza_del_ocultismo/screens/limpiezas_screen.dart';
import 'package:la_fuerza_del_ocultismo/screens/rituales_screen.dart';
import 'package:la_fuerza_del_ocultismo/theme/app_theme.dart';

class _PreviewAuth extends Mock implements AuthService {
  @override
  UserModel? get userModel => null;
}

void main() {
  for (final width in [320.0, 390.0, 1240.0]) {
    testWidgets('Home layout at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        for (final family in ['Cinzel', 'Inter']) {
          final loader = FontLoader(family)
            ..addFont(rootBundle.load('assets/fonts/$family.ttf'));
          await loader.load();
        }
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      final boundary = GlobalKey();
      await tester.pumpWidget(ChangeNotifierProvider<AuthService>.value(
        value: _PreviewAuth(),
        child: MaterialApp(
            theme: AppTheme.dark,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(width == 320 ? 2 : 1)),
                child: child!),
            home: RepaintBoundary(
                key: boundary,
                child: const HomeScreen(dailyCards: Stream.empty()))),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      if (Platform.environment['CAPTURE_HOME'] == '1') {
        await tester.runAsync(() async {
          final image = await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/previews').create(recursive: true);
          await File('build/previews/home-${width.toInt()}.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.drag(find.byType(ListView).first, const Offset(0, -2500));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, 2500));
      await tester.pump();
      await tester.tap(find.byTooltip('Abrir menú'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final width in [320.0, 390.0, 600.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Stable services at width $width and text scale $scale',
          (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final opened = <Widget>[];
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.dark,
          home: MediaQuery(
              data: MediaQueryData(
                  size: Size(width, 900), textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                  body: MysticServicesCircle(user: null, onOpen: opened.add))),
        ));
        expect(tester.takeException(), isNull);
        final before = tester.getCenter(find.text('TAROT'));
        await tester.pump(const Duration(seconds: 3));
        expect(tester.getCenter(find.text('TAROT')), before);
        for (final title in ['TAROT', 'HORÓSCOPO', 'LIMPIEZAS', 'RITUALES']) {
          await tester.tap(find.text(title));
        }
        expect(opened.map((screen) => screen.runtimeType),
            [TarotScreen, HoroscopoScreen, LimpiezasScreen, RitualesScreen]);
        await tester.tap(find.text('Pausar ambiente'));
        await tester.pump();
        expect(find.text('Activar ambiente'), findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Reduced motion does not schedule animation frames',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child:
              Scaffold(body: MysticServicesCircle(user: null, onOpen: (_) {}))),
    ));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
