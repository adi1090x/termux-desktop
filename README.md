![logo](https://raw.githubusercontent.com/adi1090x/termux-desktop/master/previews/logo.png) <br />

Alright, Lets's get this straight, these are just some **dotfiles**, which will help you to setup a graphical environment in **termux**. It's kind of a *backup* for me as well. <br />

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
|polybar|Easy and fast status bar|```pkg install polybar```|
|st|Suckless/Simple terminal|```pkg install st```|
|geany|Graphical text editor|```pkg install geany```|
|thunar|File manager (optional)|```pkg install thunar```|
|pcmanfm|File manager|```pkg install pcmanfm```|
|rofi|An application launcher|```pkg install rofi```|
|feh|Simple image viewer|```pkg install feh```|
|neofetch|System info program|```pkg install neofetch```|
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
pkg update && pkg upgrade && pkg install x11-repo && pkg install tigervnc openbox obconf xorg-xsetroot polybar st geany pcmanfm rofi feh neofetch htop vim elinks mutt 
```

