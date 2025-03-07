#!/bin/bash

# script install_securite.sh

##############################################################################
## firewall - Activation du Firewall                                              
##############################################################################
install_firewall() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DU FIREWALL ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
    
    # Définition des variables
    NFTABLES_CONF="/etc/nftables.conf"
    # NFTABLES_LOG_DIR="/var/log/nftables"
    # NFTABLES_LOG="$NFTABLES_LOG_DIR/nftables.log"

    # Fonction pour gérer les erreurs
    handle_error() {
        echo "❌ Erreur : $1" >&2
        exit 1
    }

    # Fonction pour exécuter une commande avec sudo et vérifier son succès
    check_command() {
        sudo "$@"
        if [ $? -ne 0 ]; then
            handle_error "Échec de la commande : sudo $*"
        fi
    }

    # Fonction pour vérifier la présence d'un paquet
    check_package() {
        local package_name=$1
        local install_command=$2

        if ! command -v "$package_name" >/dev/null 2>&1; then
            handle_error "Le paquet $package_name n'est pas installé. Installez-le avec : $install_command"
        fi
    }

    check_command sh -c '> /etc/nftables.conf'

    # Création d'un fichier temporaire pour les règles
    #docker0, 
    
    temp_rules=$(mktemp)
    trap 'rm -f "$temp_rules"' EXIT

    # Configuration des règles nftables
    {
        echo "#!/usr/sbin/nft -f"
        echo "flush ruleset"

        echo "define PRIVATE_NETS = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 }"
        echo "define BOGON_NETS = { 0.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16, 224.0.0.0/4, 240.0.0.0/4 }"
        echo "define PRIVATE_NETS6 = { fe80::/10, fc00::/7 }"
        echo "define BOGON_NETS6 = { ::/128, ::1/128, ff00::/8, 2001:db8::/32, 2001:10::/28, 2001:20::/28 }"
        # echo "define WHITELIST_IFACE = { lo }"
        echo "define SENSITIVE_PORTS = { 22, 3306, 5432, 8080, 8443, 10000, 9090, 9100, 9200, 6379, 27017, 28017, 4444, 4445 }"
        echo "define DNS_PORTS = { 53 }"
        echo "define HTTP_PORTS = { 80, 443 }"
        echo "define ICMP_TYPES = { echo-request, echo-reply, destination-unreachable, time-exceeded, parameter-problem }"
        echo "define ICMPv6_TYPES = { nd-neighbor-solicit, nd-neighbor-advert, nd-router-advert, echo-request }"

        # Créer la table et les sets
        echo "add table inet firewall"

        # Ajouter un ensemble dynamique pour les interfaces de confiance 
        echo "add set inet firewall WHITELIST_IFACE { type ifname; flags dynamic; }"

        # Ensembles IPv4
        echo "add set inet firewall blacklist { type ipv4_addr; flags dynamic, timeout; timeout 1h; }"
        echo "add set inet firewall whitelist { type ipv4_addr; flags dynamic; }"
        echo "add set inet firewall port_scanners { type ipv4_addr; flags dynamic, timeout; timeout 24h; }"
        echo "add set inet firewall bad_actors { type ipv4_addr; flags dynamic, timeout; timeout 48h; }"
        echo "add set inet firewall ssh_bruteforce { type ipv4_addr; flags dynamic, timeout; timeout 24h; }"
        echo "add set inet firewall syn_flood { type ipv4_addr; flags dynamic, timeout; timeout 1h; }"
        echo "add set inet firewall http_flood { type ipv4_addr; flags dynamic, timeout; timeout 1h; }"

        # Ensembles IPv6
        echo "add set inet firewall blacklist6 { type ipv6_addr; flags dynamic, timeout; timeout 1h; }"
        echo "add set inet firewall whitelist6 { type ipv6_addr; flags dynamic; }"
        echo "add set inet firewall port_scanners6 { type ipv6_addr; flags dynamic, timeout; timeout 24h; }"
        echo "add set inet firewall bad_actors6 { type ipv6_addr; flags dynamic, timeout; timeout 48h; }"
        echo "add set inet firewall ssh_bruteforce6 { type ipv6_addr; flags dynamic, timeout; timeout 24h; }"
        echo "add set inet firewall syn_flood6 { type ipv6_addr; flags dynamic, timeout; timeout 1h; }"
        echo "add set inet firewall http_flood6 { type ipv6_addr; flags dynamic, timeout; timeout 1h; }"

        # Chaînes de base
        echo "add chain inet firewall input { type filter hook input priority 0; policy drop; }"
        echo "add chain inet firewall output { type filter hook output priority 0; policy accept; }"
        echo "add chain inet firewall forward { type filter hook forward priority 0; policy drop; }"

        # ---------------------------------------------------------------------------------
        # Règles de base
        # ---------------------------------------------------------------------------------

        # Whitelist : autoriser les IPs de confiance en premier (IPv4 et IPv6)
        echo "add rule inet firewall input ip saddr @whitelist accept"
        echo "add rule inet firewall input ip6 saddr @whitelist6 accept"

        # Règles de base pour les connexions établies et invalides
        echo "add rule inet firewall input ct state established,related accept"
        echo "add rule inet firewall input ct state invalid drop"
        echo "add rule inet firewall input iifname @WHITELIST_IFACE accept"
        echo "add element inet firewall WHITELIST_IFACE { lo }"

        # Bloquer les IP des ensembles dynamiques (IPv4)
        echo "add rule inet firewall input ip saddr @blacklist log prefix \"[NFT-DROP] IPV4-BLACKLIST-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip saddr @port_scanners log prefix \"[NFT-DROP] IPV4-PORT-SCANNER-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip saddr @ssh_bruteforce log prefix \"[NFT-DROP] IPV4-SSH-BRUTEFORCE-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip saddr @syn_flood log prefix \"[NFT-DROP] IPV4-SYN-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip saddr @http_flood log prefix \"[NFT-DROP] IPV4-HTTP-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip saddr @bad_actors log prefix \"[NFT-DROP] IPV4-BAD-ACTOR-BLOCKED \" counter drop"

        # Bloquer les IP des ensembles dynamiques (IPv6)
        echo "add rule inet firewall input ip6 saddr @blacklist6 log prefix \"[NFT-DROP] IPV6-BLACKLIST-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip6 saddr @port_scanners6 log prefix \"[NFT-DROP] IPV6-PORT-SCANNER-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip6 saddr @ssh_bruteforce6 log prefix \"[NFT-DROP] IPV6-SSH-BRUTEFORCE-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip6 saddr @syn_flood6 log prefix \"[NFT-DROP] IPV6-SYN-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip6 saddr @http_flood6 log prefix \"[NFT-DROP] IPV6-HTTP-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip6 saddr @bad_actors6 log prefix \"[NFT-DROP] IPV6-BAD-ACTOR-BLOCKED \" counter drop"

        # Anti-spoofing : bloquer les adresses IP privées et Bogon (IPv4)
        echo "add rule inet firewall input ip saddr \$PRIVATE_NETS iif != \"lo\" log prefix \"[NFT-DROP] PRIVATE-NET-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip saddr \$BOGON_NETS log prefix \"[NFT-DROP] BOGON-NET-BLOCKED \" counter drop"

        # Anti-spoofing : bloquer les adresses IPv6 privées et réservées
        echo "add rule inet firewall input ip6 saddr \$PRIVATE_NETS6 iif != \"lo\" log prefix \"[NFT-DROP] IPV6-PRIVATE-NET-BLOCKED \" counter drop"
        echo "add rule inet firewall input ip6 saddr \$BOGON_NETS6 log prefix \"[NFT-DROP] IPV6-BOGON-NET-BLOCKED \" counter drop"



        # ---------------------------------------------------------------------------------
        # Protection contre le scan de ports
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall port_scan"
        echo "add rule inet firewall input jump port_scan"
        echo "add rule inet firewall port_scan tcp flags syn limit rate 30/minute add @port_scanners { ip saddr } log prefix \"[NFT-DROP] PORT-SCAN \" counter drop"

        # ---------------------------------------------------------------------------------
        # Protection SSH (bruteforce)
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall ssh_protection"
        echo "add rule inet firewall input tcp dport 22 jump ssh_protection"
        echo "add rule inet firewall ssh_protection ct state new limit rate 3/minute burst 5 packets log prefix \"[NFT-DROP] SSH-RATE-LIMIT \" accept"
        echo "add rule inet firewall ssh_protection ct state new log prefix \"[NFT-DROP] SSH-RATE-LIMIT-EXCEEDED \" counter drop"
        echo "add rule inet firewall ssh_protection add @ssh_bruteforce { ip saddr } log prefix \"[NFT-DROP] SSH-BRUTEFORCE \" counter drop"

        # ---------------------------------------------------------------------------------
        # Protection TCP (SYN flood, XMAS scan, etc.)
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall tcp_protection"
        echo "add rule inet firewall input ip protocol tcp jump tcp_protection"

        # Bloquer les IP malveillantes dans la chaîne TCP (IPv4)
        echo "add rule inet firewall tcp_protection ip saddr @blacklist log prefix \"[NFT-DROP] TCP-BLACKLIST-BLOCKED \" counter drop"
        echo "add rule inet firewall tcp_protection ip saddr @port_scanners log prefix \"[NFT-DROP] TCP-PORT-SCANNER-BLOCKED \" counter drop"
        echo "add rule inet firewall tcp_protection ip saddr @ssh_bruteforce log prefix \"[NFT-DROP] TCP-SSH-BRUTEFORCE-BLOCKED \" counter drop"
        echo "add rule inet firewall tcp_protection ip saddr @syn_flood log prefix \"[NFT-DROP] TCP-SYN-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall tcp_protection ip saddr @http_flood log prefix \"[NFT-DROP] TCP-HTTP-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall tcp_protection ip saddr @bad_actors log prefix \"[NFT-DROP] TCP-BAD-ACTOR-BLOCKED \" counter drop"

        # Règles TCP spécifiques
        echo "add rule inet firewall tcp_protection tcp flags & (fin|syn) == fin|syn log prefix \"[NFT-DROP] TCP-FINSYNATTACK \" counter drop"
        echo "add rule inet firewall tcp_protection tcp flags & (syn|rst) == syn|rst log prefix \"[NFT-DROP] TCP-SYNRSTATTACK \" counter drop"
        echo "add rule inet firewall tcp_protection tcp flags & (fin|syn|rst|psh|ack|urg) == 0 log prefix \"[NFT-DROP] NULL-SCAN \" counter drop"
        echo "add rule inet firewall tcp_protection tcp flags & (fin|syn|rst|psh|ack|urg) == fin|syn|rst|psh|ack|urg log prefix \"[NFT-DROP] XMAS-SCAN \" counter drop"

        # ---------------------------------------------------------------------------------
        # Protection SYN flood
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall syn_flood_protection"
        echo "add rule inet firewall input jump syn_flood_protection"
        echo "add rule inet firewall syn_flood_protection tcp flags syn limit rate 60/second burst 200 packets add @syn_flood { ip saddr } log prefix \"[NFT-DROP] SYN-FLOOD-DETECTED \" counter drop"

        # ---------------------------------------------------------------------------------
        # Protection HTTP flood
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall http_protection"
        echo "add rule inet firewall input tcp dport \$HTTP_PORTS jump http_protection"
        echo "add rule inet firewall http_protection ct state new limit rate 200/minute burst 100 packets add @http_flood { ip saddr } log prefix \"[NFT-DROP] HTTP-FLOOD \" counter drop"

        # ---------------------------------------------------------------------------------
        # Protection DNS amplification
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall dns_protection"
        echo "add rule inet firewall input udp dport \$DNS_PORTS jump dns_protection"

        # Bloquer les IP malveillantes dans la chaîne DNS (IPv4)
        echo "add rule inet firewall dns_protection ip saddr @blacklist log prefix \"[NFT-DROP] DNS-BLACKLIST-BLOCKED \" counter drop"
        echo "add rule inet firewall dns_protection ip saddr @port_scanners log prefix \"[NFT-DROP] DNS-PORT-SCANNER-BLOCKED \" counter drop"
        echo "add rule inet firewall dns_protection ip saddr @ssh_bruteforce log prefix \"[NFT-DROP] DNS-SSH-BRUTEFORCE-BLOCKED \" counter drop"
        echo "add rule inet firewall dns_protection ip saddr @syn_flood log prefix \"[NFT-DROP] DNS-SYN-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall dns_protection ip saddr @http_flood log prefix \"[NFT-DROP] DNS-HTTP-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall dns_protection ip saddr @bad_actors log prefix \"[NFT-DROP] DNS-BAD-ACTOR-BLOCKED \" counter drop"

        # Règle DNS spécifique
        echo "add rule inet firewall dns_protection ct state new limit rate 100/second log prefix \"[NFT-DROP] DNS-AMPLIFICATION \" counter drop"

        # ---------------------------------------------------------------------------------
        # Protection ICMP
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall icmp_protection"
        echo "add rule inet firewall input ip protocol icmp jump icmp_protection"

        # Bloquer les IP malveillantes dans la chaîne ICMP (IPv4)
        echo "add rule inet firewall icmp_protection ip saddr @blacklist log prefix \"[NFT-DROP] ICMP-BLACKLIST-BLOCKED \" counter drop"
        echo "add rule inet firewall icmp_protection ip saddr @port_scanners log prefix \"[NFT-DROP] ICMP-PORT-SCANNER-BLOCKED \" counter drop"
        echo "add rule inet firewall icmp_protection ip saddr @ssh_bruteforce log prefix \"[NFT-DROP] ICMP-SSH-BRUTEFORCE-BLOCKED \" counter drop"
        echo "add rule inet firewall icmp_protection ip saddr @syn_flood log prefix \"[NFT-DROP] ICMP-SYN-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall icmp_protection ip saddr @http_flood log prefix \"[NFT-DROP] ICMP-HTTP-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall icmp_protection ip saddr @bad_actors log prefix \"[NFT-DROP] ICMP-BAD-ACTOR-BLOCKED \" counter drop"

        # Règles ICMP spécifiques
        echo "add rule inet firewall icmp_protection icmp type \$ICMP_TYPES limit rate 30/second log prefix \"[NFT-DROP] ICMP-ACCEPTED \" accept"
        echo "add rule inet firewall icmp_protection log prefix \"[NFT-DROP] ICMP \" counter drop"

        # ---------------------------------------------------------------------------------
        # Protection IPv6
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall ipv6_protection"
        echo "add rule inet firewall input ip6 nexthdr icmpv6 jump ipv6_protection"

        # Bloquer les IP malveillantes dans la chaîne IPv6
        echo "add rule inet firewall ipv6_protection ip6 saddr @blacklist6 log prefix \"[NFT-DROP] IPV6-BLACKLIST-BLOCKED \" counter drop"
        echo "add rule inet firewall ipv6_protection ip6 saddr @port_scanners6 log prefix \"[NFT-DROP] IPV6-PORT-SCANNER-BLOCKED \" counter drop"
        echo "add rule inet firewall ipv6_protection ip6 saddr @ssh_bruteforce6 log prefix \"[NFT-DROP] IPV6-SSH-BRUTEFORCE-BLOCKED \" counter drop"
        echo "add rule inet firewall ipv6_protection ip6 saddr @syn_flood6 log prefix \"[NFT-DROP] IPV6-SYN-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall ipv6_protection ip6 saddr @http_flood6 log prefix \"[NFT-DROP] IPV6-HTTP-FLOOD-BLOCKED \" counter drop"
        echo "add rule inet firewall ipv6_protection ip6 saddr @bad_actors6 log prefix \"[NFT-DROP] IPV6-BAD-ACTOR-BLOCKED \" counter drop"

        # Règles IPv6 spécifiques
        echo "add rule inet firewall ipv6_protection icmpv6 type \$ICMPv6_TYPES log prefix \"[NFT-DROP] IPV6-ACCEPTED \" accept"
        echo "add rule inet firewall ipv6_protection log prefix \"[NFT-DROP] IPV6\" counter drop"

        # ---------------------------------------------------------------------------------
        # Protection des ports sensibles
        # ---------------------------------------------------------------------------------

        echo "add chain inet firewall sensitive_ports"
        echo "add rule inet firewall input tcp dport \$SENSITIVE_PORTS jump sensitive_ports"
        echo "add rule inet firewall sensitive_ports ip saddr @whitelist log prefix \"[NFT-DROP] SENSITIVE-PORT-ACCEPTED \" accept"
        echo "add rule inet firewall sensitive_ports log prefix \"[NFT-DROP] SENSITIVE-PORT \" counter drop"

        # ---------------------------------------------------------------------------------
        # Logging et drop final
        # ---------------------------------------------------------------------------------

        echo "add rule inet firewall input log prefix \"[NFT-DROP] FINAL-DROP \" counter drop"

    } > "$temp_rules"

    # Application des règles nftables
    echo "Configuration des règles nftables..."
    check_command nft -f "$temp_rules"
    echo "Règles nftables appliquées avec succès."

    # Sauvegarde de la configuration
    echo "Sauvegarde de la configuration..."
    sudo nft list ruleset | sudo tee "$NFTABLES_CONF" > /dev/null

    # Vérification et ajout du groupe nftables
    if ! getent group nftables >/dev/null; then
        echo "Création du groupe nftables..."
        check_command groupadd nftables
    fi

    CURRENT_USER=$(logname 2>/dev/null || echo "$SUDO_USER")
    if [ -n "$CURRENT_USER" ]; then
        check_command usermod -aG nftables "$CURRENT_USER"
    fi

    echo "Configuration de journald..."
    {

        echo "[Journal]"
        echo "SystemMaxUse=500M"
        echo "SystemMaxFileSize=50M"
        echo "SystemMaxFiles=10"
        echo "Storage=persistent"
        echo "Compress=yes"
        echo "ForwardToSyslog=no"
        echo "RateLimitIntervalSec=30s"
        echo "RateLimitBurst=1000"
        echo "MaxRetentionSec=1month"

    } | sudo tee "/etc/systemd/journald.conf" > /dev/null

    # echo "Configuration des logs..."
    # check_command mkdir -p /var/spool/rsyslog
    # check_command chown root:nftables /var/spool/rsyslog
    # check_command chmod 755 /var/spool/rsyslog

    # Création du répertoires des logs
    # check_command mkdir -p "$NFTABLES_LOG_DIR"

    # check_command touch "$NFTABLES_LOG"
    # check_command chown root:nftables "$NFTABLES_LOG"
    # check_command chmod 640 "$NFTABLES_LOG"

    # Configuration de rsyslog
    # echo "Configuration de rsyslog..."
    # {
        # echo "module(load=\"imuxsock\")"
        # echo "module(load=\"imklog\")"

        # echo "\$FileOwner root"
        # echo "\$FileGroup nftables"
        # echo "\$FileCreateMode 0640"
        # echo "\$DirCreateMode 0755"
        # echo "\$Umask 0022"
        # echo "\$WorkDirectory /var/spool/rsyslog"

        # echo ":msg, contains, \"NFT-DROP\" -$NFTABLES_LOG"
        # echo "& stop"

    # } | sudo tee "/etc/rsyslog.conf" > /dev/null

    # Configuration de logrotate
    # echo "Configuration de logrotate..."
    # {
        # echo "$NFTABLES_LOG {"
        # echo "    daily"
        # echo "    rotate 365"
        # echo "    size 100M"
        # echo "    maxsize 200M"
        # echo "    missingok"
        # echo "    notifempty"
        # echo "    compress"
        # echo "    delaycompress"
        # echo "    sharedscripts"
        # echo "    postrotate"
        # echo "        /usr/bin/systemctl restart rsyslog.service >/dev/null 2>&1 || true"
        # echo "    endscript"
        # echo "}"

    # } | sudo tee "/etc/logrotate.d/rsyslog" > /dev/null

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DU FIREWALL ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}


##############################################################################
## Clam - Activation de l'antivirus                                              
##############################################################################
install_clam() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DE L'ANTIVIRUS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
    
    # Créer un groupe pour ClamAV (s'il n'existe pas déjà)
    if ! getent group clamav > /dev/null; then
        sudo groupadd clamav
        if [ $? -eq 0 ]; then
            echo "Création du groupe clamav - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
        else
            echo "Création du groupe clamav - ERREUR" | tee -a "$LOG_FILES_INSTALL"
        fi
    else
        echo "Le groupe clamav existe déjà" | tee -a "$LOG_FILES_INSTALL"
    fi

    # Ajouter l'utilisateur actuel au groupe clamav
    sudo usermod -aG clamav $USER
    if [ $? -eq 0 ]; then
        echo "Ajout de l'utilisateur au groupe clamav - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Ajout de l'utilisateur au groupe clamav - ERREUR" | tee -a "$LOG_FILES_INSTALL"
    fi

    # Créer les répertoires pour la quarantaine et les logs
    sudo mkdir -p $HOME/.clamav/quarantine $HOME/.clamav/logs
    sudo chown :clamav $HOME/.clamav/quarantine $HOME/.clamav/logs
    sudo chmod 770 $HOME/.clamav/quarantine $HOME/.clamav/logs
    sudo chmod 770 /var/lib/clamav
    if [ $? -eq 0 ]; then
        echo "Création des répertoires de quarantaine et des logs - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Création des répertoires de quarantaine et des logs - ERREUR" | tee -a "$LOG_FILES_INSTALL"
    fi

    # Configurer les exclusions dans clamd.conf
    echo "
    #
    # Exclure de l'analyse
    #
    ExcludePath ^/proc
    ExcludePath ^/sys
    ExcludePath ^/run
    ExcludePath ^/dev
    ExcludePath ^/var/lib/lxcfs/cgroup
    ExcludePath ^$HOME/.clamav/quarantine" | sudo tee -a /etc/clamav/clamd.conf
    if [ $? -eq 0 ]; then
        echo "Configuration des exclusions dans clamd.conf - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Configuration des exclusions dans clamd.conf - ERREUR" | tee -a "$LOG_FILES_INSTALL"
    fi

    # Ajouter les tâches cron
    (crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/freshclam --quiet") | crontab -
    if [ $? -eq 0 ]; then
        echo "Ajout de la tâche cron pour freshclam - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Ajout de la tâche cron pour freshclam - ERREUR" | tee -a "$LOG_FILES_INSTALL"
    fi

    (crontab -l 2>/dev/null; echo "20 21 * * * /usr/bin/clamdscan --fdpass --log=$HOME/.clamav/logs/scan-\$(date +'%d-%m-%Y-%T').log --move=$HOME/.clamav/quarantine /") | crontab -
    if [ $? -eq 0 ]; then
        echo "Ajout de la tâche cron pour clamdscan - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Ajout de la tâche cron pour clamdscan - ERREUR" | tee -a "$LOG_FILES_INSTALL"
    fi

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DE L'ANTIVIRUS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}


##############################################################################
## install_vpn - Activation du vpn                                              
##############################################################################
install_vpn() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DU VPN ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    cd /etc/openvpn
    sudo wget http://support.fastestvpn.com/download/fastestvpn_ovpn/ -O fastestvpn_ovpn.zip
    if [ $? -eq 0 ]; then
        echo "Téléchargement du fichier VPN - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Téléchargement du fichier VPN - ERREUR" | tee -a "$LOG_FILES_INSTALL"
    fi

    sudo unzip fastestvpn_ovpn.zip
    if [ $? -eq 0 ]; then
        echo "Décompression du fichier VPN - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Décompression du fichier VPN - ERREUR" | tee -a "$LOG_FILES_INSTALL"
    fi

    sudo cp /etc/openvpn/tcp_files/* /etc/openvpn/ && sudo cp /etc/openvpn/udp_files/* /etc/openvpn/
    if [ $? -eq 0 ]; then
        echo "Copie des fichiers VPN - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Copie des fichiers VPN - ERREUR" | tee -a "$LOG_FILES_INSTALL"
    fi

    #sudo openvpn --config /etc/openvpn/luxembourg-tcp.ovpn --auth-user-pass /home/alexandre/Documents/pentest/vpn/auth
    # Un commentaire, à réactiver si nécessaire

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DU VPN ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}