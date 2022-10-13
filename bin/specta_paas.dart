import 'dart:async';

import 'package:specta_paas/specta_paas.dart' as specta_paas;
import 'package:telegram_client/telegram_client.dart';

void main(List<String> arguments) {
  print('Hello world: ${specta_paas.calculate()}!');
  TelegramBotApi tg = TelegramBotApi("");
  int chat_id = 0;
  Timer.periodic(Duration(seconds: 2), (t) async {
    await tg.request("sendMessage", parameters: {"chat_id": chat_id, "text": t.toString()});
  });
}
