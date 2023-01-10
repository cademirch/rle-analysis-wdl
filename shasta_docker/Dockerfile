FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
RUN curl -O -L https://github.com/paoloshasta/shasta/releases/download/0.11.1/shasta-Linux-0.11.1
RUN chmod +x shasta-Linux-0.11.1 && mv shasta-Linux-0.11.1 /bin/shasta && mkdir /data
WORKDIR /data