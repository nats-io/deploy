#!/bin/bash 
set -x
echo "Bootstrap started" > bootstrap.log
sudo mkdir /nats-data; 
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noatime ${efs_mount_target_ip}:/ /nats-data

# per instance setup of systemd template
NATS_DATA_ROOT=/nats-data/

INSTANCE_ID=1
SERVICE_NAME=natssd
SVC_ID=$SERVICE_NAME-$INSTANCE_ID

# if there aren't already the necessary directories in /nats-data/ create them.
if [ ! -d /$NATS_DATA_ROOT/$SVC_ID ]; then
  mkdir -p /$NATS_DATA_ROOT/$SVC_ID/{certs,current,logs,data}

  # if you want to add certs, you should do that here, too. add them to the certs directory.
  # create a config file.
  cat << EOL | sudo tee -a /$NATS_DATA_ROOT/$SVC_ID/current/natsservice.conf
# NATS Config
# Written by bootstrap.sh terraform.
listen: 0.0.0.0:4233
http: 8233
log_file: "$NATS_DATA_ROOT$SVC_ID/logs/nats.log"

# Define the cluster name.
# Can be id, cid or cluster_id
id: "natssd_cluster"
EOL

  # create a config file.
  cat << EOL | sudo tee -a /$NATS_DATA_ROOT/$SVC_ID/current/streaming.conf
# NATS Streaming Server Config
# Written by bootstrap.sh terraform.

# Store type
# Can be st, store, store_type or StoreType
# Possible values are file or memory (case insensitive)
store: "file"

# When using a file store, need to provide the root directory.
# Can be dir or datastore
dir: "$NATS_DATA_ROOT$SVC_ID/data"

# Debug flag.
# Can be sd or stand_debug
sd: false

# Trace flag.
# Can be sv or stan_trace
sv: false

# If specified, connects to an external NATS server, otherwise
# starts and embedded server.
# Can be ns, nats_server or nats_server_url
# ns: "nats://localhost:4222"

# This flag creates a TLS connection to the server but without
# the need to use a TLS configuration (no NATS server certificate verification).
secure: false

# Define store limits.
# Can be limits, store_limits or StoreLimits.
# See Store Limits chapter below for more details.
# store_limits: {
#     # Define maximum number of channels.
#     # Can be mc, max_channels or MaxChannels
#     max_channels: 100
#
#     # Define maximum number of subscriptions per channel.
#     # Can be msu, max_sybs, max_subscriptions or MaxSubscriptions
#     max_subs: 100
#
#     # Define maximum number of messages per channel.
#     # Can be mm, max_msgs, MaxMsgs, max_count or MaxCount
#     max_msgs: 10000
#
#     # Define total size of messages per channel.
#     # Can be mb, max_bytes or MaxBytes. Expressed in bytes
#     max_bytes: 10240000
#
#     # Define how long messages can stay in the log, expressed
#    # as a duration, for example: "24h" or "1h15m", etc...
#    # Can be ma, max_age, MaxAge.
#    max_age: "24h"
#}

# TLS configuration.
# tls: {
#     client_cert: "/path/to/client/cert_file"
#     client_key: "/path/to/client/key_file"
#     # Can be client_ca or client_cacert
#     client_ca: "/path/to/client/ca_file"
# }

# Configure file store specific options.
# Can be file or file_options
file: {
    # Enable/disable file compaction.
    # Can be compact or compact_enabled
    compact: true

    # Define compaction threshold (in percentage)
    # Can be compact_frag or compact_fragmemtation
    compact_frag: 50

    # Define minimum interval between attempts to compact files.
    # Expressed in seconds
    compact_interval: 300

    # Define minimum size of a file before compaction can be attempted
    # Expressed in bytes
    compact_min_size: 10485760

    # Define the size of buffers that can be used to buffer write operations.
    # Expressed in bytes
    buffer_size: 2097152

    # Define if CRC of records should be computed on reads.
    # Can be crc or do_crc
    crc: true

    # You can select the CRC polynomial. Note that changing the value
    # after records have been persisted would result in server failing
    # to start complaining about data corruption.
    crc_poly: 3988292384

    # Define if server should perform "file sync" operations during a flush.
    # Can be sync, do_sync, sync_on_flush
    sync: true

    # Enable/disable caching of messages once stored. If enabled, it saves
    # on disk reads (improved performance at the expense of memory).
    # Can be cache, do_cache, cache_msgs
    cache: true
}
EOL

# ends the config creation.
fi

# create the user
sudo useradd -m -d /nats-data/$SVC_ID -s /usr/sbin/nologin -c "$SVC_ID service user." \
    -u $((1200+$INSTANCE_ID)) $SVC_ID

# give the user ownership of their files.
sudo chown $SVC_ID:$SVC_ID -R /$NATS_DATA_ROOT/$SVC_ID

# the NATS AMI will create a systemd template that points to an /nats-data/svc_id-instance_id/current/natsservice.conf
sudo systemctl enable $SERVICE_NAME\@$INSTANCE_ID.service
sudo systemctl start $SERVICE_NAME\@$INSTANCE_ID.service

echo "Bootstrap finished." > bootstrap.log
