import 'dart:async';
import 'dart:io';

import 'package:specta_paas/specta_paas.dart' as specta_paas;
import 'package:telegram_client/telegram_client.dart';

void main(List<String> arguments) {
  var res = Process.runSync("ls", [""]);
  print(res.stderr);
  print(res.stdout);
  print(Platform.environment["azka"]);
}
