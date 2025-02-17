wget -P $HOME/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip
cd $HOME/.local/share/fonts
unzip Hack.zip
rm Hack.zip
fc-cache -fv
echo "'Hack Nerd Font' should now be listed below:"
fc-list : family style | grep -i hack
