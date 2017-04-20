#!/bin/bash

git submodule update --remote
hexo clean
rm -rf .deploy_git
git status
git add .
git status
git commit
git pull origin master
git push origin master
