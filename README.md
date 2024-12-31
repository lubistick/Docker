# Docker Compendium

Это про [Docker](https://www.docker.com).
Мы запустим php framework [Laravel](https://laravel.com) с помощью Docker с кое-какими инструментами для Backend разработки.


## Цель проекта

Мы поговорим про:
- [Реестр образов](#реестр-образов)
- [Основных командах Docker](#команды-docker-cli)
- [Об операционной системе Linux alpine](#linux-alpine)
    - [Пакетный менеджер apk](#пакетный-менеджер-apk)
    - [Установку php](#установка-php)
    - [Установку composer](#установка-composer)
    - [Установку Laravel](#установка-laravel)
- Основных командах Dockerfile
- Утилите docker-compose
- Базу данных Postgres
- Cервер Nginx
- Чем Docker отличается от виртуальной машины
- Запустим Laravel в Docker

И самое главное - расскажу как я размышляю при решении новых задач.


## Реестр образов

[меню](#цель-проекта)

Обычно свои образы собирают на базе образа "alpine".
Поищем в официальном реестре Docker.
Заходим на [DockerHub](https://hub.docker.com) и ищем `linux alpine`.

В результатах поиска мы увидим:
- `alpinelinux/docker-cli`
- `alpine`
- `alpine/git`

Названия образов на DockerHub имеет структуру `<vendor>/<package>`.
Смотрим первый результат:
- `alpinelinux` - это `<vendor>` или команда разработчиков
- `docker-cli` - это `<package>` собственно пакет

Нам такое не подходит.

Смотрим следующий результат поиска - `alpine`.
Названия образов на DockerHub имеет и другую структуру - просто `<package>` - значит,
что пакет официальный. Отлично. То что надо!

Итак, переходим в [alpine](https://hub.docker.com/_/alpine).
Смотрим "Supported tags" - последняя версия alpine на момент написания гайда - `3.21.0`.
Теперь мы знаем версию alpine, которую будем запускать в Docker.


## Команды Docker cli

[меню](#цель-проекта)

Можно пользоваться GUI версией Docker Desktop.
Но я буду использовать консоль.
Вспомним основные команды Docker cli.

Откроем консоль и напишем:
```sh
docker --help
```

Это справка.
К любой программе в Linux можно написать `<program> --help` и получить справку.
Или `<program> <command> --help` для справки по конкретной команде программы.
Например, `docker run --help`.

Посмотрим список образов:
```sh
docker images

REPOSITORY   TAG         IMAGE ID       CREATED        SIZE
postgres     14-alpine   7f76e70684c3   6 months ago   239MB
```
 
На примере образа Postgres:
- `REPOSITORY` - название образа (postgres)
- `TAG` - версия (14-alpine)
- `IMAGE ID` - ID образа, по которому его можно найти командами Docker (7f76e70684c3)
- `CREATED` - когда создан (6 months ago)
- `SIZE` - сколько занимает памяти на диске (239MB)

Скачаем из реестра образ Linux alpine:

```sh
docker pull alpine:3.21.0

3.21.0: Pulling from library/alpine
38a8310d387e: Already exists 
Digest: sha256:21dc6063fd678b478f57c0e13f47560d0ea4eeba26dfc947b2a4f81f686b9f45
Status: Downloaded newer image for alpine:3.21.0
docker.io/library/alpine:3.21.0

What's Next?
  View a summary of image vulnerabilities and recommendations → docker scout quickview alpine:3.21.0
```

Посмотрим список образов:

```sh
docker images

REPOSITORY   TAG         IMAGE ID       CREATED        SIZE
alpine       3.21.0      4048db5d3672   2 weeks ago    7.84MB
postgres     14-alpine   7f76e70684c3   6 months ago   239MB
```

Обратите внимание, как мало весит Linux alpine (7.84MB).

Создадим контейнер из образа и запустим его:

```sh
docker run alpine:3.21.0
```

Хмм.. не запустилось. Посмотрим контейнеры:
```sh
docker ps

CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

Ни одного контейнера. Посмотрим все контейнеры, включая остановленные:

```sh
docker ps -a

CONTAINER ID   IMAGE           COMMAND     CREATED              STATUS                          PORTS     NAMES
db02305c0ddb   alpine:3.21.0   "/bin/sh"   About a minute ago   Exited (0) About a minute ago             elastic_golick
```

Что выдала команда:
- `CONTAINER ID` - ID контейнера, по которому его можно найти командами Docker (db02305c0ddb)
- `IMAGE` - образ, из которого создан контейнер (alpine:3.21.0)
- `COMMAND` - ...
- `CREATED` - когда создан контейнер (About a minute ago)
- `STATUS` - статус (Exited (0) About a minute ago)
- `PORTS` - какие порты открыты внутри и снаружи контейнера (никакие)
- `NAMES` - название контейнера, как альтернатива айдишнику (elastic_golick)

Получается контейнер запущен и тут же остановлен.
Чтобы контейнер не останавливался, нужно чтобы в нем работал какой-либо процесс.

Напишем такую команду:

```sh
docker run -i -t --rm alpine:3.21.0 sh

/ #
```

Мы только что создали и запустили контейнер командой `run` с дополнительными флагами:
- `-i` - интерактивный режим
- `-t` - режим псевдо-TTY
- `--rm` - автоматически удалить контейнер после остановки

Приглашение в консоли поменялось, мы внутри Lunux apline.
Посмотрим процессы внутри контейнера:

```sh
ps

PID   USER     TIME  COMMAND
    1 root      0:00 sh
    7 root      0:00 ps
```

Результат выполнения команды на примере sh:
- `PID` - ID процесса в ОС Linux (1)
- `USER` - пользователь, запустивший процесс (root)
- `TIME` - ...
- `COMMAND` - запущенная команда (sh)


В контейнере постоянно работает процесс sh, поэтому контейнер не завершает работу. Отлично!


## Linux alpine

[меню](#цель-проекта)

ОС [Linux alpine](https://alpinelinux.org) настолько маленькая, что ее даже пишут с маленькой буквы.


### Пакетный менеджер apk

[меню](#цель-проекта)

Пакетный менеджер для alpine - это [apk](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper).
Посмотрим, что он умеет:

```sh
apk --help
```

Видим, что можно установить последние обновления - хорошая практика, делаем:

```sh
apk upgrade

fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/community/x86_64/APKINDEX.tar.gz
(1/3) Upgrading busybox (1.37.0-r8 -> 1.37.0-r9)
Executing busybox-1.37.0-r9.post-upgrade
(2/3) Upgrading busybox-binsh (1.37.0-r8 -> 1.37.0-r9)
(3/3) Upgrading ssl_client (1.37.0-r8 -> 1.37.0-r9)
Executing busybox-1.37.0-r9.trigger
OK: 7 MiB in 15 packages
```

Обновим данные из репозиториев для скачивания:

```sh
apk update

fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/community/x86_64/APKINDEX.tar.gz
v3.21.0-187-g0d6c022f3e5 [https://dl-cdn.alpinelinux.org/alpine/v3.21/main]
v3.21.0-192-g6f058067d40 [https://dl-cdn.alpinelinux.org/alpine/v3.21/community]
OK: 25391 distinct packages available
```


### Установка php

[меню](#цель-проекта)

Поищем `php`:

```sh
apk search php
```

Видим очень много пакетов. Мы выберем и установим `php84`:

```sh
apk add php84

(1/9) Installing php84-common (8.4.2-r0)
(2/9) Installing argon2-libs (20190702-r5)
(3/9) Installing ncurses-terminfo-base (6.5_p20241006-r3)
(4/9) Installing libncursesw (6.5_p20241006-r3)
(5/9) Installing libedit (20240808.3.1-r0)
(6/9) Installing pcre2 (10.43-r0)
(7/9) Installing xz-libs (5.6.3-r0)
(8/9) Installing libxml2 (2.13.4-r3)
(9/9) Installing php84 (8.4.2-r0)
Executing busybox-1.37.0-r9.trigger
OK: 18 MiB in 24 packages
```

Мы установили php внутри alpine! Проверим:

```sh
php -v

sh: php: not found
```

Нет... В чем дело?
Установленные в Linux программы обычно лежат в директории `/usr/bin`.
Посмотрим там программу `php`:

```sh
ls -la /usr/bin
```

Чтобы не искать глазами по большому списку,
результат вывода команды `ls -la` можно отфильтровать через пайп `|` с помощью команды `grep`:

```sh
ls -la /usr/bin | grep php

-rwxr-xr-x    1 root     root       8394856 Dec 19 09:30 php84
```

Называется `php84`. Попробуем вызвать php так:

```sh
php84 -v

PHP 8.4.2 (cli) (built: Dec 19 2024 09:30:47) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.4.2, Copyright (c) Zend Technologies
```

Сделаем символическую ссылку, чтобы удобнее вызывать php:

```sh
ln -s /usr/bin/php84 /usr/bin/php
```

Попробуем:

```sh
php -v

PHP 8.4.2 (cli) (built: Dec 19 2024 09:30:47) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.4.2, Copyright (c) Zend Technologies
```

Отлично мы поставили php внутри Docker контейнера с Linux alpine!


### Установка Composer

[меню](#цель-проекта)

Установим [Composer](https://getcomposer.org) - пакетный менеджер для php.
Переходим в раздел [Download Composer](https://getcomposer.org/download) и видим заголовок "Command-line installation".
Введем предложенные команды для установки.

Команда `php` с флагом `-r` запустит php код, написанный в кавычках, а именно скачает установщик Composer:

```sh
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

PHP Warning:  copy(): Unable to find the wrapper "https" - did you forget to enable it when you configured PHP? in Command line code on line 1
PHP Warning:  copy(): Unable to find the wrapper "https" - did you forget to enable it when you configured PHP? in Command line code on line 1
PHP Warning:  copy(): Unable to find the wrapper "https" - did you forget to enable it when you configured PHP? in Command line code on line 1
PHP Warning:  copy(https://getcomposer.org/installer): Failed to open stream: No such file or directory in Command line code on line 1
```

Хмм... PHP Warning...

Пишет: "Не найти обертку для https, наверно вы забыли ее включить, когда конфигурировали php".
Подозреваю, что речь идет про Curl, т.к. мы ходим по http с помощью него.
Как это решать? Или знать, или гуглить.

Я знаю, что есть протоколы http и https, где "s" на конце означает "secure".
По-другому его еще называют SSL. Поэтому вместо гугла, поищу в менеджере `apk`:

```sh
apk search php84 | grep ssl

php84-openssl-8.4.2-r0
```

Отлично, ставим php openssl:

```sh
apk add php84-openssl

(1/1) Installing php84-openssl (8.4.2-r0)
OK: 22 MiB in 34 packages
```

Пробуем установить composer:

```sh
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
```

Без ошибок. Делаем дальше:

```sh
php composer-setup.php

Some settings on your machine make Composer unable to work properly.
Make sure that you fix the issues listed below and run this script again:

The phar extension is missing.
Install it or recompile php without --disable-phar

The iconv OR mbstring extension is required and both are missing.
Install either of them or recompile php without --disable-iconv
```

Все красно-желтое. Почитаем вывод команды выше:
"Некоторые настройки на вашей машине мешают Composer работать правильно.
Исправьте ощибки ниже и перезапустите скрипт заново":
- Отсутствует расширение "phar".
- Установите или расширение "iconv", или "mbstring", или установите оба расширения.

Ищем "phar":

```sh
apk search php84 | grep phar

php84-phar-8.4.2-r0
```

Установим:

```sh
apk add php84-phar

(1/1) Installing php84-phar (8.4.2-r0)
Executing busybox-1.37.0-r9.trigger
OK: 18 MiB in 26 packages
```

Ищем "iconv":

```sh
apk search php84 | grep iconv

php84-iconv-8.4.2-r0
```

Установим:

```sh
apk add php84-iconv

(1/1) Installing php84-iconv (8.4.2-r0)
OK: 18 MiB in 27 packages
```

Ищем "mbstring":

```sh
apk search php84 | grep mbstring

php84-mbstring-8.4.2-r0
```

Установим:

```sh
apk add php84-mbstring

(1/2) Installing oniguruma (6.9.9-r0)
(2/2) Installing php84-mbstring (8.4.2-r0)
OK: 20 MiB in 29 packages
```

И перезапускаем скрипт:

```sh
php composer-setup.php

All settings correct for using Composer
Downloading...

Composer (version 2.8.4) successfully installed to: //composer.phar
Use it: php composer.phar
```

Отлично, мы установили Composer! Проверим:

```sh
php composer.phar

   ______
  / ____/___  ____ ___  ____  ____  ________  _____
 / /   / __ \/ __ `__ \/ __ \/ __ \/ ___/ _ \/ ___/
/ /___/ /_/ / / / / / / /_/ / /_/ (__  )  __/ /
\____/\____/_/ /_/ /_/ .___/\____/____/\___/_/
                    /_/
Composer version 2.8.4 2024-12-11 11:57:47
```

Установщик больше не нужен, удалим его:

```sh
php -r "unlink('composer-setup.php');"
```


### Установка Laravel

Итак заходим на официальный сайт [Laravel](https://laravel.com).
Жмем "Get started", вообще жать эту кнопку на сайтах с незнакомыми технологиями - хорошая практика.
Видим кнопку - жмем.

Находим заголовок "Creating a Laravel Application".
Ипользуем Composer, чтобы скачать установщик Laravel:

```sh
composer global require laravel/installer

sh: composer: not found
```

Ах да, надо обращаться к Composer так:

```sh
php composer.phar global require laravel/installer
```

Пошла установка... Готово. Делаем дальше:

```sh
laravel new example-app

sh: laravel: not found
```

Обратим внимание на вывод предыдущей команды для скачивания установщика.
Первая строка вывода "Текущая директория изменена на /root/.composer".
Посмотрим, что там:

```sh
ls -la /root/.composer/

total 108
drwxr-xr-x    4 root     root          4096 Dec 31 22:29 .
drwx------    1 root     root          4096 Dec 31 22:14 ..
-rw-r--r--    1 root     root            13 Dec 31 22:15 .htaccess
drwxr-xr-x    4 root     root          4096 Dec 31 22:29 cache
-rw-r--r--    1 root     root            64 Dec 31 22:29 composer.json
-rw-r--r--    1 root     root         74101 Dec 31 22:29 composer.lock
-rw-r--r--    1 root     root           799 Dec 31 22:14 keys.dev.pub
-rw-r--r--    1 root     root           799 Dec 31 22:14 keys.tags.pub
drwxr-xr-x   12 root     root          4096 Dec 31 22:29 vendor
```

Нашли папку vendor:

```sh
ls -la /root/.composer/vendor/

total 52
drwxr-xr-x   12 root     root          4096 Dec 31 22:29 .
drwxr-xr-x    4 root     root          4096 Dec 31 22:29 ..
-rw-r--r--    1 root     root           771 Dec 31 22:29 autoload.php
drwxr-xr-x    2 root     root          4096 Dec 31 22:29 bin
drwxr-xr-x    3 root     root          4096 Dec 31 22:29 carbonphp
drwxr-xr-x    2 root     root          4096 Dec 31 22:29 composer
drwxr-xr-x    3 root     root          4096 Dec 31 22:29 doctrine
drwxr-xr-x    8 root     root          4096 Dec 31 22:29 illuminate
drwxr-xr-x    4 root     root          4096 Dec 31 22:29 laravel
drwxr-xr-x    3 root     root          4096 Dec 31 22:29 nesbot
drwxr-xr-x    5 root     root          4096 Dec 31 22:29 psr
drwxr-xr-x   16 root     root          4096 Dec 31 22:29 symfony
drwxr-xr-x    3 root     root          4096 Dec 31 22:29 voku
```

Посмотрим, какие есть бинарники:

```sh
ls -l /root/.composer/vendor/bin/

total 8
-rwxr-xr-x    1 root     root          3330 Dec 31 22:29 carbon
-rwxr-xr-x    1 root     root          3345 Dec 31 22:29 laravel
```

Вот и установщик Laravel.


Todo:

```sh
/root/.composer/vendor/bin/laravel new example-app

   _                               _
  | |                             | |
  | |     __ _ _ __ __ ___   _____| |
  | |    / _` | '__/ _` \ \ / / _ \ |
  | |___| (_| | | | (_| |\ V /  __/ |
  |______\__,_|_|  \__,_| \_/ \___|_|


In NewCommand.php line 179:
                                                                                                  
  The following PHP extensions are required but are not installed: ctype, session, and tokenizer
```

Не хватает расширений php: ctype, session и tokenizer.

Todo:

```sh
todo
```


## Dockerfile

... дописать


## Чем Docker отличается от виртуальной машины

[меню](#цель-проекта)

Как я запускаю Docker:
- На Windows 10 установлены WSL 2 и Docker Desktop 4.29.0
- Внутри WSL установлена Ubuntu 22.04.3 LTS

Зачем такие сложности?

```sh
дописать
```

