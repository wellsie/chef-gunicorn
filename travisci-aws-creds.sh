#!/bin/sh
#
# Author:: Jono Wells (_@oj.io)
# oj.io
# Encrypt AWS creds for travis-ci
#
# Copyright 2014, Jono Wells
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

usage(){
cat << EOF
  usage: $0 [-hd] file

  This script will take AWS environment variables and update your .travis.yml
  file. In addition to encrypting the designated PEM file to .secret.

  OPTIONS:
    -h show this message
    -d dry run - does not update or create any files
EOF
}

dry=off
while getopts "hd" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    d)
      dry=on
      ;;
    \?)
      usage >&2
      exit 1;;
  esac
done
shift "$((OPTIND-1))"

pemfile=$@

if [ ! -f "$pemfile" ];
  then
    echo "  $pemfile is not a file\n"
    usage
    exit 1
fi

echo "input file: $pemfile"
echo "dry: $dry"

AWS_SSH_KEY=./.$(basename $pemfile)
echo AWS_SSH_KEY=$AWS_SSH_KEY

set -u
for KEY in AWS_ACCESS_KEY AWS_SECRET_KEY AWS_SSH_KEY_ID
do
  env |grep ^$KEY=
done

[ "$dry" == "on" ] && exit 0

TRAVIS_CI_SECRET=`cat /dev/urandom | head -c 10000 | openssl sha1`
openssl aes-256-cbc -pass "pass:$TRAVIS_CI_SECRET" -in $1 -out ./.secret -a

travis encrypt TRAVIS_CI_SECRET=$TRAVIS_CI_SECRET --add --override
travis encrypt AWS_ACCESS_KEY=$AWS_ACCESS_KEY --add
travis encrypt AWS_SECRET_KEY=$AWS_SECRET_KEY --add
travis encrypt AWS_SSH_KEY=$AWS_SSH_KEY --add
travis encrypt AWS_SSH_KEY_ID=$AWS_SSH_KEY_ID --add

# to decrypt the file do this in .travis.yml
#
# before_script:
# - openssl aes-256-cbc -pass "pass:$TRAVIS_CI_SECRET" -in ./.secret -out "$AWS_SSH_KEY"

