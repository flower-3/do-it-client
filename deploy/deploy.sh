#!/bin/bash

DOCKER_COMPOSE_PATH=/home/ubuntu/do-it-deploy/docker/client
EXIST_RED=$(sudo docker-compose -p do-it-client-red ps | grep do-it-client-red)

if [ -z "$EXIST_RED" ]; then
    # running do-it-client-green
    echo "running do-it-client-green"
    START_CONTAINER=red
    TERMINATE_CONTAINER=green
    START_PORT=3000
    TERMINATE_PORT=3001
else
    # running do-it-client-red
    echo "running do-it-client-red"
    START_CONTAINER=green
    TERMINATE_CONTAINER=red
    START_PORT=3001
    TERMINATE_PORT=3000
fi

echo "do-it-client-${START_CONTAINER} will up"

sudo docker-compose -p do-it-client-${START_CONTAINER} -f ${DOCKER_COMPOSE_PATH}/docker-compose.${START_CONTAINER}.yml up -d --build
DOCKER_COMPOSE_RESULT=$?
sleep 10

if [[ $DOCKER_COMPOSE_RESULT -eq 0 ]]; then
  echo "change nginx server port"

  sudo sed -i "s/${TERMINATE_PORT}/${START_PORT}/g" /etc/nginx/conf.d/service-url.inc

  echo "nginx reload"
  sudo service nginx reload

  echo "do-it-client-${TERMINATE_CONTAINER} down"
  sudo docker-compose -p do-it-client-${TERMINATE_CONTAINER} down
  sudo docker image prune -f
else
  echo "docker-compose-${START_CONTAINER} error occurs!"
fi