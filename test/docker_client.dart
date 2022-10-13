import 'package:docker_commander/docker_commander.dart';

void main() async {

  // Connect to a `DockerHost` running at '10.0.0.52:8099'
  var dockerHostRemote = DockerHostRemote('127.0.0.1', 8099, username: 'admin', password: '123');

  // Creates a `DockerCommander` for a remote host machine:
  var dockerCommander = DockerCommander(dockerHostRemote);
  
  // Initialize `DockerCommander` (at remote server):
  await dockerCommander.initialize();
  // Ensure that Docker daemon is running (at remote server):
  await dockerCommander.checkDaemon();

  // Run Docker image `hello-world` (at remote server):
  var dockerContainer = await dockerCommander.run('azka');

  // The behavior is the same of the example using `DockerHostLocal`.
  // The internal `DockerRunner` will sync remote output (stdout/sdterr) automatically!

  // ...
  
  // Gets all the STDOUT as [String]. 
  var output = dockerContainer!.stdout!.asString;
  print(output);
  print("azka");
  
  // ...
  
}