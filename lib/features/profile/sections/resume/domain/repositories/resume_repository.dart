import '../../../../../../core/result/result.dart';
import '../entities/resume.dart';

abstract interface class ResumeRepository {
  Future<Result<List<Resume>>> getResumes();

  Future<Result<String>> getFileAccessUrl({required String fileId});

  Future<Result<void>> setDefault({required String resumeId});

  Future<Result<void>> deleteResume({required String resumeId});
}
