#!/usr/bin/env bash

for file in `find ./ -type d -name '.git'`; do
	(cd $file && git -C ../ cherry -v)
done
