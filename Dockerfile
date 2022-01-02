FROM  xeffyr/termux:latest

WORKDIR /data/data/com.termux/files/home

RUN apt update -y && apt install git 

RUN git clone https://github.com/adi1090x/termux-desktop

WORKDIR /data/data/com.termux/files/home/termux-desktop

# COPY setup.sh setup.sh

ENTRYPOINT [ "./setup.sh", "--install" ]
