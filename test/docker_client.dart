import 'package:docker_commander/docker_commander.dart';

void main() async {
  // Connect to a `DockerHost` running at '10.0.0.52:8099'
  var dockerHostRemote = DockerHostRemote('127.0.0.1', 8099, secure: false, username: 'admin', password: '123');

  // Creates a `DockerCommander` for a remote host machine:
  var dockerCommander = DockerCommander(dockerHostRemote);

  // Initialize `DockerCommander` (at remote server):
  await dockerCommander.initialize();
  // Ensure that Docker daemon is running (at remote server):
  await dockerCommander.checkDaemon();

  var getall = await dockerCommander.psContainerNames();
  getall ??= [];
  if (getall.length > 2) {
    await dockerCommander.stopContainer(getall.first);
  }
  print(getall);
  return;
  // Run Docker image `hello-world` (at remote server):
  var dockerContainer = await dockerCommander.run('azka');

  // The behavior is the same of the example using `DockerHostLocal`.
  // The internal `DockerRunner` will sync remote output (stdout/sdterr) automatically!

  // ...

  // Gets all the STDOUT as [String].
  var output = dockerContainer!.stdout!.asString;
  print(output);

  var get_all = await dockerCommander.psContainerNames();
  print(get_all);
  // ...
}
