#!/bin/bash
chmod 777 -R /var/www/html/
cd /var/www/html/
bin/magento setup:upgrade
bin/magento setup:static-content:deploy -f
service nginx restart
service php8.2-fpm restart

