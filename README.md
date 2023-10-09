# Django site

Докеризированный сайт на Django для экспериментов с Kubernetes.

Внутри конейнера Django запускается с помощью Nginx Unit, не путать с Nginx. Сервер Nginx Unit выполняет сразу две функции: как веб-сервер он раздаёт файлы статики и медиа, а в роли сервера-приложений он запускает Python и Django. Таким образом Nginx Unit заменяет собой связку из двух сервисов Nginx и Gunicorn/uWSGI. [Подробнее про Nginx Unit](https://unit.nginx.org/).

## Как запустить dev-версию

Запустите базу данных и сайт:

```shell-session
$ docker-compose up
```

В новом терминале не выключая сайт запустите команды для настройки базы данных:

```shell-session
$ docker-compose run web ./manage.py migrate  # создаём/обновляем таблицы в БД
$ docker-compose run web ./manage.py createsuperuser
```

Для тонкой настройки Docker Compose используйте переменные окружения. Их названия отличаются от тех, что задаёт docker-образа, сделано это чтобы избежать конфликта имён. Внутри docker-compose.yaml настраиваются сразу несколько образов, у каждого свои переменные окружения, и поэтому их названия могут случайно пересечься. Чтобы не было конфликтов к названиям переменных окружения добавлены префиксы по названию сервиса. Список доступных переменных можно найти внутри файла [`docker-compose.yml`](./docker-compose.yml).

## Переменные окружения

Образ с Django считывает настройки из переменных окружения:

`SECRET_KEY` -- обязательная секретная настройка Django. Это соль для генерации хэшей. Значение может быть любым, важно лишь, чтобы оно никому не было известно. [Документация Django](https://docs.djangoproject.com/en/3.2/ref/settings/#secret-key).

`DEBUG` -- настройка Django для включения отладочного режима. Принимает значения `TRUE` или `FALSE`. [Документация Django](https://docs.djangoproject.com/en/3.2/ref/settings/#std:setting-DEBUG).

`ALLOWED_HOSTS` -- настройка Django со списком разрешённых адресов. Если запрос прилетит на другой адрес, то сайт ответит ошибкой 400. Можно перечислить несколько адресов через запятую, например `127.0.0.1,192.168.0.1,site.test`. [Документация Django](https://docs.djangoproject.com/en/3.2/ref/settings/#allowed-hosts).

`DATABASE_URL` -- адрес для подключения к базе данных PostgreSQL. Другие СУБД сайт не поддерживает. [Формат записи](https://github.com/jacobian/dj-database-url#url-schema).

## Работа с Kubernetes

### Для раскатки проекта в миникуб кластере необходимо выполнить следующие команды
1. `minikube start`
2. `kubectl apply -f configmap.yaml`
3. `kubectl apply -f deployment.yaml`
4. `minikube service --all`
### При изменении переменных окружения в configmap.yaml для вступлениях их в силу нужно выполнить следующие команды  
1. `kubectl apply -f configmap.yaml`
2. `kubectl rollout restart deployment django-deployment`
### Запуск ingress
1. `kubectl apply -f ingress.yaml`
2. `minikube addons enable ingress`
3. `kubectl get ingress` полученный `ADDRESS` добавить в /etc/hosts замапив с желаемым псевдонимом
4. Проверить доступность приложения в браузере
### Запуск cronjob
1. `kubectl apply -f cronjob.yaml`
#### For creation one time job from existing cronjob
1. `kubectl create job --from=cronjob/clearsessions onejob`


### Для запуска postgres с помощью helm chart
1. Установить helm с помощью snap  
`sudo snap install helm --classic`
2. Запустить release of postgresql chart  
`helm install my-release oci://registry-1.docker.io/bitnamicharts/postgresql`
* При запуске в командной строке появляются инструкции для подключения к базе изнутри и снаружи кластера, запуска psql