import 'package:curejobs/core/error/failure.dart';
import 'package:curejobs/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guard wraps values and maps thrown errors', () async {
    final ok = await Result.guard(() async => 3);
    final err = await Result.guard<int>(
      () async => throw const FormatException(),
    );

    expect(ok.valueOrNull, 3);
    expect(err.failureOrNull, isA<ParsingFailure>());
  });

  test('fold and map', () {
    const Result<int> ok = Result.ok(2);
    const Result<int> err = Result.err(NetworkFailure());

    expect(ok.map((v) => v * 2).valueOrNull, 4);
    expect(err.map((v) => v * 2).failureOrNull, isA<NetworkFailure>());
    expect(
      err.fold((_) => 'ok', (f) => f.message),
      const NetworkFailure().message,
    );
  });
}
