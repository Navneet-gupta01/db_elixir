use Mix.Config

config :db_foo, :databse_conf,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "foo",
  name: :foo_db,
  pool: DBConnection.ConnectionPool,
  pool_size: 15
