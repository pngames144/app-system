/// <reference path="../pb_data/types.d.ts" />

// Runs shortly before midnight in the PocketBase server's local timezone.
cronAdd("fail-due-routines", "59 23 * * *", () => {
  const routines = $app.dao().findRecordsByFilter(
    "routines",
    "status != 'Failed' && dueDate <= @now && (lastCompletedDate = '' || lastCompletedDate < dueDate)",
    "",
    500,
    0,
  );

  for (const routine of routines) {
    routine.set("status", "Failed");
    routine.set("streak", 0);
    $app.dao().saveRecord(routine);
  }
});