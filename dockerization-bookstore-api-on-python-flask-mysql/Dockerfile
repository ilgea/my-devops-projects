FROM python:3.10-alpine3.15
COPY . /app
WORKDIR /app
RUN pip3 install -r requirements.txt
EXPOSE 80
CMD python3 ./bookstore-api.py