FROM ubuntu:16.04
MAINTAINER Yoshiyuki Ieyama <44uk@github.com>

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
  git \
  curl \
  wget \
  autoconf \
  automake \
  build-essential \
  cmake \
  pkg-config \
  python3 \
  libtool \
  libboost-all-dev \
  libgtest-dev \
  librocksdb-dev
  #ninja-build \
  #libevent-pthreads-2.0-5 \
  #libevent-dev \
  #libzmq-dev
  #libmongoc-1.0-0 \
  #libmongoc-dev \
  #libmongo-client-dev \

# default python3
#RUN mv /usr/bin/python /usr/bin/python2 && mv /usr/bin/python3 /usr/bin/python

# gtest
RUN cd /usr/src/gtest && cmake CMakeLists.txt && make && cp *.a /usr/lib && cd -

# bson
RUN git clone https://github.com/mongodb/libbson.git -b 1.9.5 --depth 1 \
  && cd libbson \
  && ./autogen.sh && make && make install \
  && cd -

# mongoc
RUN wget https://github.com/mongodb/mongo-c-driver/releases/download/1.9.5/mongo-c-driver-1.9.5.tar.gz \
  && tar xzf mongo-c-driver-1.9.5.tar.gz && cd mongo-c-driver-1.9.5 \
  && ./configure --disable-automatic-init-and-cleanup --enable-static --prefix=/usr/local \
  && make && make install \
  && cd -

# mongo-cxx
RUN git clone https://github.com/mongodb/mongo-cxx-driver.git -b releases/stable --depth 1 \
  && cd mongo-cxx-driver/build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
  && make EP_mnmlstc_core && make install \
  && cd -

# zmqlib
RUN git clone https://github.com/zeromq/libzmq.git -b v4.2.5 --depth 1 \
  && mkdir -p libzmq/_build && cd libzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make && make install \
  && cd -

# cppzmq
RUN git clone https://github.com/zeromq/cppzmq.git -b v4.2.3 --depth 1 \
  && mkdir -p cppzmq/_build && cd cppzmq/_build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make && make install \
  && cd -

# catapult
RUN git clone https://github.com/nemtech/catapult-server.git --depth 1 \
  && cd catapult-server \
  && mkdir _build && cd _build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
    -DBSONCXX_LIB=/usr/local/lib/libbsoncxx.so \
    -DMONGOCXX_LIB=/usr/local/lib/libmongocxx.so \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    ..
  #&& make publish && make

WORKDIR catapult-server/_build
  # pkg-config \
