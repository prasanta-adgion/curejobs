import '../../../../core/result/result.dart';
import '../repositories/apply_application_repository.dart';

/// Withdraws one of the candidate's applications.
class WithdrawApplicationUseCase {
  final ApplyApplicationRepository _repository;

  const WithdrawApplicationUseCase(this._repository);

  Future<Result<void>> call(String applicationId) =>
      _repository.withdrawApplication(applicationId);
}
