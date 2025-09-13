import 'dart:html' as html;

/// Web implementation: reload current page
void reloadPage() {
  try {
    html.window.location.reload();
  } catch (e) {
    // ignore
  }
}
