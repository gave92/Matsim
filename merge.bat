@echo off

git checkout master
git merge develop
git push
git checkout develop
