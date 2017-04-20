#!/bin/bash

git submodule update --remote
hexo clean
hexo generate
echo "cp -r myimg/* public/img/"
cp -r myimg/* public/img/
hexo server
hexo clean
rm -rf .deploy_git
