# syntax=docker/dockerfile:experimental
#
# Frontend
#
FROM node:15 as frontend
COPY web/themes/custom/opwo_theme /data/themes/custom/opwo_theme
WORKDIR "/data/themes/custom/opwo_theme"
RUN npm install
RUN npm run build-prod && rm -rf node_modules

#
# PHP Dependencies
#
FROM us.gcr.io/onpoint-webops-preview/composer-prestissimo:2.0 as vendor
COPY composer.* /app/
# COPY patches/ /app/patches/
# COPY premium-modules/ /app/premium-modules/
COPY scripts/ /app/scripts/
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan git.yellowpencil.com >> ~/.ssh/known_hosts
RUN --mount=type=ssh composer install --ignore-platform-reqs --no-progress

#
# Application
#
FROM us.gcr.io/onpoint-webops-preview/drupal-php:7.4
WORKDIR "/var/www/html"

# Copy PHP Dependencies output
COPY --chown=root:www-data --from=vendor /app/ /var/www/html/

# Copy Application code
COPY --chown=root:www-data . /var/www/html
RUN mkdir -p /var/www/html/tmp
RUN mkdir -p /var/www/html/web/sites/default/private
RUN chown root:www-data /var/www/html/tmp
RUN chown root:www-data /var/www/html/web/sites/default/private
RUN chmod -R 775 /var/www/html/tmp
RUN chmod -R 775 /var/www/html/web/sites/default

# Copy Frontend output
COPY --chown=root:www-data --from=frontend /data/themes/custom/opwo_theme /var/www/html/web/themes/custom/opwo_theme

EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]
