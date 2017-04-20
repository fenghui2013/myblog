#!/bin/bash

git submodule update --remote
hexo clean
hexo generate
echo "cp -r myimg/* public/img/"
cp -r myimg/* public/img/
hexo deploy
rm -rf .deploy_git
