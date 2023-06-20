FROM python:3.10-alpine3.15
COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY . /app
WORKDIR /app
EXPOSE 80
CMD python3 ./app.py