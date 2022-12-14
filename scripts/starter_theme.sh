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
  echo "${YELLOW_BG}${BLACK_TXT} The starting theme front-end setup script requires Composer 2. Please note the rest of the composer install command has still be ran as expected - the theme setup is an optional step. ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} If you are setting up a site please also note that the site installation profile will still be able to be installed. ${RESET}";
  exit 0;
fi

# Check if the user actually wants to run the install script or not.
echo "${GREEN_TXT}Would you like to install a theme using the starter theme front-end setup script? ${RESET}[${YELLOW_TXT}Y,n${RESET}]?";
read install_theme
if [ "$install_theme" != 'y' -a "$install_theme" != 'Y' ]
then
  echo "${YELLOW_BG}${BLACK_TXT} Theme will not be setup. Please note the rest of the composer install command has still be ran as expected - the theme setup is an optional step. ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} If you are setting up a site please also note that the site installation profile will still be able to be installed. ${RESET}";
  echo "\n${YELLOW_BG}${BLACK_TXT} If you are not using a custom theme at all, you will need to update your Docker setup to not use the front-end theme: ${RESET}";
  echo "  - Comment out ${YELLOW_TXT}lines 45 - 53${RESET} in the ${YELLOW_TXT}docker-compose.yml${RESET} file";
  echo "  - Comment out ${YELLOW_TXT}lines 5 - 9, and 38${RESET} in the ${YELLOW_TXT}DOCKERFILE${RESET} file";
  exit 0;
fi

# fe_setup.sh script runs from here on.
echo "${GREEN_TXT}What is the theme name? (This value should be all lowercase, and will replace 'yellowpencil' in the starter theme.)${RESET}";
read theme_name
echo "${GREEN_TXT}What is the URL of the project repository? This repo needs to have already been created. This will only replace the repo URL in some files in the theme - it will not affect the repo in any way.${RESET}";
echo "${GREEN_TXT}This should follow the format 'https://git.yellowpencil.com/onpoint-webops/project-name'.${RESET}";
read repo_url
SEARCH_PATH=web/themes/custom
SEARCH=yellowpencil
SEARCH_R=[Yy]ellow[Pp]encil
REPLACE=$theme_name
REPO=$repo_url
# Check if the theme already exists and is so exit so we don't accidentally
# overwrite anything.
if [ -d "$SEARCH_PATH/$REPLACE" -a ! -h "$SEARCH_PATH/$REPLACE" ]
then
  echo "${YELLOW_BG}${BLACK_TXT} Theme already exists. Please note the rest of the composer install command has still be ran as expected - the theme setup is an optional step. ${RESET}";
  echo "${YELLOW_BG}${BLACK_TXT} If you are setting up a site please also note that the site installation profile will still be able to be installed. ${RESET}";
  exit 0;
fi

echo "\n${GREEN_TXT}Running \"Theme Setup Script\"...${RESET}";

echo "  - Cloning project from ${YELLOW_TXT}git@git.yellowpencil.com:yellowpencil/yp_drupal8_theme.git${RESET} to ${GREEN_TXT}$SEARCH_PATH/$REPLACE${RESET}";
git clone git@git.yellowpencil.com:yellowpencil/yp_drupal8_theme.git $SEARCH_PATH/$REPLACE
mv $SEARCH_PATH/$REPLACE/yellowpencil/* $SEARCH_PATH/$REPLACE
rm -r $SEARCH_PATH/$REPLACE/yellowpencil
rm -rf $SEARCH_PATH/$REPLACE/.git
rm -rf $SEARCH_PATH/$REPLACE/.gitignore

echo "  - Renaming files in ${YELLOW_TXT}${SEARCH_PATH}${RESET}...";
find ${SEARCH_PATH} -type f -name "*${SEARCH}*" | while read FILENAME ; do
  NEW_FILENAME="$(echo ${FILENAME} | sed -e "s/${SEARCH}/${REPLACE}/g")";
  echo "    - Renaming ${YELLOW_TXT}${FILENAME}${RESET} to ${GREEN_TXT}${NEW_FILENAME}${RESET}";
  mv "${FILENAME}" "${NEW_FILENAME}";
done

echo "  - Replacing ${YELLOW_TXT}${SEARCH_R}${RESET} with ${GREEN_TXT}${REPLACE}${RESET} in ${YELLOW_TXT}.twig${RESET} files";
find ${SEARCH_PATH} -type f -name "*.twig" -print0 | xargs -0 sed -i '' -e "s/${SEARCH_R}/${REPLACE}/g"
echo "  - Replacing ${YELLOW_TXT}${SEARCH_R}${RESET} with ${GREEN_TXT}${REPLACE}${RESET} in the ${YELLOW_TXT}.theme${RESET} file";
find ${SEARCH_PATH} -type f -name "*.theme" -print0 | xargs -0 sed -i '' -e "s/${SEARCH_R}/${REPLACE}/g"
echo "  - Replacing ${YELLOW_TXT}${SEARCH_R}${RESET} with ${GREEN_TXT}${REPLACE}${RESET} in ${YELLOW_TXT}.yml${RESET} files";
find ${SEARCH_PATH} -type f -name "*.yml" -print0 | xargs -0 sed -i '' -e "s/${SEARCH_R}/${REPLACE}/g"
echo "  - Replacing ${YELLOW_TXT}${SEARCH_R}${RESET} with ${GREEN_TXT}${REPLACE}${RESET} in ${YELLOW_TXT}.txt${RESET} files";
find ${SEARCH_PATH} -type f -name "*.txt" -print0 | xargs -0 sed -i '' -e "s/${SEARCH_R}/${REPLACE}/g"
PACKAGE_FILE=$(find ${SEARCH_PATH}/${REPLACE} -type f -name "package.json" -print0)
echo "  - Replacing ${YELLOW_TXT}${SEARCH_R}${RESET} with ${GREEN_TXT}${REPLACE}${RESET} in the ${YELLOW_TXT}${PACKAGE_FILE}${RESET} file";
sed -i '' -e "s/${SEARCH_R}/${REPLACE}/g" $PACKAGE_FILE
sed -i '' -e "s,https:\/\/[^\"#]*,${REPO},g" $PACKAGE_FILE

echo "  - Replacing ${YELLOW_TXT}[theme-slug]${RESET} with ${GREEN_TXT}${REPLACE}${RESET} in the ${YELLOW_TXT}docker-compose.yml${RESET}";
sed -i '' -e "s/\[theme-slug\]/${REPLACE}/g" docker-compose.yml
echo "  - Replacing ${YELLOW_TXT}[theme-slug]${RESET} with ${GREEN_TXT}${REPLACE}${RESET} in the ${YELLOW_TXT}DOCKERFILE${RESET}";
sed -i '' -e "s/\[theme-slug\]/${REPLACE}/g" Dockerfile

echo "${GREEN_TXT}The '${theme_name}' theme has been successfully created.${RESET}";
