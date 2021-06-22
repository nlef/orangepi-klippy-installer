#!/usr/bin/env bash

WIRINGOP_REPO=https://github.com/orangepi-xunlong/wiringOP.git
USTREAMER_REPO=https://github.com/pikvm/ustreamer
KIAUH_REPO=https://github.com/th33xitus/kiauh.git
#TELEGRAM_BOT_REPO=http://omv.home:3000/lefskiy/moonraker-telegram-bot.git
TELEGRAM_BOT_REPO=https://github.com/nlef/moonraker-telegram-bot

install_wiringop(){
    cd  ~
    git clone ${WIRINGOP_REPO}
    cd wiringOP
    sudo ./build clean
    sudo ./build install
}

install_deps(){
    sudo apt update
    sudo apt-get install --yes zlib1g-dev libjpeg-dev git
}

install_ustreamer(){
    USTREAMER_USER=ustreamer
    cd  ~
    sudo apt install --yes build-essential libevent-dev libjpeg-dev libbsd-dev
    git clone --depth=1 ${USTREAMER_REPO}
    cd ustreamer/
    sudo make install
    if [[ $(cat /etc/passwd | grep ${USTREAMER_USER} | wc -l) -eq 0 ]]; then
    	sudo useradd -r ${USTREAMER_USER}
    fi
    sudo usermod -a -G video ${USTREAMER_USER}

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

    sudo systemctl daemon-reload
    sudo systemctl enable ustreamer.service
    sudo systemctl start ustreamer.service
}


download_kiauh(){
    cd  ~
    git clone ${KIAUH_REPO}
    cd kiauh
	read -p "Do you want return log path to /tmp? (y/N):" yn
	while true; do
        case "$yn" in
        Y|y|Yes|yes)
                echo "Return log path to /tmp"
				find . -type f -print0 | xargs -0 sed -i 's|${HOME}/klipper_logs|/tmp|g'
                break;;
        N|n|No|no|"") break;;
		*) break;;
        esac
	done
    ./kiauh.sh

}

install_telegram_bot(){
    cd  ~
    git clone ${TELEGRAM_BOT_REPO}
    cd moonraker-telegram-bot/
    ./install.sh 
}

install_wiringop
install_deps
install_ustreamer
download_kiauh
install_telegram_bot

