sudo pacman -Syu
sudo pacmad -S zsh xmonad xmonad-contrib yaourt sbt tig cabal-install trayer
yaourt -S taffybar-git volume-applet
cabal update
cabal install stylish-haskell hlint
