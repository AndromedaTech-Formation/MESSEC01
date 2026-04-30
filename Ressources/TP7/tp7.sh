#!/bin/bash

# =================================================================
# Script de configuration automatique d'un serveur d'authentification OAuth vulnérable
# Cours MESSEC01 : Concept de messagerie sécurisée et gestion des droits d'accès
#
# TP n°7 : OAuth : Mise en œuvre et vulnérabilités
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
echo -e "${NC}${CYAN} Script de configuration automatique ${JAUNE}serveur OAuth vulnérable"
echo -e "${NC} Cours MESSEC01 : Concept de messagerie securisee"
echo -e "${NC} https://github.com/AndromedaTech-Formation/MESSEC01"
echo ""
echo " TP n°7 : OAuth : Mise en œuvre et vulnérabilités"
echo " Ce script est à utiliser sur une machine en Debian 13"
echo -e "${ROUGE}${FLASH}AVERTISSEMENT"
echo -e "${NC}${ROUGE}    Usage strictement pédagogique"
echo -e "    Ce script ne doit pas être utilisé en PRODUCTION connecté à Internet"
echo ""
echo -e "${NC}"
read -p " Lancer le script ? :"
echo ""
echo ""
echo -e "${NC}"








echo -e "${CYAN} >>>>>> PREPARATION DU SYSTEME... ${NC}"
apt-get install curl golang-go -y
echo -e "${CYAN} >>>>>> INSTALLATION DE DOCKER... ${NC}"
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
echo -e "${CYAN} >>>>>> TELECHARGEMENT DU LAB DEPUIS GITHUB... ${NC}"
git clone https://github.com/AndromedaTech-Formation/oauth-labs
cd oauth-labs
mv Makefile Makefile.old
mv docker-compose.yaml docker-compose.yaml.old
curl -fsSL https://raw.githubusercontent.com/AndromedaTech-Formation/MESSEC01/main/Ressources/TP7/Makefile -o Makefile
curl -fsSL https://raw.githubusercontent.com/AndromedaTech-Formation/MESSEC01/main/Ressources/TP7/docker-compose.yaml -o docker-compose.yaml
echo -e "${CYAN} >>>>>> PREPARATION DU LAB... cela peut prendre quelques minutes... ${NC}"
echo '172.16.16.1 oauth.labs' >> /etc/hosts
echo '172.16.16.1 server-02.oauth.labs server-02' >> /etc/hosts
echo '172.16.16.1 client-02.oauth.labs client-02' >> /etc/hosts
make config
make docker
echo -e "${CYAN} >>>>>> DEMARRAGE DU LAB... ${NC}"
make lab02



echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "*********************************************************"
echo -e "************   ${VERT}INSTALLATION TERMINEE   ${NC}******************"
echo "*********************************************************"
echo ""
echo ""
echo "Vous pouvez maintenant accéder à votre ${VERT}serveur OAuth :"
echo -e "${ROUGE} ==> Rendez-vous sur https://client-02.oauth.labs ${NC}"
echo "et suivez les instructions données dans l'énoncé de l'exercice"
echo ""
exit



