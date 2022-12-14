FROM us.gcr.io/onpoint-webops-preview/drupal-php:7.4

RUN apt-get -y update \
# Uncomment the line below to work with xdebug
# && apt-get -y install php7.4-xdebug \
  && apt-get -y install vim

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents('https://composer.github.io/installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt. Update hash in DockerFile?'; unlink('composer-setup.php'); } echo PHP_EOL;"\
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && php -r "unlink('composer-setup.php');"

RUN curl -OL https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar \
  && chmod a+x drush.phar \
  && mv drush.phar /usr/local/bin/drush

COPY docker/local-dev/drupal/config/php.ini /etc/php/7.4/mods-available/custom.ini

# Only run xdebug on fpm SAPI to avoid cli errors.
# Uncomment the lines below to work with xdebug
# RUN phpdismod xdebug \
#  && phpenmod -v 7.4 -s fpm custom \
#  && phpenmod -v 7.4 -s fpm xdebug

WORKDIR "/var/www/html"

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]
