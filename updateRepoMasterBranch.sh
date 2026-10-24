#!/bin/bash


eval $(ssh-agent -s)
ssh-add ~/sshkeys_4_meh/tha_linuz_keyh
ssh -T git@github.com


git add . && git commit -m OEQ\RSJENXC && git push origin master
