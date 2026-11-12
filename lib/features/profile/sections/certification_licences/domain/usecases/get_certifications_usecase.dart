import '../../../../../../core/result/result.dart';
import '../entities/certification.dart';
import '../repositories/certification_repository.dart';

/// Loads the candidate's certificates and licences.
class GetCertificationsUseCase {
  final CertificationRepository _repository;

  const GetCertificationsUseCase(this._repository);

  Future<Result<List<Certification>>> call() => _repository.getCertifications();
}
