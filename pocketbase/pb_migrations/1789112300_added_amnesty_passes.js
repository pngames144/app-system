/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const users = app.findCollectionByNameOrId("_pb_users_auth_");
  users.fields.addAt(13, new Field({
    help: "Available passes reset to 2 at the start of each UTC week.",
    id: "number_amnesty_passes",
    max: 2,
    min: 0,
    name: "amnestyPasses",
    onlyInt: true,
    required: false,
    type: "number"
  }));
  users.fields.addAt(14, new Field({
    id: "date_amnesty_week_start",
    name: "amnestyWeekStart",
    required: false,
    type: "date"
  }));
  return app.save(users);
}, (app) => {
  const users = app.findCollectionByNameOrId("_pb_users_auth_");
  users.fields.removeById("number_amnesty_passes");
  users.fields.removeById("date_amnesty_week_start");
  return app.save(users);
});