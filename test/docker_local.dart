// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';

import 'package:docker_commander/docker_commander_vm.dart';

void main() async {
  DockerCli dockerCli = DockerCli();
  await dockerCli.init();
  DockerCommander docker = dockerCli.docker;

  // Process build = await Process.start(
  //   "docker",
  //   ["build", "https://github.com/azkadev/specta_userbot_telegram.git#main", "-t", "azkadev/userbot"],
  //   runInShell: true,
  // );
  // print(await build.exitCode);
  // build.stderr.listen((event) {
  //   print(utf8.decode(event));
  // });
  // build.stdout.listen((event) {
  //   print(utf8.decode(event));
  // });

  var buid = await dockerCli.buildImage(
    nameImage: "azkadev/userbot",
    dockerImage:DockerImage.fromDirectory(directory: Directory("../")),
    onData: (dockerProcess) {
      print(dockerProcess.stderr!.asString);
    },
  );
  var res = await docker.command("ps", []);
  print(res!.stdout!.asString);
  // var getall = await docker.psContainerNames();
  // getall ??= [];
  // if (getall.length > 1) {
  //   print(getall);
  //   print("delete");
  //   await docker.stopContainer(getall.first);
  //   var getalls = await docker.psContainerNames();
  //   print(getalls);
  //   return;
  // }
  
  var dockerContainer = await docker.run('azkadev/userbot', containerName: "azkacantip"); 
  // Gets all the STDOUT as [String].
  var output = dockerContainer!.stdout!.asString;

  print(output);
}

class DockerCli {
  late DockerCommander docker;
  DockerCli({DockerCommander? dockerCommander}) {
    dockerCommander ??= DockerCommander(DockerHostLocal());
    docker = dockerCommander;
  }

  Future<void> init() async {
    await docker.initialize();
    await docker.checkDaemon();
  }

  Future<DockerProcess?> buildImage({
    required String nameImage,
    required DockerImage dockerImage,
    void Function(DockerProcess dockerProcess)? onData,
  }) async {
    DockerProcess? re = await docker.command(
      "build",
      [dockerImage.data, "-t", nameImage, "--progress=plain"],
    );

    if (re != null) {
      return await Future.microtask(() async {
        while (true) {
          await Future.delayed(Duration(milliseconds: 10));
          if (re.isFinished) {
            return re;
          } else {
            if (onData != null) {
              onData.call(re);
            }
          }
        }
      });
    }
  }

  Future<List> getAllImages() async {
    return await docker.psContainerNames() ?? [];
  }

  Future<DockerProcess?> remove({required String imageOrId}) async  {
    return await docker.command("rmi", [imageOrId]);
  }
  Future<DockerProcess?> removeAll() async  {
    return await docker.command("rmi", ["\$(docker images -q)", "--force"]);
  }
}

class DockerImage {
  late String data;
  DockerImage(this.data);
  factory DockerImage.fromGit({
    required String url,
    String branch = "master",
  }) {
    return DockerImage("${url}#${branch.toString()}");
  }
  factory DockerImage.fromDirectory({
    required Directory directory,
  }) {
    return DockerImage("${directory.path}");
  }
}
