#!/bin/bash

install_wiringop(){
    cd  ~
    git clone https://github.com/orangepi-xunlong/wiringOP.git
    cd wiringOP
    sudo ./build clean
    sudo ./build install
}

install_deps(){
    sudo apt update
    sudo apt-get install --yes zlib1g-dev libjpeg-dev git
}

install_ustreamer(){
    cd  ~
    sudo apt install --yes build-essential libevent-dev libjpeg-dev libbsd-dev
    git clone --depth=1 https://github.com/pikvm/ustreamer
    cd ustreamer/
    sudo make install
    sudo useradd -r ustreamer
    sudo usermod -a -G video ustreamer

    sudo /bin/sh -c "cat > /etc/systemd/system/ustreamer.service" <<EOF
[Unit]
Description=uStreamer service
After=network.target
[Service]
User=ustreamer
ExecStart=/usr/local/bin/ustreamer --process-name-prefix ustreamer-0 --log-level 0 --device=/dev/video0 --resolution=1280x960 --format=MJPEG --encoder=HW --quality=100 --host=0.0.0.0 --port=8080 --workers=1
[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable ustreamer.service
    sudo systemctl start ustreamer.service
}


download_kiauh(){
    cd  ~
    git clone https://github.com/th33xitus/kiauh.git 
    cd kiauh
    ./kiauh.sh

}

install_telegram_bot(){
    cd  ~
    git clone http://omv.home:3000/lefskiy/moonraker-telegram-bot.git
    cd moonraker-telegram-bot/
    ./install.sh 
}

install_wiringop
install_deps
install_ustreamer
download_kiauh
install_telegram_bot

