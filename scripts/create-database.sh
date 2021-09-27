az sql db create \
  --resource-group aaron-resource-group \
  --server codesanook-example-db-server \
  --name codesanook-db \
  --catalog-collation SQL_Latin1_General_CP1_CI_AS \
  --collation SQL_Latin1_General_CP1_CI_AS \
  --capacity 5 \
  --max-size 2GB \
  --edition Basic \
  --backup-storage-redundancy Zone