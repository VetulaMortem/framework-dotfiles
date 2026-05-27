#!/bin/bash

case $1 in
	title)
		playerctl metadata --format '{{ title }}'
	;;
	artist)
		playerctl metadata --format '{{ artist }}'
	;;
esac
