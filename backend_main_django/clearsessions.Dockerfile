from python:3.9-slim-bullseye

WORKDIR /code

COPY requirements.txt /code/

RUN apt update && apt install -y python3-pip                                  \
    && pip3 install -r requirements.txt                                       \
    && apt remove -y python3-pip                                              \
    && apt autoremove --purge -y
    
COPY . /code/

CMD ./manage.py clearsessions
