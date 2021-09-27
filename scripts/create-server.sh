#! /bin/bash

az sql server create \
  --resource-group aaron-resource-group \
  --name codesanook-example-db-server \
  --admin-user codesanook-example-sa \
  --admin-password 