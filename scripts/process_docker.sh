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
  echo "${YELLOW_BG}${BLACK_TXT} The process Docker script requires Composer 2. You will manually have to update the following files: ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} - docker-compose.yml ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} - drush/sites/self.site.yml ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} - visual-regression-urls.json ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} - web/sites/default/settings.php ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} See the README.md for more information on what updates must be made. ${RESET}"
  echo "${YELLOW_BG}${BLACK_TXT} If you are setting up a site please also note that the site installation profile will still be able to be installed. ${RESET}";
  exit 0;
fi

# Check if the user actually wants to run the install script or not.
echo "${GREEN_TXT}Would you like to run the process Docker script? ${RESET}(It is highly recommended you do run this script for an easy setup.) [${YELLOW_TXT}Y,n${RESET}]?";
read run_docker_process_script
if [ "$run_docker_process_script" != 'y' -a "$run_docker_process_script" != 'Y' ]
then
  echo "${YELLOW_BG}${BLACK_TXT} The process Docker script will not be run. Please note the rest of the composer install command has still be ran as expected. ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} You will manually have to update the following files: ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} - docker-compose.yml ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} - drush/sites/self.site.yml ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} - visual-regression-urls.json ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} - web/sites/default/settings.php ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} See the README.md for more information on what updates must be made. ${RESET}"
  echo "${YELLOW_BG}${BLACK_TXT} If you are setting up a site please also note that the site installation profile will still be able to be installed. ${RESET}";
  exit 0;
fi

echo "${GREEN_TXT}What URL slug would you like to use? (eg \"yellow-pencil\" would result in a local development URL of \"yellow-pencil.dev.localhost\".)${RESET}";
read app_slug_replace

echo "${GREEN_TXT}Please enter the GitHub repo name? (eg \"https://git.yellowpencil.com/onpoint-webops/yp-onpoint-site\" has a repo slug of \"yp-onpoint-site\".)${RESET}";
read repo_slug_replace

echo "\n${GREEN_TXT}Running \"Process Docker Script\"...${RESET}";

# Replace in all the following files:
# - docker-compose.yml
# - drush/sites/self.site.yml
# - visual-regression-urls.json
# - web/sites/default/settings.php
echo "  - Replacing ${YELLOW_TXT}[app-slug]${RESET} with ${GREEN_TXT}${app_slug_replace}${RESET} in ${YELLOW_TXT}docker-compose.yml${RESET}";
sed -i '' -e "s/\[app-slug\]/${app_slug_replace}/g" docker-compose.yml

echo "  - Replacing ${YELLOW_TXT}[app-slug]${RESET} with ${GREEN_TXT}${app_slug_replace}${RESET} in ${YELLOW_TXT}drush/sites/self.site.yml${RESET}";
sed -i '' -e "s/\[app-slug\]/${app_slug_replace}/g" drush/sites/self.site.yml

echo "  - Replacing ${YELLOW_TXT}[app-slug]${RESET} with ${GREEN_TXT}${app_slug_replace}${RESET} in ${YELLOW_TXT}docker-compose.yml${RESET}";
sed -i '' -e "s/\[repo-slug\]/${repo_slug_replace}/g" visual-regression-urls.json

echo "  - Replacing ${YELLOW_TXT}[app-slug]${RESET} with ${GREEN_TXT}${app_slug_replace}${RESET} in ${YELLOW_TXT}docker-compose.yml${RESET}";
sed -i '' -e "s/\[repo-slug\]/${repo_slug_replace}/g" web/sites/default/settings.php

# Copy the settings.local.php file to it's final location
echo "  - Copying ${YELLOW_TXT}scripts/files/settings.local.php${RESET} to ${GREEN_TXT}web/sites/default${RESET}";
cp scripts/files/settings.local.php web/sites/default
# Setup default `hash_salt` for Drupal one-time links
HASH_SALT=$(php scripts/helper-scripts/generate_hash_salt.php)
echo "  - Created new Hash Salt ${GREEN_TXT}${HASH_SALT}${RESET}";
echo "  - Replacing ${YELLOW_TXT}[hash-salt]${RESET} with ${GREEN_TXT}${HASH_SALT}${RESET} in ${YELLOW_TXT}web/sites/default/settings.php${RESET}";
sed -i '' -e "s/\[hash-salt\]/${HASH_SALT}/g" web/sites/default/settings.php

echo "${GREEN_TXT}The local Docker development environment has been setup.${RESET}";
