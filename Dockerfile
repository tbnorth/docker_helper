FROM python

RUN apt-get update && apt-get install -y docker.io

COPY docker_data.py /

CMD ["python", "/docker_data.py", "--did"]

