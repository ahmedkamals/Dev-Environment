#!/bin/sh
#
# @file
# Docker check.
#
# Copyright © 2015, Ahmed Kamal. (https://github.com/ahmedkamals)
#
# This file is part of Ahmed Kamal's server configurations.
# ® Redistributions of files must retain the above copyright notice.
#
# @copyright     Ahmed Kamal (https://github.com/ahmedkamals)
# @link          https://github.com/ahmedkamals/dev-environment
# @package       AK
# @subpackage    Docker
# @version       1.0
# @since         2015-01-25 Happy day :)
# @license
# @author        Ahmed Kamal <me.ahmed.kamal@gmail.com>
# @modified      2015-01-25
#

REPO=hub.docker.com:5000
PREFIX='akamal/'
CONTAINERS_NAMES="Apache Varnish PHP5-FPM"
IP_SUBNET="172.17.1."
PORTS0="8090"
PORTS1="6080"
PORTS2="9000"

checkContainerStatus(){

  containerName=$1
  RUNNING=$(docker inspect -f {{.State.Running}} $containerName 2> /dev/null)

  if [ $? -eq 1 ]; then

    echo "UNKNOWN - $containerName does not exist."
    return 0
  fi

  if [ "$RUNNING" = "false" ]; then

    echo "CRITICAL - $containerName is not running."
    return 1
  fi

  GHOST=$(docker inspect -f {{.State.Ghost}} $containerName)

  if [ "$GHOST" = "true" ]; then

    echo "WARNING - $containerName has been ghosted."
    return 2
  fi

  STARTED=$(docker inspect -f {{.State.StartedAt}} $containerName)
  NETWORK=$(docker inspect -f {{.NetworkSettings.IPAddress}} $containerName)

  echo "OK - $containerName is running. IP: $NETWORK, StartedAt: $STARTED"
  return 1
}

checkImageStatus (){

  repositoryName=$1

  REPOSITORY=$(docker images | grep "$repositoryName" | awk '{print $1}')

  if [ "$REPOSITORY" = "" ]; then

    echo "IMAGE - $repositoryName is not exist."
    return 0
  fi

  return 1
}

deployContainer(){

    containerName=$1
    ip=${IP_SUBNET}$2

    port=PORTS$2
    port=$(eval echo \$$port)

    repositoryName=${PREFIX}$containerName

    checkImageStatus $repositoryName
    imageStatus=$?

    if [ $imageStatus = 0 ];
    then

      containerId=$(docker run -it -d --name $containerName -p $ip::$port $repositoryName /bin/bash)
      echo "###" $containerName $containerId
    fi


      #buildContainer $containerName $repositoryName
    #fi
}

startContainer(){

  containerName=$1
  ip=${IP_SUBNET}$2

  port=PORTS$2
  port=$(eval echo \$$port)

  repositoryName=${PREFIX}$containerName

  echo $ip : $port $containerName
  containerId=$(docker run -it -d --name $containerName -p $ip::$port $repositoryName /bin/bash)
  echo "@@@@" $containerName $containerId
}

buildContainer(){

  containerName=$1
  repositoryName=$2

  docker build --rm --force-rm=true --no-cache=true -t $repositoryName:latest $containerName

  containerId=$(docker ps -l | awk 'print ${1}')

  IMAGE=$(docker commit $containerId $repositoryName)
#      docker tag -f $IMAGE ${PREFIX}$containerName
#      IMAGE=$(docker commit $containerId -a 'Ahmed Kamal' -m 'Initial commit')
  echo "$IMAGE $repositoryName"
}

init(){

  key=-1
  for containerName in $CONTAINERS_NAMES;
  do

    key=`expr $key + 1`

    containerName=`echo "$containerName" | sed -e 's/\(.*\)/\L\1/'`

    checkContainerStatus $containerName
    status=$?

    case "$status" in

      [0-1])

        deployContainer $containerName $key
        ;;
      2)

        startContainer  $containerName $key
        ;;
    esac

  done
}

#while true ; do

  init
#  sleep 30
#done
