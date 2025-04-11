#!/bin/bash

# Renk kodları
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'


# 8. bringmecoins
echo " "
echo " "
echo " "
echo -e "${BLUE} ######   ######    ####    ##   ##    ####   ##   ##  #######    ####    #####    ####    ##   ##   #####${NC}"
echo -e "${BLUE}  ##  ##   ##  ##    ##     ###  ##   ##  ##  ### ###   ##   #   ##  ##  ##   ##    ##     ###  ##  ##   ##${NC}"
echo -e "${BLUE}  ##  ##   ##  ##    ##     #### ##  ##       #######   ## #    ##       ##   ##    ##     #### ##  #${NC}"
echo -e "${BLUE}  #####    #####     ##     ## ####  ##       #######   ####    ##       ##   ##    ##     ## ####   #####${NC}"
echo -e "${BLUE}  ##  ##   ## ##     ##     ##  ###  ##  ###  ## # ##   ## #    ##       ##   ##    ##     ##  ###       ##${NC}"
echo -e "${BLUE}  ##  ##   ##  ##    ##     ##   ##   ##  ##  ##   ##   ##   #   ##  ##  ##   ##    ##     ##   ##  ##   ##${NC}"
echo -e "${BLUE} ######   #### ##   ####    ##   ##    #####  ##   ##  #######    ####    #####    ####    ##   ##   #####${NC}"
echo " "
echo " "
echo " "
echo " "

echo " "
echo -e "${BLUE}########## GENSYN UPDATE START ##########${NC}"
echo " "

# Script temizliği
if [ -f "$HOME/script.sh" ]; then
  echo -e "${YELLOW}The previous script.sh file is being deleted...${NC}"
  rm -f "$HOME/script.sh"
fi

# Adımlar
BACKUP_DIR="$HOME/rl-swarm-backup"
RL_DIR="$HOME/rl-swarm"

# 1. Çalışan screen varsa durdur
if screen -list | grep -q "gensyn"; then
  echo -e "${YELLOW}Active 'gensyn' screen session found. It's being shut down...${NC}"
  screen -S gensyn -X stuff "^C"
  sleep 2
  screen -S gensyn -X quit
  echo -e "${GREEN}Screen closed.${NC}"
else
  echo -e "${RED}No active 'gensyn' screen session found.${NC}"
fi

# 2. Dosyaları yedekle
if [ -d "$RL_DIR" ]; then
  echo -e "${YELLOW}rl-swarm folder found. Backing up...${NC}"
  mkdir -p "$BACKUP_DIR/modal-login"

  if [ -f "$RL_DIR/swarm.pem" ]; then
    cp "$RL_DIR/swarm.pem" "$BACKUP_DIR/swarm.pem"
    echo -e "${GREEN}swarm.pem is backed up.${NC}"
  else
    echo -e "${RED}swarm.pem not found, failed to backup.${NC}"
  fi

  if [ -d "$RL_DIR/modal-login/temp-data" ]; then
    cp -r "$RL_DIR/modal-login/temp-data" "$BACKUP_DIR/modal-login/temp-data"
    echo -e "${GREEN}temp-data is backed up.${NC}"
  else
    echo -e "${RED}temp-data not found, failed to backup.${NC}"
  fi

  echo -e "${YELLOW}delete rl-swarm..${NC}"
  rm -rf "$RL_DIR"
else
  echo -e "${RED}rl-swarm folder not found, operation aborted.${NC}"
  exit 1
fi

# 3. Güncel repo klonlanıyor
echo -e "${GREEN}Cloning the current rl-swarm repo...${NC}"
git clone https://github.com/zunxbt/rl-swarm.git "$RL_DIR"

# 4. Yedekler geri yükleniyor
if [ -f "$BACKUP_DIR/swarm.pem" ]; then
  cp "$BACKUP_DIR/swarm.pem" "$RL_DIR/swarm.pem"
  echo -e "${GREEN}swarm.pem geri yüklendi.${NC}"
else
  echo -e "${RED}swarm.pem backup not found.${NC}"
fi

# temp-data klasörü geri yükleniyor
if [ -d "$BACKUP_DIR/modal-login/temp-data" ]; then
  if [ -d "$RL_DIR/modal-login/temp-data" ]; then
    echo -e "${YELLOW}The new temp-data folder is deleted...${NC}"
    rm -rf "$RL_DIR/modal-login/temp-data"
  fi
  mkdir -p "$RL_DIR/modal-login"
  cp -r "$BACKUP_DIR/modal-login/temp-data" "$RL_DIR/modal-login/temp-data"
  echo -e "${GREEN}temp-data folder has been restored.${NC}"
else
  echo -e "${RED}No backup of temp-data folder found.${NC}"
fi

# 5. Yarn işlemleri
echo -e "${GREEN}Yarn update..${NC}"
cd "$RL_DIR/modal-login"
yarn install
yarn upgrade
yarn add next@latest
yarn add viem@latest

# 6. testnet_grpo_runner.py dosyası düzenleniyor
echo -e "${GREEN}Updating testnet_grpo_runner.py file...${NC}"
sed -i 's/dht = hivemind.DHT(start=True, \*\*self\._dht_kwargs(grpo_args))/dht = hivemind.DHT(start=True, ensure_bootstrap_success=False, \*\*self._dht_kwargs(grpo_args))/g' "$RL_DIR/hivemind_exp/runner/gensyn/testnet_grpo_runner.py"

# 7. Node'u yeniden başlat
echo -e "${GREEN}The new screen and the node is initialized...${NC}"
cd "$RL_DIR"
screen -dmS gensyn bash -c "python3 -m venv .venv && source .venv/bin/activate && ./run_rl_swarm.sh"

# 8. bringmecoins
echo " "
echo " "
echo -e "${BLUE} ######   ######    ####    ##   ##    ####   ##   ##  #######    ####    #####    ####    ##   ##   #####${NC}"
echo -e "${BLUE}  ##  ##   ##  ##    ##     ###  ##   ##  ##  ### ###   ##   #   ##  ##  ##   ##    ##     ###  ##  ##   ##${NC}"
echo -e "${BLUE}  ##  ##   ##  ##    ##     #### ##  ##       #######   ## #    ##       ##   ##    ##     #### ##  #${NC}"
echo -e "${BLUE}  #####    #####     ##     ## ####  ##       #######   ####    ##       ##   ##    ##     ## ####   #####${NC}"
echo -e "${BLUE}  ##  ##   ## ##     ##     ##  ###  ##  ###  ## # ##   ## #    ##       ##   ##    ##     ##  ###       ##${NC}"
echo -e "${BLUE}  ##  ##   ##  ##    ##     ##   ##   ##  ##  ##   ##   ##   #   ##  ##  ##   ##    ##     ##   ##  ##   ##${NC}"
echo -e "${BLUE} ######   #### ##   ####    ##   ##    #####  ##   ##  #######    ####    #####    ####    ##   ##   #####${NC}"
echo " "
echo " "


# 9. Bitiş
echo " "
echo -e "${GREEN}✅ All operations completed, node restarted.${NC}"
echo " "
echo -e "${YELLOW}💡 Connect to Screen : ${NC}screen -r gensyn"
echo " "
echo -e "${GREEN}#### Twitter : @BringMeCoins #####${NC}"
