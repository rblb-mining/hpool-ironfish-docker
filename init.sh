#!/bin/bash

echo $@

if [ "$HPOOLKEY" = "" ];
then
	if [ "$1" != "" ];
	then
		export HPOOLKEY="$1"
	else
		echo "No API_KEY"

	fi

fi

get_latest_release() {
	curl  --retry 60 --retry-delay 10  -s https://api.github.com/repos/$1/releases/latest \
| grep "linux.zip" \
| cut -d : -f 2,3 \
| cut -d , -f 2 \
| tr -d \" \
 | xargs


}

get_latest_proxy_release() {
	curl  --retry 60 --retry-delay 10  -s https://api.github.com/repos/$1/releases/latest \
| grep "xproxy-" \
| cut -d : -f 2,3 \
| cut -d , -f 2 \
| tr -d \" \
 | xargs


}
if [ "$MINER" = "" ];
then
	export MINER=`get_latest_release hpool-dev/ironfish-miner`
fi

if [ "$PROXY" = "" ];
then
	export PROXY=`get_latest_proxy_release hpool-dev/ironfish-miner`
fi

if [ "$MINER_NAME" = "" ];
then
	export MINER_NAME=`hostname`
fi

rm -Rf miner || true
mkdir -p miner
cd miner

mkdir -p proxy
cd proxy
curl -L $PROXY -o proxy.zip
unzip proxy.zip
cd Iron*
yq -yi ".chains[0].apiKey = \"$HPOOLKEY\"" config.yaml
yq -yi ".server.host = \"127.0.0.1\"" config.yaml 
./x-proxy-ironfish-linux-amd64 &
cd ../../

mkdir -p miner
cd miner
curl -L $MINER -o miner.zip
unzip miner.zip
cd linux
yq -yi ".minerName = \"$MINER_NAME\"" config.yaml
yq -yi '.proxy.url = "http://127.0.0.1:9190"' config.yaml
yq -yi '.url = "http://127.0.0.1:9190"' config.yaml
yq -yi ".apiKey = \"$HPOOLKEY\"" config.yaml

./hpool-miner-ironfish-cuda
