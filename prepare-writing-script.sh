#!/bin/bash

eval $(ssh-agent -s)
ssh-add ~/sshkeys_4_meh/tha_linuz_keyh
ssh -vT git@github.com
ssh -vT git@codeberg.org
pushd /mnt/FASTstorage/GithubFAST/escrita && git push origin master && popd
