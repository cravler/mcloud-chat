#!/bin/bash

echo "Waiting while mysql starts"
while ! echo exit | nc -z mysql 3306; do
    echo ".";
    sleep 3;
done

if [ ! -d /var/www/sf ]; then

    composer create-project --no-interaction symfony/framework-standard-edition /var/www/sf/ "2.5.*"
    chmod +x /var/www/sf/app/console
    cp -R /var/www/.mcloud/php/sf/* /var/www/sf
    sf/app/console doctrine:database:create

    # Install chat
    /var/www/sf/app/console generate:bundle --namespace=Cravler/RemoteBundle --no-interaction --dir=/var/www/sf/src
    /var/www/sf/app/console generate:bundle --namespace=Cravler/ChatBundle --no-interaction --dir=/var/www/sf/src
    composer require cravler/remote-bundle:dev-master --working-dir=/var/www/sf/
    composer require cravler/chat-bundle:dev-master --working-dir=/var/www/sf/
    rm -rf /var/www/sf/src/Cravler
    /var/www/sf/app/console assets:install sf/web/

    echo '' >> /var/www/sf/app/config/config.yml
    echo 'cravler_remote:' >> /var/www/sf/app/config/config.yml
    echo '    app_port: 8080:80' >> /var/www/sf/app/config/config.yml
    echo '    remote_host: "remote"' >> /var/www/sf/app/config/config.yml
    echo '    secret: "%secret%"' >> /var/www/sf/app/config/config.yml

    echo '' > /var/www/sf/app/config/routing.yml
    echo 'cravler_remote:' >> /var/www/sf/app/config/routing.yml
    echo '    resource: "@CravlerRemoteBundle/Resources/config/routing.xml"' >> /var/www/sf/app/config/routing.yml
    echo '' >> /var/www/sf/app/config/routing.yml
    echo 'cravler_chat:' >> /var/www/sf/app/config/routing.yml
    echo '    resource: "@CravlerChatBundle/Resources/config/routing.xml"' >> /var/www/sf/app/config/routing.yml
    echo '    prefix:   /' >> /var/www/sf/app/config/routing.yml

else

    composer install --no-interaction --working-dir=/var/www/sf/

fi

php5-fpm -R