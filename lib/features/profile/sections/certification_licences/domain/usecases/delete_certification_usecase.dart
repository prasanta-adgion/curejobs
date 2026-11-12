import '../../../../../../core/result/result.dart';
import '../repositories/certification_repository.dart';

/// Removes one certificate by id.
class DeleteCertificationUseCase {
  final CertificationRepository _repository;

  const DeleteCertificationUseCase(this._repository);

  Future<Result<void>> call(String id) => _repository.deleteCertification(id);
}
