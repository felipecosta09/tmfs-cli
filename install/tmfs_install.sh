#!/bin/bash

# Check if JQ is installed.
if ! command -v jq &> /dev/null
then
    echo "JQ could not be found."
    exit
fi

# Check if curl is installed.
if ! command -v curl &> /dev/null
then
    echo "curl could not be found."
    exit
fi

# Check if sudo is installed.
if ! command -v sudo &> /dev/null
then
    echo "sudo could not be found."
    exit
fi

BASE_METADATA_URL="https://cli.artifactscan.cloudone.trendmicro.com/tmas-cli/"
BASE_URL="https://tmfs-cli.fs-sdk-ue1.xdr.trendmicro.com/tmfs-cli/"
METADATA_URL="${BASE_METADATA_URL}metadata.json"
VERSION_STRING=$(curl -s $METADATA_URL | jq -r '.latestVersion')
VERSION="${VERSION_STRING:1}"
echo "Latest version is: $VERSION"

OS=$(uname -s)
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then ARCH=arm64; fi
ARCHITECTURE="${OS}_${ARCH}"
echo "Downloading version $VERSION of tmfs CLI for $OS in architecture $ARCHITECTURE"
if [ "$OS" = "Linux" ]; 
then 
    URL="${BASE_URL}latest/tmfs-cli_$ARCHITECTURE.tar.gz"
    curl -s "$URL" | tar -xz tmfs
else
    URL="${BASE_URL}latest/tmfs-cli_$ARCHITECTURE.zip"
    curl -s "$URL" -o tmfs.zip
    unzip -p tmfs.zip tmfs > extracted_tmfs
    mv extracted_tmfs tmfs
    chmod +x tmfs
    rm -rf tmfs.zip
fi

echo "Moving the binary to \"/usr/local/bin/\". It might request root access."
sudo mv tmfs /usr/local/bin/
