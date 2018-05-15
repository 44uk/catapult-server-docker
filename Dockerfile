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
  libgtest-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
  #libboost-all-dev \
  #librocksdb-dev
  #libevent-pthreads-2.0-5 \
  #libevent-dev \
  #libzmq-dev
  #libmongoc-1.0-0 \
  #libmongoc-dev \
  #libmongo-client-dev \

# cmake
RUN git clone https://gitlab.kitware.com/cmake/cmake.git -b v3.11.1 --depth 1 \
  && cd cmake \
  && ./bootstrap --prefix=/usr && make -j4 && make install \
  && cd -

# gcc,g++ 6
# RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
#   && apt-get update && apt-get install -y gcc-6 g++-6 \
#   && rm /usr/bin/gcc /usr/bin/g++ \
#   && ln -s /usr/bin/gcc-6 /usr/bin/gcc \
#   && ln -s /usr/bin/g++-6 /usr/bin/g++

# gcc,g++ 7
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
  && apt-get update && apt-get install -y gcc-7 g++-7 \
  && rm /usr/bin/gcc /usr/bin/g++ \
  && ln -s /usr/bin/gcc-7 /usr/bin/gcc \
  && ln -s /usr/bin/g++-7 /usr/bin/g++

# boost
RUN wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz \
  && tar xzf boost_1_67_0.tar.gz && cd boost_1_67_0 \
  && ./bootstrap.sh \
  && ./b2 install toolset=gcc-7 --prefix=/usr -j4 \
  && cd -

# rocksdb
RUN git clone https://github.com/facebook/rocksdb.git -b v5.12.4 --depth 1 \
  && mkdir -p rocksdb/_build && cd rocksdb/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
  && cd -

# bson
# RUN git clone https://github.com/mongodb/libbson.git -b 1.9.5 --depth 1 \
#   && cd libbson \
#   && ./autogen.sh && make -j4 && make install \
#   && cd -

# mongo-c
RUN wget https://github.com/mongodb/mongo-c-driver/releases/download/1.9.5/mongo-c-driver-1.9.5.tar.gz \
  && tar xzf mongo-c-driver-1.9.5.tar.gz && cd mongo-c-driver-1.9.5 \
  && ./configure --disable-automatic-init-and-cleanup --prefix=/usr \
  && make -j4 && make install \
  && cd -

# mongo-cxx
# && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_FLAGS="-std=gnu++11" .. \
RUN git clone https://github.com/mongodb/mongo-cxx-driver.git -b r3.2.0 --depth 1 \
  && cd mongo-cxx-driver/build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. \
  && make EP_mnmlstc_core -j4 && make install \
  && cd -

# zmqlib
RUN git clone https://github.com/zeromq/libzmq.git -b v4.2.3 --depth 1 \
  && mkdir -p libzmq/_build && cd libzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
  && cd -

# cppzmq
RUN git clone https://github.com/zeromq/cppzmq.git -b v4.2.3 --depth 1 \
  && mkdir -p cppzmq/_build && cd cppzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
  && cd -

# gtest
#RUN git clone https://github.com/google/googletest.git -b release-1.8.0 --depth 1 \
#  && mkdir -p googletest/_build && cd googletest/_build \
#  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install \
#  && cd -
RUN cd /usr/src/gtest && cmake CMakeLists.txt && make -j4 && mv *.a /usr/lib && cd -

# fix catapult build
COPY fix.patch .

# [x] PYTHON_EXECUTABLE
# [] BOOST_ROOT=/usr/include/boost
# [] GTEST_ROOT
# [] LIBBSONCXX_DIR=/usr/include/bsoncxx/
# [] LIBMONGOCXX_DIR=/usr/include/mongocxx/
# [] ZeroMQ_DIR
# [] cppzmq_DIR

# catapult
RUN git clone https://github.com/nemtech/catapult-server.git -b master --depth 1 \
  && cd catapult-server \
  && mv /fix.patch . && patch -p1 < fix.patch \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DBSONCXX_LIB=/usr/lib/libbsoncxx.so \
    -DMONGOCXX_LIB=/usr/lib/libmongocxx.so \
    .. \
  && make publish && VERBOSE=1 make
    # -DCMAKE_CXX_FLAGS="-std=c++2a -Wno-unused-parameter -Wno-c++0x-compat" \
    # -DCMAKE_CXX_FLAGS="-std=c++14 -Wno-unused-parameter -Wno-c++0x-compat" \
    # -DCMAKE_CXX_FLAGS="-std=gnu++17 -Wno-unused-parameter -Wno-c++0x-compat" \
    # -DBOOST_ROOT=/usr/include/boost \
    # -DLIBBSONCXX_DIR=/usr/include/bsoncxx/ \
    # -DLIBMONGOCXX_DIR=/usr/include/mongocxx/ \

WORKDIR catapult-server/_build
