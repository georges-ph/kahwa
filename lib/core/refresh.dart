import 'package:flutter/foundation.dart';

/// Changes every time something shown on other screens is saved: a donation,
/// a goal, a profile. Screens that are still open underneath listen to it and
/// load their data again, however the user gets back to them.
final ValueNotifier<int> dataChanged = ValueNotifier(0);

void notifyDataChanged() => dataChanged.value++;
