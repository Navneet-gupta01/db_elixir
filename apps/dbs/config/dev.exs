use Mix.Config

config(:dbs, :bar_database_conf,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "bar",
  name: :bar_db,
  pool: DBConnection.ConnectionPool,
  pool_size: 15
)

config(:dbs, :foo_database_conf,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "foo",
  name: :foo_db,
  pool: DBConnection.ConnectionPool,
  pool_size: 15
)
