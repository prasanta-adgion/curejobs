// 	Application entry point

import 'package:curejobs/app/config/environment.dart';

import 'bootstrap.dart';

Future<void> main() async {
  await bootstrap(Environment.prod);
}
