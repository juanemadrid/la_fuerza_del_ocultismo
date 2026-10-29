import 'dart:js_interop';
import 'dart:js_interop_unsafe';

void armGooglePopupOnTouch(double x, double y) {
  try {
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
