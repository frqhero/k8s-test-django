FROM python:3.9.6-slim-bullseye

WORKDIR /code

COPY requirements.txt /code/

RUN python3 -V

RUN pip3 install -r requirements.txt
    
COPY . /code/

CMD ./manage.py clearsessions
# CMD sleep infinity
