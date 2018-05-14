FROM ubuntu:16.04
MAINTAINER Yoshiyuki Ieyama <44uk@github.com>

RUN sed -i.bak -e "s%http://[^ ]\+%http://ftp.riken.go.jp/Linux/ubuntu/%g" /etc/apt/sources.list
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
  git \
  curl \
  wget \
  vim \
  autoconf \
  automake \
  apt-file \
  build-essential \
  cmake \
  software-properties-common \
  pkg-config \
  python3 \
  libssl-dev \
  libsasl2-dev \
  libtool \
  libboost-all-dev \
  libgtest-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
  #librocksdb-dev
  #libevent-pthreads-2.0-5 \
  #libevent-dev \
  #libzmq-dev
  #libmongoc-1.0-0 \
  #libmongoc-dev \
  #libmongo-client-dev \

# gcc,g++ 6
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
  && apt-get update && apt-get install -y gcc-6 g++-6 \
  && rm /usr/bin/gcc /usr/bin/g++ \
  && ln -s /usr/bin/gcc-6 /usr/bin/gcc \
  && ln -s /usr/bin/g++-6 /usr/bin/g++

# gcc,g++ 7
# RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
#   && apt-get update && apt-get install -y gcc-7 g++-7 \
#   && rm /usr/bin/gcc /usr/bin/g++ \
#   && ln -s /usr/bin/gcc-7 /usr/bin/gcc \
#   && ln -s /usr/bin/g++-7 /usr/bin/g++

# cmake
# RUN git clone https://gitlab.kitware.com/cmake/cmake.git -b v3.11.1 --depth 1 \
#   && cd cmake \
#   && ./bootstrap --prefix=/usr/local && make -j4 && make install \
#   && cd -

# boost
# RUN git clone --recursive git@github.com:boostorg/boost.git
# cd boost
# ./bootstrap.sh
# ./b2 toolset=gcc-7 --prefix=/usr/local -j5
# sudo ./b2 install toolset=gcc-7 --prefix=/usr/local -j5

# gtest
#RUN git clone https://github.com/google/googletest.git -b release-1.8.0 --depth 1 \
#  && mkdir -p googletest/_build && cd googletest/_build \
#  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install \
#  && cd -
RUN cd /usr/src/gtest && cmake CMakeLists.txt && make -j4 && mv *.a /usr/lib && cd -

# rocksdb
RUN git clone https://github.com/facebook/rocksdb.git -b v5.12.4 --depth 1 \
  && mkdir -p rocksdb/_build && cd rocksdb/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install \
  && cd -

# bson
# RUN git clone https://github.com/mongodb/libbson.git -b 1.9.5 --depth 1 \
#   && cd libbson \
#   && ./autogen.sh && make -j4 && make install \
#   && cd -

# mongo-c
RUN wget https://github.com/mongodb/mongo-c-driver/releases/download/1.9.5/mongo-c-driver-1.9.5.tar.gz \
  && tar xzf mongo-c-driver-1.9.5.tar.gz && cd mongo-c-driver-1.9.5 \
  && ./configure --disable-automatic-init-and-cleanup --prefix=/usr/local \
  && make -j4 && make install \
  && cd -

# mongo-cxx
# && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_FLAGS="-std=gnu++11" .. \
RUN git clone https://github.com/mongodb/mongo-cxx-driver.git -b r3.2.0 --depth 1 \
  && cd mongo-cxx-driver/build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
  && make EP_mnmlstc_core && make -j4 && make install \
  && cd -

# zmqlib
RUN git clone https://github.com/zeromq/libzmq.git -b v4.2.5 --depth 1 \
  && mkdir -p libzmq/_build && cd libzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install \
  && cd -

# cppzmq
RUN git clone https://github.com/zeromq/cppzmq.git -b v4.2.3 --depth 1 \
  && mkdir -p cppzmq/_build && cd cppzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install \
  && cd -

# fix catapult build
COPY fix.patch .

# [x] PYTHON_EXECUTABLE
# BOOST_ROOT
# GTEST_ROOT
# LIBBSONCXX_DIR
# LIBMONGOCXX_DIR
# ZeroMQ_DIR
# cppzmq_DIR

# catapult
RUN git clone https://github.com/nemtech/catapult-server.git -b master --depth 1 \
  && cd catapult-server \
  && mv /fix.patch . && patch -p1 < fix.patch \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DBSONCXX_LIB=/usr/local/lib/libbsoncxx.so \
    -DMONGOCXX_LIB=/usr/local/lib/libmongocxx.so \
    ..
    # -LIBBSONCXX_DIR=/usr/local/lib/ \
    # -LIBMONGOCXX_DIR=/usr/local/lib/ \
    # -DCMAKE_CXX_FLAGS="-std=gnu++11 -Wno-unused-parameter -Wno-c++0x-compat" \
  #&& make publish && make -j4

WORKDIR catapult-server/_build
