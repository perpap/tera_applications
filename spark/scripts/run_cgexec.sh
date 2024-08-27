#!/usr/bin/env bash

#set -x
#TERAHEAP_HOME=$HOME/teraheap
echo "TERAHEAP_HOME=$TERAHEAP_HOME"
export LIBRARY_PATH=$TERAHEAP_HOME/allocator/lib:$TERAHEAP_HOME/tera_malloc/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$TERAHEAP_HOME/allocator/lib:$TERAHEAP_HOME/tera_malloc/lib:$LD_LIBRARY_PATH
#export PATH=$TERAHEAP_HOME/allocator/include:$TERAHEAP_HOME/tera_malloc/include:$PATH
#export C_INCLUDE_PATH=$TERAHEAP_HOME/allocator/include:$TERAHEAP_HOME/tera_malloc/include:$C_INCLUDE_PATH
#export CPLUS_INCLUDE_PATH=$TERAHEAP_HOME/allocator/include:$TERAHEAP_HOME/tera_malloc/include:$CPLUS_INCLUDE_PATH

#LD_PRELOAD=/usr/lib64/libjemalloc.so.1
#export LD_PRELOAD

ulimit -a

"$@"
#numactl --cpunodebind=0 "$@"
