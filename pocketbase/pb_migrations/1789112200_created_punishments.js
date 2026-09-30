/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const punishments = new Collection({
    createRule: "user = @request.auth.id",
    deleteRule: null,
    listRule: "user = @request.auth.id",
    updateRule: null,
    viewRule: "user = @request.auth.id",
    fields: [
      { autogeneratePattern: "[a-z0-9]{15}", max: 15, min: 15, name: "id", pattern: "^[a-z0-9]+$", primaryKey: true, required: true, system: true, type: "text" },
      { cascadeDelete: true, collectionId: "_pb_users_auth_", maxSelect: 1, name: "user", required: true, type: "relation" },
      { cascadeDelete: true, collectionId: app.findCollectionByNameOrId("routines").id, maxSelect: 1, name: "routine", required: true, type: "relation" },
      { max: 0, min: 0, name: "type", required: true, type: "text" },
      { max: 0, min: 0, name: "description", required: false, type: "text" },
      { max: null, min: 0, name: "value", onlyInt: true, required: true, type: "number" },
      { max: 0, min: 0, name: "status", required: true, type: "text" },
      { name: "created", onCreate: true, onUpdate: false, type: "autodate" },
      { name: "updated", onCreate: true, onUpdate: true, type: "autodate" }
    ],
    indexes: [],
    name: "punishments",
    type: "base"
  });
  app.save(punishments);

  const logs = new Collection({
    createRule: "user = @request.auth.id",
    deleteRule: null,
    listRule: "user = @request.auth.id",
    updateRule: null,
    viewRule: "user = @request.auth.id",
    fields: [
      { autogeneratePattern: "[a-z0-9]{15}", max: 15, min: 15, name: "id", pattern: "^[a-z0-9]+$", primaryKey: true, required: true, system: true, type: "text" },
      { cascadeDelete: true, collectionId: "_pb_users_auth_", maxSelect: 1, name: "user", required: true, type: "relation" },
      { cascadeDelete: false, collectionId: app.findCollectionByNameOrId("punishments").id, maxSelect: 1, name: "punishment", required: false, type: "relation" },
      { max: 0, min: 0, name: "eventType", required: true, type: "text" },
      { max: 0, min: 0, name: "details", required: true, type: "text" },
      { name: "created", onCreate: true, onUpdate: false, type: "autodate" },
      { name: "updated", onCreate: true, onUpdate: true, type: "autodate" }
    ],
    indexes: [],
    name: "event_logs",
    type: "base"
  });
  return app.save(logs);
}, (app) => {
  app.delete(app.findCollectionByNameOrId("event_logs"));
  return app.delete(app.findCollectionByNameOrId("punishments"));
});