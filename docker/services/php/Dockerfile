
FROM php:7.4.12-fpm

USER root

# Move to if
RUN apt-get update && apt-get install -y wget git libpq-dev
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql
# fi

COPY zz_dev.ini /usr/local/etc/php/conf.d/

RUN \
	echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/xdebug.ini \
	&& echo "xdebug.remote_host = host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini \
	&& echo "xdebug.coverage_enable = 0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart = 1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back = 0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.profiler_enable = 0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.var_display_max_depth = -1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.var_display_max_children = -1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.var_display_max_data = -1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.max_nesting_level = 500" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && mkdir /usr/local/etc/php/debug_conf.d/ \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/debug_conf.d/_xdebug.ini \
    && ln -s /usr/local/etc/php/conf.d/* /usr/local/etc/php/debug_conf.d/

ENV PHP_IDE_CONFIG "serverName=demo"

WORKDIR /var/www/crm


# Move to if dev
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet --install-dir=/usr/local/bin --filename=composer
RUN chown www-data /usr/local/bin/composer
RUN wget https://get.symfony.com/cli/installer -O - | bash
RUN mv /root/.symfony/bin/symfony /usr/local/bin/symfony
RUN chown www-data /usr/local/bin/symfony
RUN chown -R www-data /tmp
RUN usermod -u 1000 www-data

# add token
# fi

USER www-data

WORKDIR /var/www/crm
