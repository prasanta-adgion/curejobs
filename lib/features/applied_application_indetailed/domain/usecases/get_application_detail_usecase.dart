import '../../../../core/result/result.dart';
import '../entities/application_detail.dart';
import '../repositories/application_detail_repository.dart';

/// Loads one of the candidate's applications with all its details.
class GetApplicationDetailUseCase {
  final ApplicationDetailRepository _repository;

  const GetApplicationDetailUseCase(this._repository);

  Future<Result<ApplicationDetail>> call(String applicationId) =>
      _repository.getApplication(applicationId);
}
