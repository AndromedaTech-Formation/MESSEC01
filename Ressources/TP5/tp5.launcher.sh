#!/bin/bash

# =============================================
# Bannière d'en-tête
# =============================================
echo -e "\n"
echo -e "  \033[1;34m╔══════════════════════════════════════════════════════════════════════════╗\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m TTTTTTTTTTTTTTTTTTTTTTTPPPPPPPPPPPPPPPPP        555555555555555555 \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m T:::::::::::::::::::::TP::::::::::::::::P       5::::::::::::::::5 \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m T:::::::::::::::::::::TP::::::PPPPPP:::::P      5::::::::::::::::5 \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m T:::::TT:::::::TT:::::TPP:::::P     P:::::P     5:::::555555555555 \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m TTTTTT  T:::::T  TTTTTT  P::::P     P:::::P     5:::::5            \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m         T:::::T          P::::P     P:::::P     5:::::5            \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m         T:::::T          P::::PPPPPP:::::P      5:::::5555555555   \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m         T:::::T          P:::::::::::::PP       5:::::::::::::::5  \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m         T:::::T          P::::PPPPPPPPP         555555555555:::::5 \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m         T:::::T          P::::P                             5:::::5\033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m         T:::::T          P::::P                             5:::::5\033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m         T:::::T          P::::P                 5555555     5:::::5\033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m       TT:::::::TT      PP::::::PP               5::::::55555::::::5\033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m       T:::::::::T      P::::::::P                55:::::::::::::55 \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m       T:::::::::T      P::::::::P                  55:::::::::55   \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m       TTTTTTTTTTT      PPPPPPPPPP                    555555555     \033[0m     \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m \033[1;36m                                                                         \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m    \033[1;33m   AndromedaTech Formation\033[0m                                            \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m    \033[1;32m🔐 MESSEC01 : Messagerie sécurisée et contrôle d'accès\033[0m                \033[1;34m║\033[0m"
echo -e "  \033[1;34m║\033[0m    \033[1;35m📋 TP n°5 : Configuration d'une authentification 2FA\033[0m                  \033[1;34m║\033[0m"
echo -e "  \033[1;34m╚══════════════════════════════════════════════════════════════════════════╝\033[0m"
echo -e "\n"

# =============================================
# Vérification des droits root
# =============================================
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Ce script doit être exécuté en tant que root." >&2
    exit 1
fi

# =============================================
# Variables
# =============================================
RAW_URL="https://raw.githubusercontent.com/AndromedaTech-Formation/MESSEC01/main/Ressources/TP5/tp5.tar.gz"
INSTALL_DIR="/var/TP5"
TEMP_ARCHIVE="/tmp/tp5.tar.gz"
TIMEOUT_SECONDS=10  # Timeout pour la vérification de GitHub

# =============================================
# Fonction pour vérifier l'accessibilité de GitHub
# =============================================
check_github_access() {
    echo -n "🔍 Vérification de l'accès à GitHub..."
apt-get install curl
    # Utilisation de curl avec timeout pour éviter de bloquer le script
    if curl --silent --max-time "$TIMEOUT_SECONDS" --head "https://github.com" > /dev/null; then
        echo -e "\r✅ GitHub est accessible.          "
        return 0
    else
        echo -e "\r❌ GitHub est inaccessible. Vérifiez votre connexion internet ou le statut de GitHub (https://www.githubstatus.com)." >&2
        exit 1
    fi
}

# =============================================
# Fonction pour télécharger avec une barre de progression
# =============================================
download_with_progress() {
    echo "📥 Téléchargement de l'archive depuis GitHub..."

    # Vérifier si wget est installé, sinon l'installer
    if ! command -v wget &> /dev/null; then
        echo "📦 Installation de wget..."
        apt update && apt install -y wget || {
            echo "❌ Erreur: Impossible d'installer wget." >&2
            exit 1
        }
    fi

    # Téléchargement avec wget (affiche une barre de progression)
    if ! wget --progress=bar:force --timeout="$TIMEOUT_SECONDS" --tries=3 "$RAW_URL" -O "$TEMP_ARCHIVE"; then
        echo "❌ Erreur: Impossible de télécharger l'archive." >&2
        echo "   - Vérifiez que l'URL est correcte: $RAW_URL" >&2
        echo "   - Vérifiez que le fichier existe sur GitHub." >&2
        exit 1
    fi
}

# =============================================
# Fonction pour décompresser et exécuter up.sh
# =============================================
install_tp5() {
    echo "📂 Décompression de l'archive dans $INSTALL_DIR..."

    # Créer le répertoire s'il n'existe pas
    mkdir -p "$INSTALL_DIR" || {
        echo "❌ Erreur: Impossible de créer le répertoire $INSTALL_DIR" >&2
        exit 1
    }

    # Décompresser l'archive
    if ! tar -xzf "$TEMP_ARCHIVE" -C "$INSTALL_DIR"; then
        echo "❌ Erreur: Impossible de décompresser l'archive." >&2
        exit 1
    fi

    # Rendre up.sh exécutable et l'exécuter
    if [ -f "$INSTALL_DIR/up.sh" ]; then
        echo "🚀 Exécution de up.sh..."
        chmod +x "$INSTALL_DIR/up.sh" || {
            echo "❌ Erreur: Impossible de rendre up.sh exécutable." >&2
            exit 1
        }
        "$INSTALL_DIR/up.sh" || {
            echo "❌ Erreur: Échec de l'exécution de up.sh." >&2
            exit 1
        }
    else
        echo "❌ Erreur: Le fichier up.sh est introuvable dans l'archive." >&2
        exit 1
    fi
}

# =============================================
# Exécution du script
# =============================================
check_github_access
download_with_progress
install_tp5

# Nettoyage
rm -f "$TEMP_ARCHIVE"

echo "✅ Installation terminée avec succès !"
exit 0
