#!/usr/bin/env bash

WIRINGOP_REPO=https://github.com/orangepi-xunlong/wiringOP.git
USTREAMER_REPO=https://github.com/pikvm/ustreamer
KIAUH_REPO=https://github.com/th33xitus/kiauh.git
TELEGRAM_BOT_REPO=http://omv.home:3000/lefskiy/moonraker-telegram-bot.git
#TELEGRAM_BOT_REPO=https://github.com/nlef/moonraker-telegram-bot

install_wiringop(){
    cd  ~
    WOP_FOLDER=wiringOP
    if [ ! -d "${WOP_FOLDER}" ] ; then
        git clone ${WIRINGOP_REPO} ${WOP_FOLDER}
        cd "${WOP_FOLDER}"
    else
        cd "${WOP_FOLDER}"
        git pull ${WIRINGOP_REPO}
    fi

    sudo ./build clean
    sudo ./build install
}

install_deps(){
    sudo apt update
    sudo apt-get install --yes zlib1g-dev libjpeg-dev git build-essential libevent-dev libjpeg-dev libbsd-dev gpiod
}

install_ustreamer(){
    USTREAMER_USER=ustreamer
    cd  ~
    
    USTR_FOLDER=ustreamer
    if [ ! -d "${USTR_FOLDER}" ] ; then
        git clone ${USTREAMER_REPO} ${USTR_FOLDER}
        cd "${USTR_FOLDER}"
    else
        cd "${USTR_FOLDER}"
        git pull ${USTREAMER_REPO}
    fi

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
ExecStart=/usr/local/bin/ustreamer --process-name-prefix ustreamer-0 --log-level 0 --device=/dev/video0 --resolution=1920x1080 --format=MJPEG --encoder=HW --quality=100 --host=0.0.0.0 --port=8080 --workers=1
[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable ustreamer.service
    sudo systemctl start ustreamer.service
}

install_vlc_streamer(){
    VLCSTREAMER_USER=vlcstreamer
    cd  ~
    
    sudo apt-get install --yes vlc

    if [[ $(cat /etc/passwd | grep ${VLCSTREAMER_USER} | wc -l) -eq 0 ]]; then
    	sudo useradd -r ${VLCSTREAMER_USER}
    fi
    sudo usermod -a -G video ${VLCSTREAMER_USER}

    sudo /bin/sh -c "cat > /etc/systemd/system/vlc-streamer.service" <<EOF
#Systemd service file for cvlc webcam stream
[Unit]
Description=Starts cvlc stream 
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
User=vlcstreamer
ExecStart=cvlc -vvv v4l2:///dev/video0:chroma=h264:width=1920:height=1080:fps=30 --sout '#standard{access=http,mux=mp4frag,dst=:8080/stream.mp4}' 
Restart=always
RestartSec=30
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable vlc-streamer.service
    sudo systemctl start vlc-streamer.service
}

download_kiauh(){
    cd  ~

    KIAUH_FOLDER=kiauh
    if [ ! -d "${KIAUH_FOLDER}" ] ; then
        git clone ${KIAUH_REPO} ${KIAUH_FOLDER}
        cd "${KIAUH_FOLDER}"
    else
        cd "${KIAUH_FOLDER}"
        git pull ${KIAUH_REPO}
    fi

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

    TBOT_FOLDER=moonraker-telegram-bot
    if [ ! -d "${TBOT_FOLDER}" ] ; then
        git clone ${TELEGRAM_BOT_REPO} ${TBOT_FOLDER}
        cd "${TBOT_FOLDER}"
    else
        cd "${TBOT_FOLDER}"
        git pull ${TELEGRAM_BOT_REPO}
    fi

    ./install.sh 
}

install_wiringop
install_deps
#install_ustreamer
install_vlc_streamer
download_kiauh
install_telegram_bot

