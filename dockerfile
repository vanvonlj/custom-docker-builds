FROM kasmweb/ubuntu-noble-desktop:develop
LABEL maintainer="borsatto at mail dot com"

USER root

RUN echo 'root:Kasm123!' | sudo chpasswd
RUN echo 'kasm-user:Kasm123!' | sudo chpasswd

# Fixing the dockerstartup dir
COPY dockerstartup.zip /tmp/
RUN unzip -o /tmp/dockerstartup.zip -d /
RUN rm /tmp/dockerstartup.zip

# Kasm
ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

# Cleaning up the Image for other apps
# -------------------------------------------

RUN rm /home/kasm-default-profile/Desktop/*.*
RUN rm -Rf /opt/onlyoffice/
RUN rm -Rf /opt/Telegram/

# Removing sublime and other unnecessary pkgs
RUN apt remove -y thunderbird zoom slack-desktop sublime-text google-chrome-stable signal-desktop && apt autoremove -y

# -------------------------------------------
# End of cleanup procedure


# -------------------------------------------


RUN apt update
RUN apt install -y apt-transport-https software-properties-common

# Download / Install Microsoft Repo
RUN wget http://ftp.ie.debian.org/debian/pool/main/i/icu/libicu72_72.1-3_amd64.deb
RUN wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/powershell-lts_7.4.6-1.deb_amd64.deb
RUN dpkg -i libicu72_72.1-3_amd64.deb
RUN dpkg -i powershell-lts_7.4.6-1.deb_amd64.deb
RUN rm libicu72_72.1-3_amd64.deb powershell-lts_7.4.6-1.deb_amd64.deb

# Download / Install eza Repo
RUN apt install -y gpg
RUN mkdir -p /etc/apt/keyrings
RUN wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
RUN chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Updating the pkgs list
RUN apt update

# Installing the new pkgs and few other things
RUN apt-get install -y eza fzf unzip 

# Installing obsidian
RUN wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.7.7/obsidian_1.7.7_amd64.deb
RUN dpkg -i obsidian_1.7.7_amd64.deb
RUN rm obsidian_1.7.7_amd64.deb

# Installing Github Desktop
RUN wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
RUN sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" > /etc/apt/sources.list.d/shiftkey-packages.list'
RUN sudo apt update && sudo apt install github-desktop

# Install Insomnia
RUN curl -1sLf 'https://packages.konghq.com/public/insomnia/setup.deb.sh' | sudo -E distro=ubuntu codename=focal bash
RUN sudo apt-get update
RUN sudo apt-get install insomnia

# Removing any unecessary pkgs
RUN apt remove -y obs-studio thunderbird vlc slack
RUN apt update
RUN apt autoremove -y

# Installing most used Powershell modules
RUN pwsh -Command Install-Module VMware.PowerCLI -Force
RUN pwsh -Command Install-Module -Name Az -Repository PSGallery -Force

# Installing starship
RUN wget https://starship.rs/install.sh
RUN chmod +x install.sh
RUN ./install.sh -y
RUN mkdir -p /home/kasm-default-profile/.config/powershell/
RUN echo 'Invoke-Expression (&starship init powershell)' > /home/kasm-default-profile/.config/powershell/Microsoft.PowerShell_profile.ps1

# Upgrading pkgs and ensuring the non-necessary pkgs will be removed
RUN apt upgrade -y
RUN apt autoremove -y

# Copying the modified custom_startup.sh (from kasm/terminal:1.15.0)
COPY custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

# Installing Hack Nerd Font
RUN wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
RUN unzip Hack.zip -d /usr/local/share/fonts

# Copying modified .bashrc file to the default profile home dir
COPY .bashrc /home/kasm-default-profile/

# Copying terminal profile
COPY user /home/kasm-default-profile/.config/dconf/
COPY xfce4/ /home/kasm-default-profile/.config/
# COPY xfce4/terminal/terminalrc /home/kasm-default-profile/.config/xfce4/terminal/


# Adding Starship Theme
# COPY starship.toml /home/kasm-default-profile/.config/

# Getting rid off the xfce4-panel
# RUN chmod a-rwx /usr/bin/xfce4-panel

# Wallpaper
# COPY wallpaper-kasm.jpg /usr/share/backgrounds/bg_default.png


# ----------------------------------------------------

# More Kasm 
RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME
ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME
USER 1000

