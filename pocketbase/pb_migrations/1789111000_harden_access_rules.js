/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const users = app.findCollectionByNameOrId("_pb_users_auth_")
  users.listRule = "id = @request.auth.id"
  users.viewRule = "id = @request.auth.id"
  users.updateRule = "id = @request.auth.id"
  users.deleteRule = "id = @request.auth.id"
  app.save(users)

  const tasks = app.findCollectionByNameOrId("pbc_2602490748")
  const userField = tasks.fields.getByName("user")
  userField.required = true
  userField.maxSelect = 1
  app.save(tasks)

  const currentExp = users.fields.getByName("currentExp")
  currentExp.onlyInt = true
  app.save(users)
}, (app) => {
  const users = app.findCollectionByNameOrId("_pb_users_auth_")
  users.listRule = ""
  users.viewRule = null
  users.updateRule = null
  users.deleteRule = ""
  app.save(users)

  const tasks = app.findCollectionByNameOrId("pbc_2602490748")
  const userField = tasks.fields.getByName("user")
  userField.required = false
  userField.maxSelect = 0
  app.save(tasks)

  const currentExp = users.fields.getByName("currentExp")
  currentExp.onlyInt = false
  app.save(users)
})