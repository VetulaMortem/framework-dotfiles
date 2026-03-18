#!/bin/bash
killall Discord -9
pidof steam && steam -shutdown
sleep 1
uwsm stop
