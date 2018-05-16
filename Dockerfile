FROM ubuntu:16.04
MAINTAINER Yoshiyuki Ieyama <44uk@github.com>

WORKDIR /tmp
COPY pkgs/ /tmp/

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
  software-properties-common \
  pkg-config \
  python3 \
  libc6-dev \
  libssl-dev \
  libsasl2-dev \
  libtool \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
  #cmake \
  #libgtest-dev \
  #libopenthreads-dev
  #libboost-all-dev \
  #librocksdb-dev
  #libevent-pthreads-2.0-5 \
  #libevent-dev \
  #libzmq-dev
  #libmongoc-1.0-0 \
  #libmongoc-dev \
  #libmongo-client-dev \


# cmake
RUN tar xzf cmake-v3.11.1.tar.gz && cd cmake-v3.11.1 \
  && ./bootstrap --prefix=/usr && make -j4 && make install \
  && cd /tmp
#RUN git clone https://gitlab.kitware.com/cmake/cmake.git -b v3.11.1 --depth 1 \
#  && cd cmake \
#  && ./bootstrap --prefix=/usr && make -j4 && make install \
#  && cd -


# gtest
RUN tar xzf googletest-release-1.8.0.tar.gz && cd googletest-release-1.8.0 \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
  && cd /tmp
#RUN cd /usr/src/gtest && cmake CMakeLists.txt && make -j4 && mv *.a /usr/lib && cd -
#RUN git clone https://github.com/google/googletest.git -b release-1.8.0 --depth 1 \
#  && mkdir -p googletest/_build && cd googletest/_build \
#  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install \
#  && cd -


# gcc,g++ 7
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
  && apt-get update && apt-get install -y gcc-7 g++-7 \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && rm /usr/bin/gcc /usr/bin/g++ \
  && ln -s /usr/bin/gcc-7 /usr/bin/gcc \
  && ln -s /usr/bin/g++-7 /usr/bin/g++


# gcc,g++ 6
# RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
#   && apt-get update && apt-get install -y gcc-6 g++-6 \
#   && rm /usr/bin/gcc /usr/bin/g++ \
#   && ln -s /usr/bin/gcc-6 /usr/bin/gcc \
#   && ln -s /usr/bin/g++-6 /usr/bin/g++


# rocksdb
RUN tar xzf rocksdb-5.12.4.tar.gz && cd rocksdb-5.12.4 \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
  && cd -
#RUN git clone https://github.com/facebook/rocksdb.git -b v5.12.4 --depth 1 \
#  && mkdir -p rocksdb/_build && cd rocksdb/_build \
#  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
#  && cd -


# boost
# error: conflicting declaration 'typedef class boost::asio::io_context boost::asio::io_service'
# このエラーが出た。回避するためには1.65系がいいみたい
RUN tar xzf boost_1_65_1.tar.gz && cd boost_1_65_1 \
  && ./bootstrap.sh && ./b2 toolset=gcc install --prefix=/usr -j4 \
  && cd /tmp


# bson
# RUN git clone https://github.com/mongodb/libbson.git -b 1.9.5 --depth 1 \
#   && cd libbson \
#   && ./autogen.sh && make -j4 && make install \
#   && cd -


# zmqlib
RUN tar xzf libzmq-4.2.3.tar.gz && cd libzmq-4.2.3 \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
  && cd /tmp
#RUN git clone https://github.com/zeromq/libzmq.git -b v4.2.3 --depth 1 \
#  && mkdir -p libzmq/_build && cd libzmq/_build \
#  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
#  && cd -


# cppzmq
RUN tar xzf cppzmq-4.2.3.tar.gz && cd cppzmq-4.2.3 \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
  && cd /tmp
#RUN git clone https://github.com/zeromq/cppzmq.git -b v4.2.3 --depth 1 \
#  && mkdir -p cppzmq/_build && cd cppzmq/_build \
#  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
#  && cd -


# mongo-c
RUN tar xzf mongo-c-driver-1.8.1.tar.gz && cd mongo-c-driver-1.8.1 \
  && ./configure --disable-automatic-init-and-cleanup --prefix=/usr \
  && make -j4 && make install \
  && cd /tmp
#RUN wget https://github.com/mongodb/mongo-c-driver/releases/download/1.9.5/mongo-c-driver-1.9.5.tar.gz \
#  && tar xzf mongo-c-driver-1.9.5.tar.gz && cd mongo-c-driver-1.9.5 \
#  && ./configure --disable-automatic-init-and-cleanup --prefix=/usr \
#  && make -j4 && make install \
#  && cd -


# mongo-cxx
RUN tar xzf mongo-cxx-driver-r3.1.4.tar.gz && cd mongo-cxx-driver-r3.1.4 \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 && make install \
  && cd /tmp
#RUN git clone https://github.com/mongodb/mongo-cxx-driver.git -b r3.2.0 --depth 1 \
#  && cd mongo-cxx-driver/build \
#  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. \
#  && make EP_mnmlstc_core -j4 && make install \
#  && cd -



#RUN wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz \
#  && tar xzf boost_1_65_1.tar.gz && cd boost_1_65_1 \
#  && ./bootstrap.sh && ./b2 toolset=gcc install --prefix=/usr -j4 \
#  && cd -

# fix catapult build
# COPY fix.patch .

# [] PYTHON_EXECUTABLE
# [] BOOST_ROOT
# [] GTEST_ROOT
# [] LIBBSONCXX_DIR
# [] LIBMONGOCXX_DIR
# [] ZeroMQ_DIR
# [] cppzmq_DIR


# catapult
RUN tar xzf catapult-server-0.1.0.1.tar.gz && cd catapult-server-0.1.0.1 \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
    -DCMAKE_CXX_FLAGS="-pthread" \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DBSONCXX_LIB=/usr/lib/libbsoncxx.so \
    -DMONGOCXX_LIB=/usr/lib/libmongocxx.so \
    .. \
  && make publish
  # && VERBOSE=1 make

    # -DLIBBSONCXX_DIR=/usr/include \
    # -DLIBMONGOCXX_DIR=/usr/include \
    # -DLIBBSONCXX_DIR=/usr/include/bsoncxx \
    # -DLIBMONGOCXX_DIR=/usr/include/mongocxx \
    # -DLIBBSONCXX_DIR=/usr/include/bsoncxx/v_noabi \
    # -DLIBMONGOCXX_DIR=/usr/include/mongocxx/v_noabi \
    # -DLIBBSONCXX_DIR=/usr/include/bsoncxx/v_noabi/bsoncxx/ \
    # -DLIBMONGOCXX_DIR=/usr/include/mongocxx/v_noabi/mongocxx/ \
    # -DBSONCXX_LIB=/usr/lib/libbsoncxx.so \
    # -DMONGOCXX_LIB=/usr/lib/libmongocxx.so \



#RUN git clone https://github.com/nemtech/catapult-server.git -b master --depth 1 \
#  && cd catapult-server \
#  && mkdir _build && cd _build

  # && cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
  #   -DPYTHON_EXECUTABLE=/usr/bin/python3 \
  #   -DBSONCXX_LIB=/usr/lib/libbsoncxx.so \
  #   -DMONGOCXX_LIB=/usr/lib/libmongocxx.so \
  #   .. \
  # && make publish && make
  # && make publish && VERBOSE=1 make
  # -DCMAKE_CXX_FLAGS="-std=gnu++1z -Wno-unused-parameter -Wno-c++0x-compat" \
  # -DCMAKE_CXX_FLAGS="-std=c++2a -Wno-unused-parameter -Wno-c++0x-compat" \
  # -DCMAKE_CXX_FLAGS="-std=c++14 -Wno-unused-parameter -Wno-c++0x-compat" \
  # -DCMAKE_CXX_FLAGS="-std=gnu++17 -Wno-unused-parameter -Wno-c++0x-compat" \
  # -DBOOST_ROOT=/usr/include/boost \
  # -DLIBBSONCXX_DIR=/usr/include/bsoncxx/ \
  # -DLIBMONGOCXX_DIR=/usr/include/mongocxx/ \
  # && mv /fix.patch . && patch -p1 < fix.patch \

WORKDIR catapult-server-0.1.0.1/_build
