import '../../../../core/result/result.dart';
import '../entities/candidate.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class CandidateRepository {
  Future<Result<Candidate>> getMyProfile();
}
