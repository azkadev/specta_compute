import 'package:docker_process/docker_process.dart';

Future main() async {
  final dp = await DockerProcess.start(
    image: 'ubuntu',
    name: 'azka',
    readySignal: (line) => line.contains('Done.'),
  );
  final pr = await dp.exec(['ls', '-l']);
  print(pr.stdout);
  await dp.stop();
}