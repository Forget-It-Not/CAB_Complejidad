#!/bin/bash

# Arguments
#   $1: Nº Reps

sn="Marcos_Networld"
tmux new-session -d -s $sn
echo $sn
for i in $(seq 1 $1); do
    tmux new-win -d -n "$sn:$i"
done
for i in $(seq 1 $1); do
    tmux send-keys -t "$sn:$i" "matlab -r 'CL_run_simulations_proxy($i)'" ENTER
done