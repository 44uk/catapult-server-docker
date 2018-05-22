# Catapult Docker

[nemtech/catapult\-server: Catapult server](https://github.com/nemtech/catapult-server) has no documentation. This is an experimental way.


## build image

```
docker build -t catapult .
```

## run image example

```
# address generation
$ docker run --rm catapult catapult.tools.address

# generate random hashes.dat
mkdir -p seed/mijin-test/00000
dd if=/dev/random of=seed/mijin-test/00000/hashes.dat bs=1 count=64

# nemesis block generation
$ docker run --rm \
  -v$(pwd)/resources:/tmp/catapult-server/_build/resources \
  -v$(pwd)/tools:/tmp/catapult-server/_build/tools \
  -v$(pwd)/seed/mijin-test:/tmp/catapult-server/_build/seed/mijin-test \
  catapult catapult.tools.nemgen -r ../tools/nemgen/resources/mijin-test.my.properties

# move generated block
$ mkdir data && mv seed/mijin-test/00000 data/

# catapult server
$ docker run \
  -p 7900:7900 -p 7901:7901 \
  -v$(pwd)/resources:/tmp/catapult-server/_build/resources \
  -v$(pwd)/data:/tmp/catapult-server/_build/data \
  catapult catapult.server

# interactive shell
$ docker run --rm -it catapult bash
```

Change resources/*.properties as you like.

### run server

```
# To generate nemesis block
$ ./bin/catapult.tools.nemgen ../tools/nemgen/resources/mijin-test.properties \
$ cp -r ../seed/mijin-test/00000 ../data/
# Boot server
$ bin/catapult.server
```

## require environment (maybe)

* cmake: 3.11.1
* boost: 1.65.1
* mongoc 1.4.3
* mongo-cxx 3.0.2
* gtest: 1.8.0
* libzmq: 4.2.3
* cppzmq: 4.2.3

## notes

### mongo-cxx

pass the option when building mongo-cxx.

```
-DBSONCXX_POLY_USE_BOOST=1
```

### catapult-server

need additional options.

```
-DMONGOCXX_LIB=/path/to/libmongocxx.so
-DBSONCXX_LIB=/path/to/libbsoncxx.so
```
