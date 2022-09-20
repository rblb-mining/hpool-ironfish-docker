FROM nvidia/cuda:11.7.1-runtime-ubuntu22.04
RUN apt update -y && apt install -y curl unzip python3 python3-pip jq && apt clean -y
RUN pip3 install yq
RUN mkdir -p /hpool
COPY init.sh /hpool/init.sh
RUN chmod +x /hpool/init.sh
WORKDIR /hpool
ENTRYPOINT [ "/bin/sh","-c","/hpool/init.sh" ]




