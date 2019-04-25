#!/bin/sh

cat ./pathConfig > ./cluster/routing/startConfig
cat ./cluster/routing/config >> ./cluster/routing/startConfig
skynet/skynet cluster/routing/startConfig