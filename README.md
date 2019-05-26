# DbTest

## Running the application

## configuration

```
vi apps/dbs/config/config.exs
vi apps/dbs/config/dev.exs
```

### Checking Out the code.
```
git clone https://github.com/Navneet-gupta01/db_elixir.git
cd db_elixir
```


## Testing The application
```
mix test
```

### Creating DB and Schema
```
mix init
```

### Seeding Databse Foo
# One Way
```
iex -S mix
iex> Dbs.Program.import
```

# Another Way
```
time mix run -e "Dbs.Program.import"
```


### Faster Way of Seeding Databse Foo( Using COPY method)
# One Way
```
iex -S mix
iex> Dbs.Program.import_copy
```

# Another Way
```
time mix run -e "Dbs.Program.import_copy"
```

### Migrating Data from FOO(source) to BAR(dest)
# One Way
```
iex -S mix
iex> Dbs.Program.copy_from_foo_to_bar
```

# Another Way
```
time mix run -e "Dbs.Program.copy_from_foo_to_bar"
```


# Accessing Rest Apis
```
iex -S mix
```
### Or
```
mix run --no-halt
```


### Rest Apis Specs

```
curl -vvv http://localhost:9000/dbs/bar/tables/dest\?from_id\=999990

curl -vvv http://localhost:9000/dbs/foo/tables/source\?from_id\=999990
```
* `from_id` is Optional Query param default to `0`, it will start streaming from start.


```
Response:

$ curl -vvv http://localhost:9000/dbs/foo/tables/source\?from_id\=999990
*   Trying ::1...
* TCP_NODELAY set
* Connection failed
* connect to ::1 port 9000 failed: Connection refused
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 9000 (#0)
> GET /dbs/foo/tables/source?from_id=999990 HTTP/1.1
> Host: localhost:9000
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-type: text/event-stream; charset=utf-8
< date: Sun, 26 May 2019 04:44:14 GMT
< server: Cowboy
< transfer-encoding: chunked
<
a,b,c
999991, 1, 1
999992, 2, 2
999993, 0, 3
999994, 1, 4
999995, 2, 0
999996, 0, 1
999997, 1, 2
999998, 2, 3
999999, 0, 4
1000000, 1, 0
```


# Further Improvement that can be worked on.
* While Streaming data through Http Api's, DB's is checked frequently for any update. It could be avoided using A Pub-Sub channel. Http_Api can subscribe to different sources (here dest/source tables changes.). And once record are inserted a event could be published to the corresponding subscriber.
