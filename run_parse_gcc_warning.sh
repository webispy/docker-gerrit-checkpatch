#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
	echo "Illegal number of parameters"
	exit 1
fi

#echo '{ "comments": {'

# Remove before 'dpkg-buildpackage' match
# Remove after 'Finished' match
sed '/^dpkg-buildpackage$/,$!d' $1 | \
	sed '/^Finished$/,$d' | \
	sed -rn 's/^\/<<PKGBUILDDIR>>\/([^:]*):([0-9]*):([0-9]*): (.*): (.*)/\t"\1" : [ { "line" : "\2", "message" : "\4: \5" } ]/p'

#echo '} }'

