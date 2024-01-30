#!/usr/bin/env bash

set -o errexit
set -o nounset

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT=$(cd "${SCRIPT_DIR}/..";pwd)
VERSION_BASE_PATH="${ROOT}/VERSION_BASE"
VERSION_BASE=$(cat "${VERSION_BASE_PATH}")

VERSION_APP_PATH="${ROOT}/VERSION"
VERSION_DOCKER_PATH="${ROOT}/VERSION_DOCKER"
VERSION_CHART_PATH="${ROOT}/VERSION_CHART"

#                 Python                       Docker                                                                 Chart
# branch:         4.2.0.dev3+branch-411fa4aa   4.2.0-snapshot.3.branch.411fa4aa                                       4.2.0-snapshot.3.branch.411fa4aa
# master:         4.2.0.dev3+master-411fa4aa   4.2.0-master-latest,4.2.0-snapshot.3,4.2.0-snapshot.3.master.411fa4aa  4.2.0-snapshot.3
# public release: 4.2.0                        4.2.0,4.2.0-latest,4.2.0-411fa4aa                                      4.2.0

make_version() {
  VERSION_BASE_HASH=$(git log --follow -1 --pretty=%H "$VERSION_BASE_PATH")
  GIT_COUNT=$(git rev-list --count "$VERSION_BASE_HASH"..HEAD)
  GIT_SHA=$(git log -1 --pretty=%h)
  BRANCH=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
  LATEST_TAG=$( [[ $GITHUB_REF == refs/tags/* ]] && echo "${GITHUB_REF##refs/tags/}" || echo "" )

  echo "GIT_SHA: $GIT_SHA"
  echo "GIT_COUNT: $GIT_COUNT"
  echo "BRANCH: $BRANCH"
  echo "LATEST_TAG: $LATEST_TAG"

  # Docker versions are set starting from the most generic to the most specific
  # so we can take the most generic one and set to the chart values later
  if [[ -z "$LATEST_TAG" ]];
  then
    # We want to be sure that BRANCH does not contain any invalid symbols
    # and truncated to 16 symbols such that the full version has size 64 symbols maximum.
    # Otherwise this will trigger failures because we set appVersion in the helm chart to docker version.
    # appVersion from the chart (must be <64 symbols) then goes to resource label (validated using (([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?)
    # (Note that full version will also get 'anomaly-detection' chart name in front of VERSION_DOCKER)
    BRANCH_TOKEN=$(echo "${BRANCH//[^a-zA-Z0-9-_.]/-}" | cut -c1-16 | sed -e 's/-$//')
    VERSION_APP="$VERSION_BASE.dev${GIT_COUNT}+${BRANCH_TOKEN}-${GIT_SHA}"
    if [ "$BRANCH" == "master" ];
    then
      VERSION_CHART="$VERSION_BASE-snapshot.${GIT_COUNT}"
      MASTER_VERSION="$VERSION_BASE-snapshot.${GIT_COUNT}.${BRANCH_TOKEN}.${GIT_SHA}"
      VERSION_DOCKER="${VERSION_CHART//[^a-zA-Z0-9-_.]/-},${MASTER_VERSION//[^a-zA-Z0-9-_.]/-}"
    else
      VERSION_CHART="$VERSION_BASE-snapshot.${GIT_COUNT}.${BRANCH_TOKEN}.${GIT_SHA}"
      VERSION_DOCKER="${VERSION_CHART//[^a-zA-Z0-9-_.]/-}"
    fi
  else
    VERSION_APP="$LATEST_TAG"
    VERSION_CHART="$LATEST_TAG"
    VERSION_DOCKER="$LATEST_TAG,$LATEST_TAG-latest,${LATEST_TAG}-${GIT_SHA}"
  fi

  echo "APP VERSION: ${VERSION_APP}"
  echo "CHART VERSION: ${VERSION_CHART}"
  echo "DOCKER VERSIONS: ${VERSION_DOCKER}"

  echo -n "${VERSION_APP}" > "${VERSION_APP_PATH}"
  echo -n "${VERSION_DOCKER}" > "${VERSION_DOCKER_PATH}"
  echo -n "${VERSION_CHART}"  > "${VERSION_CHART_PATH}"
}

set_version_in_chart() {
  CHART_NAME="$1"
  DOCKER_IMAGE_NAME="$2"

  CHART_PATH="${ROOT}/charts/${CHART_NAME}"

  VERSION_APP=$(cat "${VERSION_APP_PATH}")
  DOCKER_IMAGE_TAG=$(rev "${VERSION_DOCKER_PATH}" | cut -d ',' -f 1 | rev)
  VERSION_CHART=$(cat "${VERSION_CHART_PATH}")

  sed -i "s#repository: \"\"#repository: \"$DOCKER_IMAGE_NAME\"#" "${CHART_PATH}/values.yaml"
  sed -i "s#tag: \"\"#tag: \"$DOCKER_IMAGE_TAG\"#" "${CHART_PATH}/values.yaml"
  sed -i "s#version: \"\"#version: \"$VERSION_CHART\"#" "${CHART_PATH}/Chart.yaml"
  sed -i "s#appVersion: \"\"#appVersion: \"$VERSION_APP\"#" "${CHART_PATH}/Chart.yaml"
}

set_version_in_pyproject() {
  VERSION_APP=$(cat "${VERSION_APP_PATH}")
  PYPROJECT_PATH="${ROOT}/pyproject.toml"
  sed -i "s#version = \"0.0.0\"#version = \"$VERSION_APP\"#" "${PYPROJECT_PATH}"
}

get_docker_image_tags() {
  DOCKER_IMAGE_NAME="$1"
  DOCKER_IMAGE_TAGS=$(cat "${VERSION_DOCKER_PATH}")

  IFS=',' read -ra TAGS_ARRAY <<< "$DOCKER_IMAGE_TAGS"

  RESULT=""
  for TAG in "${TAGS_ARRAY[@]}"; do
    RESULT+="${DOCKER_IMAGE_NAME}:${TAG},"
  done

  RESULT=${RESULT%,}

  echo "$RESULT"
}
