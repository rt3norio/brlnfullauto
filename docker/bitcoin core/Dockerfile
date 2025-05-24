# Build Bitcoin Core from source
FROM ubuntu:22.04 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 \
    libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev \
    libboost-test-dev libboost-thread-dev libdb-dev libdb++-dev \
    libsqlite3-dev libzmq3-dev git

# Clone the Bitcoin repository and check out the latest release
WORKDIR /tmp
RUN git clone https://github.com/bitcoin/bitcoin.git
WORKDIR /tmp/bitcoin
# Check out the latest stable release (v26.0 at the time of writing)
RUN git checkout v26.0
# Ensure the script is executable
RUN chmod +x ./autogen.sh

# Build Bitcoin Core
RUN ./autogen.sh
RUN ./configure --disable-wallet --without-gui
RUN make -j$(nproc)
RUN make install

# Create a minimal runtime container
FROM ubuntu:22.04

# Install runtime dependencies and gosu for user switching
RUN apt-get update && apt-get install -y \
    libssl3 libevent-2.1-7 libevent-pthreads-2.1-7 libboost-system1.74.0 \
    libboost-filesystem1.74.0 libboost-thread1.74.0 \
    libzmq5 libdb5.3++ libsqlite3-0 gosu \
    && rm -rf /var/lib/apt/lists/*

# Copy the built binaries from the builder stage
COPY --from=builder /usr/local/bin/bitcoind /usr/local/bin/
COPY --from=builder /usr/local/bin/bitcoin-cli /usr/local/bin/

# Create bitcoin user and set up data directory
RUN useradd -r -m -U bitcoin
WORKDIR /home/bitcoin

# Bitcoin Core data directory
VOLUME ["/home/bitcoin/.bitcoin"]

# Bitcoin Core P2P, RPC ports
EXPOSE 8332 8333

# Start bitcoind by default - this will be overridden by the docker-compose command
CMD ["bitcoind", "-printtoconsole"]