#!/bin/sh

cat ./pathConfig > ./cluster/game/startConfig
cat ./cluster/game/config >> ./cluster/game/startConfig
skynet/skynet cluster/game/startConfig