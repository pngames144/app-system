/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const settings = app.settings();
  settings.batch.enabled = true;
  settings.batch.maxRequests = 50;
  settings.batch.timeout = 3;
  return app.save(settings);
}, (app) => {
  const settings = app.settings();
  settings.batch.enabled = false;
  return app.save(settings);
});