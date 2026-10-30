import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';

void armGooglePopupOnTouch(double x, double y, [void Function()? onTrigger]) {
  try {
    if (onTrigger != null) {
      globalContext['__triggerDartGoogleSignIn'] = onTrigger.toJS;
    }
    if (globalContext.has('__armGooglePopupOnTouch')) {
      globalContext.callMethod(
        '__armGooglePopupOnTouch'.toJS,
        x.toJS,
        y.toJS,
      );
    }
  } catch (_) {}
}

void openGooglePopupSync() {
  try {
    if (globalContext.has('__openGooglePopupSync')) {
      globalContext.callMethod('__openGooglePopupSync'.toJS);
    }
  } catch (_) {}
}

void closePendingGooglePopup() {
  try {
    if (globalContext.has('__closePendingGooglePopup')) {
      globalContext.callMethod('__closePendingGooglePopup'.toJS);
    }
  } catch (_) {}
}

Future<String?> getGoogleWebToken() async {
  try {
    if (globalContext.has('__signInWithGoogleNativeWeb')) {
      final promise = globalContext.callMethod<JSPromise<JSObject?>>(
        '__signInWithGoogleNativeWeb'.toJS,
      );
      final JSObject? result = await promise.toDart;
      if (result != null && result.has('accessToken')) {
        final token = result.getProperty<JSString?>('accessToken'.toJS)?.toDart;
        return token;
      }
    }
  } catch (e) {
    debugPrint('Aviso getGoogleWebToken: $e');
    rethrow;
  }
  return null;
}
