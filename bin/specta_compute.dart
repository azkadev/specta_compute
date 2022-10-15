// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:galaxeus_lib/galaxeus_lib.dart';
import 'package:specta_compute/specta_compute.dart';

void main(List<String> args) async {
  String username = Platform.environment["username"] ?? "admin";
  String password = Platform.environment["password"] ?? "azka123";
  String host_name = Platform.environment["HOST_API"] ?? "wss://specta-apis.up.railway.app/ws";
  host_name = "ws://127.0.0.1:8080/compute";
  WebSocketClient ws = WebSocketClient(host_name);
  // DockerCli dockerCli = DockerCli();
  // await dockerCli.init();
  ws.on("update", (update) {
    try {
      if (update is Map) {
        if (update["@type"] is String == false) {
          return;
        }
        String method = (update["@type"] as String);
        if (method == "bash") {
          late String data = "";
          if (update["data"] is String) {
            data = update["data"];
          }
          if (data.isEmpty) {
            return ws.clientSendJson({"@type": "error", "method": "data mustbe not empty"});
          }
          ws.event_emitter.emit("bash_update", null, data);
          return ws.clientSendJson({"@type": "ok"});
        }
        return ws.clientSendJson({"@type": "error", "method": "method not found"});
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
  bash(
    id: "id",
    onStdErr: (data, id) {
      ws.clientSendJson({
        "@type": "bash",
        "is_error": true, 
        "data": json.encode(data),
        "id": id,
      });
    },
    onStdOut: (data, id) {
      ws.clientSendJson({
        "@type": "bash",
        "is_error": false,
        "data": json.encode(data),
        "id": id,
      });
    },
    onShell: (shell, id) {
      ws.on("bash_update", (update) {
        shell.stdin.call(update);
      });
    },
  );
  ws.clientSendJson({"@type": "download"});
}

void bash({
  required String id,
  required void Function(String data, String id) onStdErr,
  required void Function(String data, String id) onStdOut,
  required void Function(Process shell, String id) onShell,
}) async {
  Process shell = await Process.start(
    "bash",
    [],
    includeParentEnvironment: false,
    runInShell: true,
  );
  shell.stderr.listen(
    (event) {
      var data = utf8.decode(event);
      //res_datas.add(data);
      onStdErr.call(data, id);
    },
    onDone: () {},
  );
  shell.stdout.listen(
    (event) {
      var data = utf8.decode(event);
      //res_datas.add(data);
      onStdOut.call(data, id);
    },
    onDone: () {},
  );
  shell.stdin.call("neofetch --stdout", isWithTitle: false);
  onShell.call(shell, id);
}

extension IOSSinkStdInExtensions on IOSink {
  void call(
    String data, {
    bool isWithTitle = false,
  }) {
    if (isWithTitle) {
      call("echo \"\$USER@\$(hostname -f):\$(pwd)\$ \"");
    }
    return add(utf8.encode(data += "\n"));
  }
}
