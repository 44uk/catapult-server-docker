FROM ubuntu:18.04
MAINTAINER Yoshiyuki Ieyama <44uk@github.com>

WORKDIR /tmp

RUN sed -i.bak -e "s%http://[^ ]\+%http://linux.yz.yamagata-u.ac.jp/ubuntu/%g" /etc/apt/sources.list
RUN apt-get update -y && apt-get upgrade -y && apt-get clean && apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  git \
  build-essential \
  ca-certificates \
  cmake \
  googletest \
  python3 \
  libboost-all-dev \
  librocksdb-dev \
  libgtest-dev \
  libtool \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# zmqlib
RUN git clone https://github.com/zeromq/libzmq.git -b v4.2.3 --depth 1 \
  && mkdir -p libzmq/_build && cd libzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make test && make install \
  && cd - && rm -rf libzmq && ldconfig

# cppzmq
RUN git clone https://github.com/zeromq/cppzmq.git -b v4.2.3 --depth 1 \
  && mkdir -p cppzmq/_build && cd cppzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. \
  && make -j4 && make install \
  && cd - && rm -rf cppzmq

# mongo-c
RUN git clone https://github.com/mongodb/mongo-c-driver.git -b 1.4.3 --depth 1 && cd mongo-c-driver \
  && ./autogen.sh --with-libbson=bundled && ./configure --disable-automatic-init-and-cleanup --prefix=/usr/local \
  && make -j4 && make install \
  && cd - && rm -rf mongo-c-driver

# mongo-cxx
RUN git clone https://github.com/mongodb/mongo-cxx-driver.git -b r3.0.2 --depth 1 && cd mongo-cxx-driver/build \
  && cmake -DBSONCXX_POLY_USE_BOOST=1 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
  && make -j4 && make install \
  && cd - && rm -rf mongo-cxx-driver

# gtest
RUN cd /usr/src/gtest && cmake CMakeLists.txt && make -j4 && cp *.a /usr/lib

# catapult
RUN git clone https://github.com/nemtech/catapult-server.git -b master --depth 1 \
  && cd catapult-server \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DBSONCXX_LIB=/usr/local/lib/libbsoncxx.so \
    -DMONGOCXX_LIB=/usr/local/lib/libmongocxx.so \
    .. \
  && make publish && make -j4

ENV PATH $PATH:/tmp/catapult-server/_build/bin
WORKDIR /tmp/catapult-server/_build/bin
