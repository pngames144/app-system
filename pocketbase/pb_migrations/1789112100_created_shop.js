/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const shop = new Collection({
    createRule: null,
    deleteRule: null,
    listRule: "",
    updateRule: null,
    viewRule: "",
    fields: [
      { autogeneratePattern: "[a-z0-9]{15}", max: 15, min: 15, name: "id", pattern: "^[a-z0-9]+$", primaryKey: true, required: true, system: true, type: "text" },
      { max: 0, min: 0, name: "name", required: true, type: "text" },
      { max: null, min: 0, name: "price", onlyInt: true, required: true, type: "number" },
      { max: 0, min: 0, name: "category", required: true, type: "text" },
      { max: 0, min: 0, name: "item", required: true, type: "text" },
      { name: "created", onCreate: true, onUpdate: false, type: "autodate" },
      { name: "updated", onCreate: true, onUpdate: true, type: "autodate" }
    ],
    indexes: [],
    name: "shop",
    type: "base"
  });
  app.save(shop);

  const purchases = new Collection({
    createRule: "user = @request.auth.id",
    deleteRule: null,
    listRule: "user = @request.auth.id",
    updateRule: null,
    viewRule: "user = @request.auth.id",
    fields: [
      { autogeneratePattern: "[a-z0-9]{15}", max: 15, min: 15, name: "id", pattern: "^[a-z0-9]+$", primaryKey: true, required: true, system: true, type: "text" },
      { cascadeDelete: true, collectionId: "_pb_users_auth_", maxSelect: 1, name: "user", required: true, type: "relation" },
      { cascadeDelete: false, collectionId: shop.id, maxSelect: 1, name: "item", required: true, type: "relation" },
      { max: null, min: 0, name: "price", onlyInt: true, required: true, type: "number" },
      { name: "created", onCreate: true, onUpdate: false, type: "autodate" },
      { name: "updated", onCreate: true, onUpdate: true, type: "autodate" }
    ],
    indexes: [],
    name: "purchases",
    type: "base"
  });
  return app.save(purchases);
}, (app) => {
  app.delete(app.findCollectionByNameOrId("purchases"));
  return app.delete(app.findCollectionByNameOrId("shop"));
});