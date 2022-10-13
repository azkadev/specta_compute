// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:galaxeus_lib/galaxeus_lib.dart';

void main(List<String> args) async {
  String host_name = Platform.environment["HOST_API"] ?? "wss://specta-apis.up.railway.app/ws";
  WebSocketClient ws = WebSocketClient("ws://0.0.0.0:8080/compute");

  ws.on("update", (update) {
    print(update);
    ws.clientSendJson({"@type": "client"});
    print("terkirim ke server");
  });
  await ws.connect(
    onDataUpdate: (data) {
      if (data is String && data.isNotEmpty) {
        try {
          return ws.event_emitter.emit(ws.event_name_update, null, json.decode(data));
        } catch (e) {}
      }
    },
  );
}
