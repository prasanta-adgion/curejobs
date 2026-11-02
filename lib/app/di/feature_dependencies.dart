import 'package:get_it/get_it.dart';

import '../../features/auth/login/di/login_dependencies.dart';

void registerFeatureDependencies(GetIt sl) {
  registerLoginDependencies(sl);
}
