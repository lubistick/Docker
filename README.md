# Docker Compendium

Это про [Docker](https://www.docker.com).
Мы запустим [Laravel](https://laravel.com) с помощью Docker с кое-какими инструментами для Backend разработки.


## Цель проекта

Мы поговорим про:

- Реестр образов
- Основных командах Docker
- Об операционной системе [Linux alpine](https://alpinelinux.org)
- 
- Чем Docker отличается от виртуальной машины
- Запустим Laravel в Docker

И самое главное - расскажу как я размышляю при решении новых задач.


## Реестр образов

Образ alpine будем искать в официальном реестре Docker.
Заходим на [DockerHub](https://hub.docker.com) и ищем образ `linux alpine`.

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

Можно пользоваться GUI версией Docker Desktop.
Но я буду использовать консоль.
Вспомним основные команды Docker cli.

Откроем консоль и напишем:
```sh
docker --help
```

Это справка. К любой программе в Linux можно написать `<program> --help` и получить справку. Или `<program> <command> --help` для справки по конкретной команде программы. Например, `docker run --help`.

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

Создадим и запустим контейнер командой `run`
с дополнительными флагами `-i` (интерактивный режим), `-t` (режим псевдо-TTY)
и `--rm` (автоматически удалить контейнер после остановки):

```sh
docker run -i -t -rm alpine:3.21.0 sh

/ #
```

Приглашение в консоли поменялось, мы внутри Lunux apline.
Посмотрим процессы внутри контейнера:
```sh
/ # ps

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

ОС настолько маленькая, что ее даже пишут с маленькой буквы.


### Пакетный менеджер apk

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


### Установка composer

Установим пакетный менеджер для php - composer.

```sh
дописать
```


## Чем Docker отличается от виртуальной машины

- Я пользуюсь Windows 10
- На Windows установлен WSL 2 и Docker Desktop 4.29.0
- Внутри WSL установлена Ubuntu 22.04.3 LTS

Зачем такие сложности?

```sh
дописать
```

