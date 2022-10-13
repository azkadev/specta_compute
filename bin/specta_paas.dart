// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:galaxeus_lib/galaxeus_lib.dart';
import 'package:specta_paas/specta_paas.dart';

void main(List<String> args) async {
  String username = Platform.environment["username"] ?? "admin";
  String password = Platform.environment["password"] ?? "azka123";
  String host_name = Platform.environment["HOST_API"] ?? "wss://specta-apis.up.railway.app/compute";
  WebSocketClient ws = WebSocketClient("ws://0.0.0.0:8080/compute");
  DockerCli dockerCli = DockerCli();
  await dockerCli.init();
  
  ws.on("update", (update) {
    try {
      print(update is Map);
    } catch (e) {
      print(e);
    }
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
