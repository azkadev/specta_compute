part of specta_pass;

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

  Future<DockerProcess?> remove({required String imageOrId}) async {
    return await docker.command("rmi", [imageOrId]);
  }

  Future<DockerProcess?> removeAll() async {
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
