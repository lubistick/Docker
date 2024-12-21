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
Смотрим первый результат `alpinelinux` - это `vendor`, а `docker-cli` - это `package`. Нам такое не подходит.
Обоссать и на мороз (с).

Смотрим следующий результат поиска - `alpine`.
Когда в названии пакета не указан `vendor`, значит, что пакет официальный. Отлично. То что надо!


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
с дополнительными флагами `-i` (интерактивный режим) и `-t` (режим псевдо-TTY):

```sh
docker run -i -t alpine:3.21.0 sh

/ #
```

Теперь контейнер работает и мы внутри Lunux apline.
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

... (дописать)


## Чем Docker отличается от виртуальной машины

- Я пользуюсь Windows 10
- На Windows установлен WSL 2 и Docker Desktop 4.29.0
- Внутри WSL установлена Ubuntu 22.04.3 LTS

Зачем такие сложности?

... (дописать)

