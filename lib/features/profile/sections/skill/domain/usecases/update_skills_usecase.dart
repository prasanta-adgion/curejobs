import '../../../../../../core/result/result.dart';
import '../entities/skill.dart';
import '../repositories/skill_repository.dart';

/// Brings the saved skills in line with the list the user chose.
///
/// The API adds and removes one skill at a time, so this works out what
/// changed: skills missing from [names] are deleted, then new names are
/// added in order. Names are compared case-insensitively. Stops at the
/// first failure; the caller should reload to show what was saved.
class UpdateSkillsUseCase {
  final SkillRepository _repository;

  const UpdateSkillsUseCase(this._repository);

  Future<Result<void>> call({
    required List<Skill> current,
    required List<String> names,
  }) async {
    final wanted = {for (final n in names) n.trim().toLowerCase()};
    final existing = {for (final s in current) s.normalizedName.toLowerCase()};

    final toDelete = current.where(
      (s) =>
          s.id.isNotEmpty && !wanted.contains(s.normalizedName.toLowerCase()),
    );
    final toAdd = <String>[];
    final queued = <String>{};
    for (final raw in names) {
      final name = raw.trim();
      final key = name.toLowerCase();
      if (name.isEmpty || existing.contains(key) || !queued.add(key)) continue;
      toAdd.add(name);
    }

    for (final skill in toDelete) {
      final result = await _repository.deleteSkill(skill.id);
      if (!result.isOk) return result;
    }
    for (final name in toAdd) {
      final result = await _repository.addSkill(name);
      if (!result.isOk) return result;
    }
    return const Result.ok(null);
  }
}
