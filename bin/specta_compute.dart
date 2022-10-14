// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:galaxeus_lib/galaxeus_lib.dart';
import 'package:specta_compute/specta_compute.dart';

void main(List<String> args) async {
  String username = Platform.environment["username"] ?? "admin";
  String password = Platform.environment["password"] ?? "azka123";
  String host_name = Platform.environment["HOST_API"] ?? "wss://specta-apis.up.railway.app/ws";
  host_name = "ws://127.0.0.1:8080/ws";
  WebSocketClient ws = WebSocketClient(host_name);
  DockerCli dockerCli = DockerCli();
  await dockerCli.init();
  ws.on("update", (update) {
    try {
      if (update is Map) {
        if (update["@type"] is String == false) {
          return;
        }
        String method = (update["@type"] as String);
      }
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
      } else if (data is List) {
        print(data.length);
      }
    },
    onDataConnection: (data) {
      print(data);
    },
  );
  ws.clientSendJson({"@type": "download"});
}
