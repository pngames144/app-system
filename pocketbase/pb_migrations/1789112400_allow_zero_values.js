/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const routines = app.findCollectionByNameOrId("routines");
  routines.fields.getByName("streak").required = false;
  app.save(routines);

  const punishments = app.findCollectionByNameOrId("punishments");
  punishments.fields.getByName("value").required = false;
  return app.save(punishments);
}, (app) => {
  const routines = app.findCollectionByNameOrId("routines");
  routines.fields.getByName("streak").required = true;
  app.save(routines);

  const punishments = app.findCollectionByNameOrId("punishments");
  punishments.fields.getByName("value").required = true;
  return app.save(punishments);
});