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

Названия образов на DockerHub имеет структуру `vendor/package`.
Смотрим первый результат `alpinelinux` - это `vendor`, а `docker-cli` - это `package`. Нам такое не подходит.
Обоссать и на мороз (с).

Смотрим следующий результат поиска - `alpine`.
Когда в названии пакета не указан `vendor`, значит, что пакет официальный. Отлично. То что надо!


Итак, переходим в [alpine](https://hub.docker.com/_/alpine).
Смотрим "Supported tags" - последняя версия alpine на момент написания гайда - `3.21.0`.
Теперь мы знаем версию alpine, которую будем запускать в Docker.


## Команды Docker cli

... (дописать)


## Linux alpine

ОС настолько маленькая, что ее даже пишут с маленькой буквы.

... (дописать)


## Чем Docker отличается от виртуальной машины

- Я пользуюсь Windows 10
- На Windows установлен WSL 2 и Docker Desktop 4.29.0
- Внутри WSL установлена Ubuntu 22.04.3 LTS

Зачем такие сложности?

... (дописать)

