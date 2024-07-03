#!/usr/bin/bash env

pgrep -f serdes.sh | xargs kill -9
pgrep -f mem_usage.sh | xargs kill -9
pgrep -f jstat.sh | xargs kill -9
