#!/bin/sh

cat ./pathConfig > ./cluster/login/startConfig
cat ./cluster/login/config >> ./cluster/login/startConfig
skynet/skynet cluster/login/startConfig