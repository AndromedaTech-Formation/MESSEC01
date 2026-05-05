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
echo -e "${NC} Cours MESSEC01 : Messagerie securisée et contrôle d'accès"
echo -e "${NC} https://github.com/AndromedaTech-Formation/MESSEC01"
echo ""
echo -e " ${JAUNE}TP n°7 : OAuth : Mise en œuvre et vulnérabilités ${NC}"
echo " Ce script est adapté pour Debian 13"
echo -e "${ROUGE}${FLASH}AVERTISSEMENT"
echo -e "${NC}${ROUGE}    Usage strictement pédagogique"
echo -e "    Ce script ne doit pas être utilisé en PRODUCTION connecté à Internet"
echo ""
echo ""
echo ""
echo ""
echo ""
echo -e "${NC}"
read -p " Lancer le script ? :"
echo ""
echo ""
echo -e "${NC}"








echo -e "${CYAN} >>>>>> PREPARATION DU SYSTEME... ${NC}"
apt-get install curl golang-go -y
#echo -e "${CYAN} >>>>>> INSTALLATION DE DOCKER... ${NC}"
#curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
echo -e "${CYAN} >>>>>> VERIFICATION DE DOCKER... ${NC}"

# ================================
# Fonction de vérification Docker
# ================================
check_docker_installed() {
    # Vérifie si le binaire docker existe
    if command -v docker &> /dev/null; then
        # Vérifie si le service docker est actif
        if systemctl is-active --quiet docker; then
            echo -e "${VERT}Docker est déjà installé et actif${NC}"
            return 0
        else
            echo -e "${JAUNE}Docker est installé mais le service n'est pas actif${NC}"
            echo -e "${CYAN}Démarrage du service Docker...${NC}"
            systemctl start docker
            systemctl enable docker
            return 0
        fi
    else
        return 1
    fi
}

# ================================
# Installation de Docker si nécessaire
# ================================

if check_docker_installed; then
    echo -e "${VERT}Docker est prêt à être utilisé${NC}"
else
    echo -e "${CYAN} >>>>>> INSTALLATION DE DOCKER... ${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

    # Vérification post-installation
    if ! check_docker_installed; then
        echo -e "${ROUGE}Échec de l'installation de Docker${NC}"
        exit 1
    fi
fi




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



echo -e "${CYAN} >>>>>> RECUPERATION DES VALEURS GENEREES PAR DOCKER COMPOSE ${NC}"
#RECUPERATION DES VALEURS GENEREES PAR DOCKER
CONFIG_FILE="docker/lab02/client.config.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erreur: Le fichier $CONFIG_FILE n'existe pas."
    exit 1
fi

# Extraire le bloc client
client_block=$(sed -n '/^client:/,/^[^ ]/p' "$CONFIG_FILE" | sed '1d;$d')

# Extraire les valeurs
CLIENT_ID=$(echo "$client_block" | grep -E '^[[:space:]]*id:' | awk '{print $2}' | tr -d "'")
CLIENT_SECRET=$(echo "$client_block" | grep -E '^[[:space:]]*secret:' | awk '{print $2}' | tr -d "'")

echo -e "${CYAN} >>>>>> VALEURS DU client.config.yaml ${NC}"
echo "Client ID: $CLIENT_ID" > /var/tp7-idsecret
echo "Client Secret: $CLIENT_SECRET" >> /var/tp7-idsecret


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
echo -e "${ROUGE} Sauvegardez les valeurs ci-dessous ${NC}, vous en aurez besoin pour la suite du TP"
echo -e "Client ID: ${VERT} $CLIENT_ID ${NC}"
echo -e "Client Secret: ${VERT} $CLIENT_SECRET ${NC}"
echo ""
echo -e "Vous pouvez maintenant accéder à votre ${VERT} serveur OAuth :"
echo -e "====> Rendez-vous sur ${JAUNE} https://client-02.oauth.labs ${NC}"
echo "et suivez les instructions données dans l'énoncé de l'exercice"
echo ""
exit



