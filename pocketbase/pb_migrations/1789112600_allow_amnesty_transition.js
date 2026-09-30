/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const punishments = app.findCollectionByNameOrId("punishments");
  punishments.updateRule = "user = @request.auth.id && status = 'Pending' && @request.body.status = 'Amnestied'";
  return app.save(punishments);
}, (app) => {
  const punishments = app.findCollectionByNameOrId("punishments");
  punishments.updateRule = null;
  return app.save(punishments);
});