#!/bin/bash

# Setup colours for us in our output messages.
BLACK_TXT=`tput setaf 0`
RED_TXT=`tput setaf 1`
GREEN_TXT=`tput setaf 2`
YELLOW_TXT=`tput setaf 3`
BLACK_BG=`tput setab 0`
RED_BG=`tput setab 1`
GREEN_BG=`tput setab 2`
YELLOW_BG=`tput setab 3`
RESET=`tput sgr0`

# Get composer version because in order to run properly this script requires
# Composer 2. See: https://github.com/composer/composer/issues/3299.
# Cuts will return overall composer version (ie. 1 or 2).
COMPOSER_VERSION_COMMAND="composer --version --no-ansi | cut -d \" \" -f 3 | cut -d \".\" -f 1"
COMPOSER_VERSION=$(eval "$COMPOSER_VERSION_COMMAND")
if [ "$COMPOSER_VERSION" -lt 2 ]
then
  echo "${YELLOW_BG}${BLACK_TXT} The Docker setup script requires Composer 2. You will manually have to get Docker up and running. ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} See the README.md for more information on how to setup Docker. ${RESET}"
  echo "${YELLOW_BG}${BLACK_TXT} If you are setting up a site please also note that the site installation profile will still be able to be installed. ${RESET}";
  exit 0;
fi

# Check if the user actually wants to run the install script or not.
echo "${GREEN_TXT}Would you like to run the Docker setup script? ${RESET} [${YELLOW_TXT}Y,n${RESET}]?";
read run_docker_setup_script
if [ "$run_docker_setup_script" != 'y' -a "$run_docker_setup_script" != 'Y' ]
then
  echo "${YELLOW_BG}${BLACK_TXT} The Docker setup script will not be run. You will manually have to get Docker up and running. ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} See the README.md for more information on how to setup Docker. ${RESET}"
  echo "${YELLOW_BG}${BLACK_TXT} If you are setting up a site please also note that the site installation profile will still be able to be installed. ${RESET}";
  exit 0;
fi

echo "${GREEN_TXT}Did you run the starting theme front-end setup script? ${RESET} [${YELLOW_TXT}Y,n${RESET}]?";
read ran_theme_setup_script

echo "\n${GREEN_TXT}Running \"Docker Setup Script\"...${RESET}";

echo "  - Running ${YELLOW_TXT}docker-compose build${RESET}";
docker-compose build

if [ "$ran_theme_setup_script" != 'y' -a "$ran_theme_setup_script" != 'Y' ]
then
  echo "  - Running ${YELLOW_TXT}docker-compose run build npm install${RESET}";
  docker-compose run build npm install
fi

echo "  - Running ${YELLOW_TXT}docker-compose up -d${RESET}";
docker-compose up -d

echo "${GREEN_TXT}The local Docker development environment has been built and is now running.${RESET}";
