/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    createRule: "user = @request.auth.id",
    deleteRule: "user = @request.auth.id",
    listRule: "user = @request.auth.id",
    updateRule: "user = @request.auth.id",
    viewRule: "user = @request.auth.id",
    fields: [
      { autogeneratePattern: "[a-z0-9]{15}", max: 15, min: 15, name: "id", pattern: "^[a-z0-9]+$", primaryKey: true, required: true, system: true, type: "text" },
      { cascadeDelete: true, collectionId: "_pb_users_auth_", maxSelect: 1, name: "user", required: true, type: "relation" },
      { max: 0, min: 0, name: "title", required: true, type: "text" },
      { max: 0, min: 0, name: "description", required: false, type: "text" },
      { max: null, min: 0, name: "expReward", onlyInt: true, required: true, type: "number" },
      { max: null, min: 0, name: "streak", onlyInt: true, required: true, type: "number" },
      { max: 0, min: 0, name: "status", required: true, type: "text" },
      { name: "dueDate", required: true, type: "date" },
      { name: "lastCompletedDate", required: false, type: "date" },
      { name: "created", onCreate: true, onUpdate: false, type: "autodate" },
      { name: "updated", onCreate: true, onUpdate: true, type: "autodate" }
    ],
    indexes: [],
    name: "routines",
    type: "base"
  });
  return app.save(collection);
}, (app) => app.delete(app.findCollectionByNameOrId("routines")));