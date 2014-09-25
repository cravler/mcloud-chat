#!/bin/bash

echo "Waiting while mysql starts"
while ! echo exit | nc -z mysql 3306; do
    echo ".";
    sleep 3;
done

if [ ! -d ./sf ]; then

    composer create-project --no-interaction symfony/framework-standard-edition sf/ "2.5.*"
    chmod +x sf/app/console
    cp -R .sf/* sf
    sf/app/console doctrine:database:create

    # Install chat
    sf/app/console generate:bundle --namespace=Cravler/RemoteBundle --no-interaction --dir=sf/src
    sf/app/console generate:bundle --namespace=Cravler/ChatBundle --no-interaction --dir=sf/src
    composer require cravler/remote-bundle:dev-master --working-dir=sf/
    composer require cravler/chat-bundle:dev-master --working-dir=sf/
    rm -rf sf/src/Cravler
    sf/app/console assets:install sf/web/

    echo '' >> sf/app/config/config.yml
    echo 'cravler_remote:' >> sf/app/config/config.yml
    echo '    app_port: 8080:80' >> sf/app/config/config.yml
    echo '    remote_host: "remote"' >> sf/app/config/config.yml
    echo '    secret: "%secret%"' >> sf/app/config/config.yml

    echo '' > sf/app/config/routing.yml
    echo 'cravler_remote:' >> sf/app/config/routing.yml
    echo '    resource: "@CravlerRemoteBundle/Resources/config/routing.xml"' >> sf/app/config/routing.yml
    echo '' >> sf/app/config/routing.yml
    echo 'cravler_chat:' >> sf/app/config/routing.yml
    echo '    resource: "@CravlerChatBundle/Resources/config/routing.xml"' >> sf/app/config/routing.yml
    echo '    prefix:   /' >> sf/app/config/routing.yml

else

    composer install --no-interaction --working-dir=sf/

fi

php5-fpm -R