![logo](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/logo.png) <br />

<p align="center">
  <img src="https://img.shields.io/github/issues/adi1090x/termux-desktop?color=violet&style=for-the-badge">
  <img src="https://img.shields.io/github/forks/adi1090x/termux-desktop?color=teal&style=for-the-badge">
  <img src="https://img.shields.io/github/stars/adi1090x/termux-desktop?style=for-the-badge">
</p>

Alright, Lets just get this straight, these are just some **dotfiles**, which will help you to setup a graphical environment in **termux**. It's kind of a *backup* for me as well. <br />

This repo contains config files, some useful & important scripts. I'm trying to make it a *step by step guide* to setup a beautiful ***linux desktop in your android device*** with termux, So follow the steps and you'll end up making it look like this - <br />

![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_13.png) <br />

Lets's start with the beginning... <br />

## What is termux?

Termux is an *Android terminal emulator* and **Linux environment** app that works directly with **no rooting** or setup required. A minimal base system is installed automatically - additional packages are available using the *APT package manager*. More [Here](https://termux.com/)... <br />

## How To install termux?

You can install termux form google play store or from f-droid. <br />

Get it on [Google Play](https://play.google.com/store/apps/details?id=com.termux) <br />
Download from [F-Droid](https://f-droid.org/packages/com.termux/) <br />

More information about installation is [here](https://wiki.termux.com/wiki/Main_Page) <br />

At first start a small base system is downloaded, And brings you to a minimal *bash* shell. <br /> 

## Dependencies

|Package|Description|Installation|
|---|---|---|
|x11-repo|Termux repo for x11 packages|```pkg install x11-repo```|
|vnc server|For graphical output|```pkg install tigervnc```|
|openbox wm|Openbox Window Manager|```pkg install openbox obconf```|
|xsetroot|Set color background for X|```pkg install xorg-xsetroot```|
|xterm|X terminal|```pkg install xterm```|
|xcompmgr|Composite manager or desktop effects|```pkg install xcompmgr```|
|xfsettingsd|The settings daemon, to set themes & icons|```pkg install xfce4-settings```|
|polybar|Easy and fast status bar|```pkg install polybar libnl```|
|st|Suckless/Simple terminal|```pkg install st```|
|geany|Graphical text editor|```pkg install geany```|
|thunar|File manager (optional)|```pkg install thunar```|
|pcmanfm|File manager|```pkg install pcmanfm```|
|rofi|An application launcher|```pkg install rofi```|
|feh|Simple image viewer|```pkg install feh```|
|neofetch|System info program|```pkg install neofetch```|
|git|VCS, for cloning repos|```pkg install git```|
|wget|Command line downloader|```pkg install wget```|
|curl|To transfer/get internet data|```pkg install curl```|
|zsh|A very good shell|```pkg install zsh```|
|vim|Command line text editor (! - hard to exit :D)|```pkg install vim```|
|htop|System monitor (optional)|```pkg install htop```|
|elinks|Command line web browser (optional)|```pkg install elinks```|
|mutt|Command line mail client (optional)|```pkg install mutt```|
|mc|Command line file manager (optional)|```pkg install mc```|
|ranger|Command line file manager (optional)|```pkg install ranger```|
|cmus|Command line music player (optional)|```pkg install cmus```|
|cava|Console-based audio visualizer (optional)|```pkg install cava```|
|pulseaudio|Sound system & audio server (optional)|```pkg install pulseaudio```|

You can install all important programs simply pasting this in the termux - <br />
```
pkg update && pkg upgrade && pkg install x11-repo && pkg install tigervnc openbox obconf xorg-xsetroot xcompmgr xterm polybar st libnl zsh geany pcmanfm rofi feh neofetch htop vim elinks mutt git wget curl xfce4-settings
```
## Configuration

Now all the necessary programs are installed, it's time to configure the system. <br />
So, first clone this repo by,
```
cd $HOME && git clone https://github.com/adi1090x/termux-desktop
```
Now go to the cloned directory *termux-desktop* and copy or move **home** & **usr** (Basically `usr/lib/archlabs/common`) directory to ***/data/data/com.termux/files***. you can do it by,
```
cp -rf ./home /data/data/com.termux/files && cp -rf ./usr /data/data/com.termux/files
```
or
```
mv -f ./home /data/data/com.termux/files && mv -f ./usr /data/data/com.termux/files

```
**Warning** : I'm assuming you're doing this on a fresh termux install. If not so, please backup your files before running these command above. These commands will forcefully copy or move files in *home* & *usr* directory. So, before doing that, take a look inside the repo directories, and backup your existing config files (like .vimrc, .zshrc, .gitconfig, etc). <br />

***VNC Server***
Now, Let's configure the **vnc server** for graphical output. Run -
```
vncserver -localhost
```
At first time, you will be prompted for setting up passwords -
```
You will require a password to access your desktops.

Password:
Verify:
Would you like to enter a view-only password (y/n)? n
```
Note that passwords are not visible when you are typing them and maximal password length is 8 characters. <br />
If everything is okay, you will see this message -
```
New 'localhost:1 ()' desktop is localhost:1

Creating default startup script /data/data/com.termux/files/home/.vnc/xstartup
Creating default config /data/data/com.termux/files/home/.vnc/config
Starting applications specified in /data/data/com.termux/files/home/.vnc/xstartup
Log file is /data/data/com.termux/files/home/.vnc/localhost:1.log
```
It means that X (vnc) server is available on display 'localhost:1'. <br />
Finally, to make programs do graphical output to the display 'localhost:1', set environment variable like shown here (yes, without specifying 'localhost'):
```
export DISPLAY=":1"
```
You may even put this variable to your bashrc or profile so you don't have to always set it manually unless display address will be changed. <br />

Now You can start the vnc server by,
```
vncserver
```
And to stop the server, run -
```
vncserver -kill :1
```

***VNC Client***
Now you need a vnc client app to connect to server. I'm using this Android VNC client: [VNC Viewer](https://play.google.com/store/apps/details?id=com.realvnc.viewer.android) (developed by RealVNC Limited). You can use [TigerVNC](https://tigervnc.org/) if you're trying to connect to server by a computer (Windows or Linux).

Determine port number on which VNC server listens. It can be calculated like this: 5900 + {display number}. So for display 'localhost:1' the port will be 5901. <br />

Now open the VNC Viewer application and create a new connection with the following information (assuming that VNC port is 5901) - <br />
```
Address:
127.0.0.1:5901

Name:
Termux
```
Now launch it. You will be prompted for password that you entered on first launch of 'vncserver'. And because you've copy pasted everthing, you'll be headed to this desktop - <br />

![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_1.png) <br />

Well, That's it. You've successfully installed a beautiful graphical desktop on termux. Hurray!!! <br />

## Screenshots
Well, Here are some ideas or things you can do with termux and how you can make doing these stuff easy with a graphical desktop. And ***FYI***, I'm not doing anything **illegal** or sponsoring any kind of **Hacking and Cracking**. *Termux is a powerful tool, use it with responsibilities.* <br />

**Rofi** : Rofi app launcher.
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_3.png) <br />
**Polybar Style** : Rofi based script to change the colors of polybar.
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_4.png) <br />
**Stuff** : Running cmatrix, htop, pipes, etc. 
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_5.png) <br />
**Internet** : Elinks as browser and mutt as mail client.
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_6.png) <br />
**File Managers** : Pcmanfm and thunar, graphical file managers.
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_7.png) <br />
**CLI File Managers** : Ranger & MC, console based file managers.
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_8.png) <br />
**Text Editors** : Runnig vim, nano (CLI based) & geany (graphical) text editors.
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_9.png) <br />
**Showing Off** : Ah, just some tools - 
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_10.png) <br />
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_11.png) <br />
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_12.png) <br />
**Resolution** : on 1920x1080 display resolution
![desktop](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/preview_14.png) <br />

### Additional Tools
You can install additional tools for termux, to make it visually look good.
1. [Oh my zsh](https://github.com/adi1090x/termux-omz), Setup zsh with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) framework.
2. [Termux style](https://github.com/adi1090x/termux-style), Change color and fonts in termux.

### Not Supported Yet
- [ ] Bitmap Fonts
- [ ] SVG Icon Packs
- [ ] .Xresources/.Xdefaults For xterm/aterm
- [ ] No Web Browser (Expected Midori)
- [ ] No Hardware Acceleration
- [ ] Some Other Things

### FYI
* First thing first, the guide above may have some errors, everybody make mistakes.
* If you face any problem or get any error, you can create an issue & i'll help.
* There are some scripts made by me and some are made by other people, I've just put those here collectively.
* You may need to edit some scripts accoring to your need (like, battery, network email for polybar & .muttrc, .gitconfig)
* I'll make more desktop configs and try to configure different window managers (fluxbox, dwm) by time.
* Share this repository with your friends.
