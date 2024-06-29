# NOTE: This script is untested and merely a collection of commands I had to run to set up my system

# -- home manager --

# add home-manager channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# back up home manager config if it exists
mv $HOME/.config/home-manager $HOME/.config/home-manager.backup
# link home-manager to this location
ln -sf $(pwd)/home-manager $HOME/.config/home-manager

# build first generation
home-manager switch

# -- system config --

# back up system config
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup
# link system config file
sudo ln -sf $(pwd)/nixos/configuration.nix /etc/nixos/configuration.nix

# add unstable channel
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos

# upgrade system
sudo nixos-rebuild switch --upgrade

# install & run open-webui llm gui via docker
docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main &
