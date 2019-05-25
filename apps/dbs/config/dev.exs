use Mix.Config

config :db_bar, :databse_conf,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "bar",
  name: :bar_db,
  pool: DBConnection.ConnectionPool,
  pool_size: 15

config :db_foo, :database_conf,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "foo",
  name: :foo_db,
  pool: DBConnection.ConnectionPool,
  pool_size: 15
