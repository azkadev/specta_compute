import 'package:docker_commander/docker_commander_vm.dart';

void main() async {
  // A simple username and password table:
  var authenticationTable = AuthenticationTable({'admin': '123'});

  // A `DockerHost` Server at port 8099:
  var hostServer = DockerHostServer(
    (user, pass) async {
      return authenticationTable.checkPassword(user, pass);
    },
    8099,
  );

  // Starts the server and wait initialization:
  await hostServer.startAndWait();
  print("server run");
}
