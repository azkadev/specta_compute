// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:galaxeus_lib/galaxeus_lib.dart';

void main(List<String> args) async {
  String username = Platform.environment["username"] ?? "admin";
  String password = Platform.environment["password"] ?? "azka123";
  String host_name = Platform.environment["HOST_API"] ?? "wss://specta-apis.up.railway.app/app";
  // host_name = "ws://127.0.0.1:8080/compute";
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
        String? extra;
        if (update["@extra"] is String) {
          extra = update["@extra"];
        }
        return print(update);
        if (method == "bash") {
          extra ??= getUuid(25);
          late String data = "";
          if (update["data"] is String) {
            data = update["data"];
          }
          if (data.isEmpty) {
            return ws.clientSendJson({"@type": "error", "method": "data mustbe not empty"});
          }

          bash(
            id: extra,
            onStdErr: (data, id) {
              if (id != extra) {
                return;
              }
              ws.clientSendJson({
                "@type": "bash",
                "is_error": true,
                "data": json.encode(data),
                "id": id,
                "@extra": extra,
              });
            },
            onStdOut: (data, id) {
              if (id != extra) {
                return;
              }
              ws.clientSendJson({
                "@type": "bash",
                "is_error": false,
                "data": json.encode(data),
                "id": id,
                "@extra": extra,
              });
            },
            onShell: (shell, id, is_done) {
              if (id != extra) {
                return;
              }
              if (is_done) {
                shell.kill();
              } else {
                shell.stdin.call(data);
              }
            },
          );
          return ws.clientSendJson({"@type": "ok"});
        }

        if (method == "exec") {
          extra ??= getUuid(25);
          late String command = "";
          late List args = [];

          if (update["command"] is String) {
            command = update["command"];
          }
          if (update["args"] is List) {
            args = update["args"];
          }
          ws.clientSendJson({"@type": "ok"});
          exec(
            id: extra,
            command: command,
            args: args.cast<String>(),
            onStdErr: (data, id) {
              if (id != extra) {
                return;
              }
              if (data.isEmpty) {
                return;
              }
              ws.clientSendJson({
                "@type": "exec",
                "is_error": true,
                "data": json.encode(data),
                "id": id,
                "@extra": extra,
              });
            },
            onStdOut: (data, id) {
              if (id != extra) {
                return;
              }
              if (data.isEmpty) {
                return;
              }
              ws.clientSendJson({
                "@type": "exec",
                "is_error": false,
                "data": json.encode(data),
                "id": id,
                "@extra": extra,
              });
            },
          );
          return;
        }

        if (method == "execRun") {
          extra ??= getUuid(25);
          late String command = "";
          late List args = [];

          if (update["command"] is String) {
            command = update["command"];
          }
          if (update["args"] is List) {
            args = update["args"];
          }
          ws.clientSendJson({"@type": "ok"});
          execRun(
            id: extra,
            command: command,
            args: args.cast<String>(),
            onStdErr: (data, id) {
              if (id != extra) {
                return;
              }
              if (data.isEmpty) {
                return;
              }
              ws.clientSendJson({
                "@type": "execRun",
                "is_error": true,
                "data": json.encode(data),
                "id": id,
                "@extra": extra,
              });
            },
            onStdOut: (data, id) {
              if (id != extra) {
                return;
              }
              if (data.isEmpty) {
                return;
              }
              ws.clientSendJson({
                "@type": "execRun",
                "is_error": false,
                "data": json.encode(data),
                "id": id,
                "@extra": extra,
              });
            },
            onShell: (shell, id, is_done) {
              if (id != extra) {
                return;
              }
              if (is_done) {
                shell.kill();
              } else {}
            },
          );
          return;
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
  // bash(
  //   id: "id",
  //   onStdErr: (data, id) {
  //     ws.clientSendJson({
  //       "@type": "bash",
  //       "is_error": true,
  //       "data": json.encode(data),
  //       "id": id,
  //     });
  //   },
  //   onStdOut: (data, id) {
  //     ws.clientSendJson({
  //       "@type": "bash",
  //       "is_error": false,
  //       "data": json.encode(data),
  //       "id": id,
  //     });
  //   },
  //   onShell: (shell, id, is_done) {
  //     ws.on("bash_update", (update) {
  //       shell.stdin.call(update);
  //     });
  //   },
  // );
  ws.clientSendJson({"@type": "download"});
}

void bash({
  required String id,
  required void Function(String data, String id) onStdErr,
  required void Function(String data, String id) onStdOut,
  required void Function(Process shell, String id, bool isDone) onShell,
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
    onDone: () {
      onShell.call(shell, id, true);
    },
  );
  shell.stdout.listen(
    (event) {
      var data = utf8.decode(event);
      //res_datas.add(data);
      onStdOut.call(data, id);
    },
    onDone: () {
      onShell.call(shell, id, true);
    },
  );
  // shell.stdin.call("neofetch --stdout", isWithTitle: false);
  onShell.call(shell, id, false);
}

void execRun({
  required String id,
  required String command,
  required List<String> args,
  required void Function(String data, String id) onStdErr,
  required void Function(String data, String id) onStdOut,
  required void Function(Process shell, String id, bool isDone) onShell,
}) async {
  Process shell = await Process.start(
    command,
    args,
    includeParentEnvironment: false,
    runInShell: true,
  );
  shell.stderr.listen(
    (event) {
      var data = utf8.decode(event);
      //res_datas.add(data);
      onStdErr.call(data, id);
    },
    onDone: () {
      onShell.call(shell, id, true);
    },
  );
  shell.stdout.listen(
    (event) {
      var data = utf8.decode(event);
      //res_datas.add(data);
      onStdOut.call(data, id);
    },
    onDone: () {
      onShell.call(shell, id, true);
    },
  );
  // shell.stdin.call("neofetch --stdout", isWithTitle: false);
  onShell.call(shell, id, false);
}

void exec({
  required String id,
  required String command,
  required List<String> args,
  required void Function(String data, String id) onStdErr,
  required void Function(String data, String id) onStdOut,
}) async {
  ProcessResult shell = await Process.run(
    command,
    args,
    includeParentEnvironment: false,
    runInShell: true,
  );
  onStdErr.call(shell.stderr, id);
  onStdOut.call(shell.stdout, id);
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
