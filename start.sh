#!/bin/bash

# turn on bash's job control
set -m

echo "Starting nginx.."
sudo nginx &
echo "Starting openvscode-server.."
/home/.openvscode-server/bin/openvscode-server --port 3000 --start-server --without-connection-token --host 0.0.0.0 --extensions-dir /openvscode --user-data-dir /openvscode