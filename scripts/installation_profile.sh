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
  echo "${YELLOW_BG}${BLACK_TXT} The site install profile script requires Composer 2. You will manually have to install the Yellow Pencil site profile. ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} See the README.md for more information on how to setup Docker. ${RESET}"
  exit 0;
fi

# Check if the user actually wants to run the install script or not.
echo "${GREEN_TXT}Would you like to run the site install profile script? ${RESET} [${YELLOW_TXT}Y,n${RESET}]?";
read run_docker_setup_script
if [ "$run_docker_setup_script" != 'y' -a "$run_docker_setup_script" != 'Y' ]
then
  echo "${YELLOW_BG}${BLACK_TXT} The site install profile script will not be run. You will manually have to install the Yellow Pencil site profile. ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} See the README.md for more information on how to setup Docker. ${RESET}"
  exit 0;
fi

echo "${GREEN_TXT}What is the site name? This can include spaces. (eg \"Yellow Pencil\")${RESET}";
read site_name

echo "\n${GREEN_TXT}Running \"Site Install Profile Script\"...${RESET}";

echo "  - Running ${YELLOW_TXT}docker-compose exec drupal drush site-install yp_install_profile --site-name='${site_name}' --site-mail=do-not-reply@yellowpencil.com --account-name=admin --account-pass=password${RESET}";
docker-compose exec drupal drush site-install yp_install_profile --site-name='${site_name}' --site-mail=do-not-reply@yellowpencil.com --account-name=admin --account-pass=password

echo "\n${GREEN_TXT}The site install profile has been installed. Please login with user ${RESET}\"admin\"${GREEN_TXT} and password ${RESET}\"password\"${GREEN_TXT} and create your own new user.${RESET}";
echo "\n${RED_BG} DISABLE/RESET THE PASSWORD FOR THE DEFAULT \"admin\" USER AS SOON AS POSSIBLE. ${RESET}";
