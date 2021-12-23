#!/bin/bash -xe

echo 'Update version started.'

# Rebase develop onto master branch after remove -SNAPSHOT
git checkout develop
git rebase master

# update version in pom.xml
mvn -B versions:set -DnextSnapshot && mvn -B versions:commit

NEXT_RELEASE_VERSION=$(
  mvn -q versions:set -DremoveSnapshot && mvn -q help:evaluate -Dexpression=project.version -DforceStdout && mvn -q versions:revert
)

if [ "${COMPONENT}" = "personium-core" -o "${COMPONENT}" = "personium-engine" ]; then
  # update version in personium-unit-config-default.properties
  sed -i \
    "s|^\(io\.personium\.core\.version=\).*\$|\1${RELEASE_VERSION}|" \
    src/main/resources/personium-unit-config-default.properties
fi

# Git commit and push
git diff
git add .
git commit -m "Update to v${NEXT_RELEASE_VERSION}"
git push origin develop

echo 'Suceeded!'
