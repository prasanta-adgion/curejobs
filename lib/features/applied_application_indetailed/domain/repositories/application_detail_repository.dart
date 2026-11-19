import '../../../../core/result/result.dart';
import '../entities/application_detail.dart';

abstract interface class ApplicationDetailRepository {
  Future<Result<ApplicationDetail>> getApplication(String id);
}
