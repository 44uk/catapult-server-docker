FROM ubuntu:18.04
MAINTAINER Yoshiyuki Ieyama <44uk@github.com>

WORKDIR /tmp

RUN sed -i.bak -e "s%http://[^ ]\+%http://linux.yz.yamagata-u.ac.jp/ubuntu/%g" /etc/apt/sources.list
RUN apt-get update -y && apt-get upgrade -y && apt-get clean && apt-get install -y --no-install-recommends \
  git \
  curl \
  wget \
  vim \
  autoconf \
  automake \
  apt-file \
  build-essential \
  cmake \
  googletest \
  software-properties-common \
  pkg-config \
  python3 \
  libboost-all-dev \
  librocksdb-dev \
  libgtest-dev \
  libssl-dev \
  libsasl2-dev \
  libtool \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# zmqlib
RUN git clone https://github.com/zeromq/libzmq.git -b v4.2.3 --depth 1 \
  && mkdir -p libzmq/_build && cd libzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install \
  && cd -

# cppzmq
RUN git clone https://github.com/zeromq/cppzmq.git -b v4.2.3 --depth 1 \
  && mkdir -p cppzmq/_build && cd cppzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install \
  && cd -

# mongo-c
RUN git clone https://github.com/mongodb/mongo-c-driver.git -b 1.4.3 --depth 1 && cd mongo-c-driver \
  && ./autogen.sh && ./configure --disable-automatic-init-and-cleanup --prefix=/usr/local \
  && make -j4 && make install \
  && cd -

# mongo-cxx
RUN git clone https://github.com/mongodb/mongo-cxx-driver.git -b r3.0.2 --depth 1 && cd mongo-cxx-driver/build \
  && cmake -DBSONCXX_POLY_USE_BOOST=1 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
  && make -j4 && make install \
  && cd -

# gtest
RUN cd /usr/src/gtest && cmake CMakeLists.txt && make && cp *.a /usr/lib && cd -

# catapult
RUN git clone https://github.com/nemtech/catapult-server.git -b master --depth 1 \
  && cd catapult-server \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
    -DCMAKE_CXX_FLAGS="-pthread" \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DBSONCXX_LIB=/usr/local/lib/libbsoncxx.so \
    -DMONGOCXX_LIB=/usr/local/lib/libmongocxx.so \
    .. \
  && make publish && make -j4

# ------------------------------------
# ここから先は作業用に都合よくやっている
# 行儀が良いとは思ってないよ

COPY patch/config-user.patch .
RUN cd catapult-server \
  && patch -p1 < /tmp/config-user.patch \
  && mkdir -p seed/mijin-test \
  && mkdir data \
  && cd _build \
  && mv resources resources.bk \
  && cp -r ../resources .

  # # To generate nemesis block
  # ./bin/catapult.tools.nemgen ../tools/nemgen/resources/mijin-test.properties \
  # cp -r ../seed/mijin-test/00000 ../data/
  # bin/catapult.server

WORKDIR catapult-server/_build
