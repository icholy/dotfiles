# My Dotfiles ... :S

* Source Code Pro (w/Powerline Patch): https://github.com/Lokaltog/powerline-fonts
* Tomorrow Theme For Gnome Terminal: https://github.com/chriskempson/tomorrow-theme
* Oh My Zsh: https://github.com/robbyrussell/oh-my-zsh
* Imgur: http://imgur.com/tools/imgurbash.sh
* GDrive: https://github.com/prasmussen/gdrive
* GHQ: https://github.com/motemen/ghq
* git-hub: https://github.com/ingydotnet/git-hub

``` sh
$ sudo apt-get install vim git xmonad zsh silversearcher-ag
$ chsh -s /bin/zsh
```

# Setting default browser

`gnome-terminal` and `thunderbird` will use `gnome-open` when opening links.
It does not respect the default browser so you need to change the xdg mime.

``` sh
xdg-mime default chromium-browser.desktop x-scheme-handler/http
xdg-mime default chromium-browser.desktop x-scheme-handler/https
```

related issue: https://bugs.launchpad.net/ubuntu/+source/chromium-browser/+bug/670128
