import 'package:docker_commander/docker_commander_vm.dart';

void main() async {
  // Creates a `DockerCommander` for a local host machine:
  var dockerCommander = DockerCommander(DockerHostLocal());
  
  // Initialize `DockerCommander`:
  await dockerCommander.initialize();
  // Ensure that Docker daemon is running.
  await dockerCommander.checkDaemon();

  // Run Docker image `hello-world`:
  var dockerContainer = await dockerCommander.run('azka');

  // Waits the container to exit, and gets the exit code:
  var exitCode = await dockerContainer!.waitExit();
  
  // Gets all the STDOUT as [String]. 
  var output = dockerContainer.stdout!.asString;
  
  print(output);
  print('EXIT CODE: $exitCode');
}