#!/bin/bash

set -ex

if [ -n "$(kairos-agent config get amt | head -n1)" ]
then
  kairos-agent config get amt | ./agent-provider-amt
fi
