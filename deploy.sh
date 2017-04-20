#!/bin/bash

git submodule update --remote
hexo clean
hexo generate
echo "mkdir public/img"
mkdir public/img
echo "cp -r myimg/* public/img/"
cp -r myimg/* public/img/
hexo deploy
rm -rf .deploy_git
