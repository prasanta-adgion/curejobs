import 'package:get_it/get_it.dart';

import 'core_dependencies.dart';
import 'feature_dependencies.dart';

final sl = GetIt.instance;

void configureDependencies() {
  registerCoreDependencies(sl);
  registerFeatureDependencies(sl);
}
