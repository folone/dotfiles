dotfiles
========

Personal home directory config
![screenshot](http://i.imgur.com/bxt7S4l.png)

# Notes

* Emacs will complain about the packages that are not
  installed. Install them from the `package-list-packages`
* Installing taffybar might be a tought deal. Some package still
  depends on unix-2.3.0, which is outdated. Installing from AUR does
  not work as of now, cause the package is not supported any more. If
  you find yourself struggling with installing it, you may consider
  using xmobar-specific config. Just make a symlink named xmonad.hs to
  the desired config.
