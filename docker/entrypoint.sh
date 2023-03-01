#!/usr/bin/env bash
set -Eeuo pipefail

echo >&2 "-------------------------------------------------------------"
echo >&2 "";
echo >&2 "     ██ ██    ██ ███    ███ ██████"
echo >&2 "     ██ ██    ██ ████  ████ ██   ██"
echo >&2 "     ██ ██    ██ ██ ████ ██ ██████"
echo >&2 "██   ██ ██    ██ ██  ██  ██ ██"
echo >&2 " █████   ██████  ██      ██ ██"
echo >&2 "";
echo >&2 "https://github.com/daledavies/jump"
echo >&2 "";
echo >&2 "-------------------------------------------------------------"

if [ -z "${DEVELOPMENT-}" ]; then
    echo >&2 "";
    echo >&2 "- Repopulating web root with application files."

    if [ "$(ls -A /var/www/html)" ]; then
        rm /var/www/html/* -r
    fi
    cp /usr/src/jumpapp/. /var/www/html -r

    echo >&2 "- You are using Jump $(</var/www/html/.jump-version)";
    echo >&2 "";
    echo >&2 "-------------------------------------------------------------"
    echo >&2 "";

    echo >&2 "- Checking if backgrounds, favicon, search or sites volumes have been mounted."
    if [ -e "/backgrounds" ]; then
        echo >&2 "   - Backgrounds directory is mapped... symlinking."
        rm /var/www/html/assets/backgrounds -r
        ln -s /backgrounds /var/www/html/assets/
        if [ ! "$(ls -A /backgrounds)" ]; then
            echo >&2 "     -- Empty so populating with default files."
            cp /usr/src/jumpapp/assets/backgrounds/* /backgrounds -r
        fi
    fi

    if [ -e "/favicon" ]; then
        echo >&2 "   - Favicon directory is mapped... symlinking."
        rm /var/www/html/assets/images/favicon -r
        ln -s /favicon /var/www/html/assets/images/
        if [ ! "$(ls -A /favicon)" ]; then
            echo >&2 "     -- Empty so populating with default favicon image."
            cp /usr/src/jumpapp/assets/images/favicon/* /favicon -r
        fi
    fi

    if [ -e "/sites" ]; then
        echo >&2 "   - Sites directory is mapped... symlinking."
        rm /var/www/html/sites -r
        ln -s /sites /var/www/html/
        if [ ! "$(ls -A /sites)" ]; then
            echo >&2 "     -- Empty so populating with default files."
            cp /usr/src/jumpapp/sites/* /sites -r
        fi
    fi

    if [ -e "/search" ]; then
        echo >&2 "   - Search directory is mapped... symlinking."
        rm /var/www/html/search -r
        ln -s /search /var/www/html/
        if [ ! "$(ls -A /search)" ]; then
            echo >&2 "     -- Empty so populating with default files."
            cp /usr/src/jumpapp/search/* /search -r
        fi
    fi

else
    echo >&2 "";
    echo >&2 "- Setting correct ownership of xdebug dir"
    chown -R jumpapp:jumpapp /tmp/xdebug
fi

DISABLEIPV6=$(echo "${DISABLEIPV6:-}" | tr '[:upper:]' '[:lower:]')

if [ "$DISABLEIPV6" == "true" ] || [ "$DISABLEIPV6" == "1" ]; then
    echo >&2 "";
    echo >&2 "- Disabling IPv6 in nginx config"
    sed -E -i 's/^([^#]*)listen \[::\]/\1#listen [::]/g' /etc/nginx/nginx.conf
else
    sed -E -i 's/^(\s*)#listen \[::\]/\1listen [::]/g' /etc/nginx/nginx.conf
fi

echo >&2 "";
echo >&2 "- All done! Starting nginx/php services now."
echo >&2 "";
echo >&2 "-------------------------------------------------------------"
echo >&2 "";

php-fpm81
nginx -g 'daemon off;'
