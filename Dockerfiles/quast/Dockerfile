FROM ubuntu:20.04
RUN apt-get update -y && apt-get install -y python3 python3-pip
RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install quast  && mkdir /data
WORKDIR /data