sudo pacman -Syu
sudo pacmad -S zsh xmonad xmonad-contrib yaourt sbt tig cabal-install
yaourt -S taffybar-git
cabal update
cabal install stylish-haskell hlint
