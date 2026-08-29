#!/usr/bin/env bash
while true; do
	pidof wob || tail -f /tmp/wobpipe | wob & 
	sleep 1m
done
