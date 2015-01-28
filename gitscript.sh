#!/bin/bash

echo "      This script will help you deploy to git"
echo "      **it will run the following commands:**"
echo "      git fetch upstream --tags"
echo "      git checkout master && git merge --ff-only upstream/master"
echo "      git checkout develop && git merge --ff-only upstream/develop"
echo "      git checkout master && git describe --abbrev=0"
echo "      git checkout master && git merge --no-ff develop"
echo "      git tag -a <Release version> -m Release <Release version>"
echo "      git checkout develop && git merge --ff-only master"
echo "      git push --tags upstream master develop "
echo ""
echo "      Do you want to start the script?(yes/no)"
read answer
if [ $answer = "yes" ]; then
    echo "      Starting execution..."
else
    echo "      Input != yes"
    echo "      The script is aborting execution..."
    exit 1
fi
echo "      Are you running this script from the root directy of your projects?(yes/no)"
read answer
if [ $answer = "yes" ]; then
    echo "      continuing with execution..."
else
    echo "      Please restart this script from the root directy of your projects"
    echo "      If you want to deploy /beepsend/dinner then run this script from /beepsend"
    echo "      The script is aborting execution..."
    exit 1
fi
echo "      Which derictory to you want to deploy?"
read dir
if [ -d "$dir" ]
then
    echo "      $dir directory  exists!"
else

    echo "      $(pwd)/$dir directory not found!"
    echo "      The script is aborting execution..."
    exit 1
fi 

cd $dir
echo "      Is it correct that your want to deploy from $(pwd) into $dir/master(yes/no)?"
read answer
if [ $answer = "yes" ]; then
    echo "      procceding..."
else
    echo "      Input != yes"
    echo "      The script is aborting execution..."
    exit 1
fi
echo "      setting up prerequisites for the script"
git checkout develop
echo "      1. Doing a fetch from the remote"
git fetch upstream --tags
echo "      Done ..."
echo "      2.  updating your local brances..."
git checkout master && git merge --ff-only upstream/master
git checkout develop && git merge --ff-only upstream/develop
echo "      Done ..."
echo "      3.  Find the latest tag in master"
VERSION=$(git checkout master && git describe --abbrev=0)
echo "$VERSION"
ver=${VERSION##*v}
newversion=${ver:4:1}
n=${ver##*[!0-9]}; p=${ver%%$n}
next_version=$p$((n+1))
echo "      Done ..."
echo "      your next version should be: $next_version"
echo "      Please enter the desired release version"
read input
echo "      The new version release version will be: $input"
echo "      Is that correct?(yes/no)"
read answer
if [ $answer = "yes" ]; then
    echo "      procceding..."
else
    echo "      Input != yes"
    echo "      You didnt want to release version $input"
    echo "      The script is aborting execution..."
    exit 1
fi
echo "      4.  Merge develop into master, this will be the tagged release. It will be named Merge release <$input>"
git checkout master && git merge --no-ff develop -m"Merge release $input"
echo "      Done ..."
echo "      5.  Making the tag annotated, this is important!"
git tag -a v$input -m "Release $input"
echo "      Done ..."
echo "      6.  Merge master back into develop (fast forward only)"
echo git checkout develop && git merge --ff-only master
echo "      Done ..."
echo "      7.  Verify that everything looks good (latest master is tagged correctly and that develop is up to date)."
git log --graph
echo "      Did everything look good on tig?(yes/no)"
read answer 
if [ $answer = "yes" ]; then
    echo "      procceding..."
else
    echo "      Input != yes"
    echo "      reverting to the state before script"
git tag -d v$input
git checkout develop
    echo "      The script is aborting execution..."
    exit 1
fi
echo "      Done ..."
echo "      8.  Push new tags + master and develop to upstream." 
echo "      Tags needs to be pushed before or at the same time as master&develop"
echo "      this is important for jenkins to build properly."
echo "      git push --tags upstream master develop"
#    git push --tags upstream master develop

