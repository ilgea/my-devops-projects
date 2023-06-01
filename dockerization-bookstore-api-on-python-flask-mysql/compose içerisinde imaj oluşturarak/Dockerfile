# FROM alpine:3.18
FROM python:3.7-alpine
COPY requirements.txt .
# requirements.txt dosyasını konteynır'ın root'una kopyalıyoruz.
RUN pip install -r requirements.txt
# İlk önce gereklilikleri yükleme adımını yapıyoruz. Her uygulama değiştiğinde bunları tekrar yüklemeye gerek kalmasın.
COPY bookstore-api.py ./app/app.py
# bookstore-api.py uygulamasını konteynır içerisine, konteynır'ın root'u altındaki app isimli klasörün içaerisine app.py olarak atıyoruz.
WORKDIR /app
# /app dizinine geçiyoruz. Bir nevi cd işlevi gibi düşünebilirsin.
EXPOSE 80
CMD python app.py