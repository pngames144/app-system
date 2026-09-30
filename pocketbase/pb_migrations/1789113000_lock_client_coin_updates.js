/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const users = app.findCollectionByNameOrId("_pb_users_auth_");
  users.updateRule = "id = @request.auth.id && @request.body.coins = coins";
  return app.save(users);
}, (app) => {
  const users = app.findCollectionByNameOrId("_pb_users_auth_");
  users.updateRule = "id = @request.auth.id";
  return app.save(users);
});