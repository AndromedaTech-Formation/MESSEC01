#!/bin/bash

# =================================================================
# Script de configuration automatique Serveur MATRIX avec back-end SYNAPSE et client Web ELEMENT
# Cours MESSEC01 : Concept de messagerie sécurisée et gestion des droits d'accès
#
# TP n°6 : Installation d'un serveur Matrix
#
# ==========================================================

# ========= COULEURS ===========
VERT="\e[32m"
CYAN="\e[36m"
JAUNE="\e[33m"
ROUGE="\e[31m"
FLASH="\e[1;5;33m"
NC="\e[0m"

# Vérification que le script est exécuté en root
clear
if [[ $EUID -ne 0 ]]; then
    echo "Veuillez exécuter ce script en tant que root."
    exit 1
fi

# ================================
# Demande des informations de base
# ================================
clear
echo -e "${NC}${CYAN} Script de configuration automatique ${JAUNE}serveur MATRIX avec back-end SYNAPSE et client Web ELEMENT"
echo -e "${NC}${FLASH} Cours MESSEC01 : Concept de messagerie securisee"
echo -e "${NC} https://github.com/AndromedaTech-Formation/MESSEC01"
echo ""
echo " TP n°6 : Installation d'un serveur Matrix"
echo " Ce script est à utiliser sur une machine en Debian 13"
echo -e "${ROUGE} AVERTISSEMENT"
echo -e "    Usage strictement pédagogique"
echo -e "    Ce script ne doit pas être utilisé en PRODUCTION connecté à Internet"
echo ""
echo -e "${VERT} Indiquez votre nom de domaine (FQDN) :${NC}"
echo -e "exemple : abri207.vault-tec.tech"
read -p " $(domainname) :" NEW_DOMAIN
echo -e "${NC} > Le FQDN suivant sera utilisé : ${VERT} $NEW_DOMAIN"
read -p " Lancer le script ? :"
echo ""
echo ""
echo -e "${NC}"



# Préparation de Docker
echo -e "${CYAN} >>>>>> PREPARATION DU SYSTEME... ${NC}"
apt update
apt install ca-certificates curl -y

echo -e "${CYAN} >>>>>> AJOUT DU ${JAUNE}source.list ${CYAN}DE DOCKER... ${NC}"
# ajout du source.list Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
rm /etc/apt/sources.list.d/docker.sources
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo -e "${CYAN} >>>>>> INSTALLATION DE DOCKER... ${NC}"
# Pré-requis : installation de Docker et Docker-compose
apt update
apt install docker-ce docker-compose-plugin -y
systemctl enable docker
systemctl start docker

echo -e "${CYAN} >>>>>> AFFICHAGE DES VERSIONS DE DOCKER ET DOCKER-COMPOSE ${NC}"
# affichage des versions installées
docker --version
docker compose version

echo -e "${CYAN} >>>>>> PRECONFIGURATION DU SERVEUR ${JAUNE}MATRIX... ${NC}"
# création du dossier Matrix-server dédié à l'instance
mkdir -p ~/matrix-server
cd ~/matrix-server

echo -e "${CYAN} >>>>>> ECRITURE DU FICHIER ${JAUNE}docker-compose.yml... ${NC}"

# Ecriture du fichier docker-compose.yml 
cat > docker-compose.yml <<EOF
version: "3"

services:

  synapse:
    image: matrixdotorg/synapse:latest
    container_name: matrix-synapse
    restart: unless-stopped
    volumes:
      - ./synapse:/data
    ports:
      - "8008:8008"
    environment:
      - SYNAPSE_SERVER_NAME=$NEW_DOMAIN
      - SYNAPSE_REPORT_STATS=no

  element:
    image: vectorim/element-web:latest
    container_name: element-web
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./config.json:/app/config.json
EOF

echo -e "${CYAN} >>>>>> ECRITURE DU FICHIER ${JAUNE}config.json ${CYAN}DE MATRIX... ${NC}"
# Ecriture du fichier config.json
cat > config.json <<EOF
{
  "default_server_config": {
    "m.homeserver": {
      "base_url": "http://$NEW_DOMAIN:8008",
      "server_name": "$NEW_DOMAIN"
    }
  }
}
EOF


echo -e "${CYAN} >>>>>> GENERATION DE LA CONFIGURATION DE ${JAUNE}SYNAPSE... ${NC}"
# génération de la configuration Synapse (avec configuration du nom de domaine)
docker run -it --rm -v $(pwd)/synapse:/data -e SYNAPSE_SERVER_NAME=$NEW_DOMAIN -e SYNAPSE_REPORT_STATS=no matrixdotorg/synapse:latest generate

echo -e "${CYAN} >>>>>> DEMARRAGE DES CONTENEURS... ${NC}"
# Démarrage des conteneurs
docker compose up -d && docker ps -a


echo "*********************************************************"
echo -e "************   ${VERT}INSTALLATION TERMINEE   ${NC}******************"
echo "*********************************************************"
echo ""
echo ""
echo "Vous pouvez maintenant configurer votre ${VERT} client Element :"
echo -e "${ROUGE} ==> Serveur Matrix ${CYAN} http://$NEW_DOMAIN:8008 ${NC}"
echo -e "${ROUGE} ==> Element (Web) ${CYAN} http://$NEW_DOMAIN:8080 ${NC}"
echo "et suivez les instructions données dans l'énoncé de l'exercice"
echo ""
echo "Pour créer un utilisateur, utilisez la commande suivante"
echo "docker exec -it matrix-synapse register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008"
exit



