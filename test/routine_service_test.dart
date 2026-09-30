import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/services/routine_service.dart';

void main() {
  test('starts a routine streak at one', () {
    final today = DateTime.utc(2026, 9, 30);

    expect(
      RoutineService.nextStreak(
        previousStreak: 0,
        lastCompletedDate: null,
        today: today,
      ),
      1,
    );
  });

  test('increments a streak after completion on the previous day', () {
    final today = DateTime.utc(2026, 9, 30);

    expect(
      RoutineService.nextStreak(
        previousStreak: 4,
        lastCompletedDate: DateTime.utc(2026, 9, 29, 22),
        today: today,
      ),
      5,
    );
  });

  test('resets a streak after a missed day', () {
    final today = DateTime.utc(2026, 9, 30);

    expect(
      RoutineService.nextStreak(
        previousStreak: 4,
        lastCompletedDate: DateTime.utc(2026, 9, 27),
        today: today,
      ),
      1,
    );
  });
}