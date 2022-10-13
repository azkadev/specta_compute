import 'dart:async';
import 'dart:io';

import 'package:specta_paas/specta_paas.dart' as specta_paas;
import 'package:telegram_client/telegram_client.dart';

void main(List<String> arguments) {
  Timer.periodic(Duration(seconds: 2), (timer) {
    ain([Directory.current.path]);
    ain(["../"]);
  });
}

void ain(List<String> arguments) {
  try {
  var res = Process.runSync("ls", arguments);
  print(res.stderr);
  print(res.stdout);
  }catch (e){
print(e);
  } 
   print(Platform.environment["azka"]);
}
