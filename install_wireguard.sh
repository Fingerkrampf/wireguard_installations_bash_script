#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Dieses Skript ist freie Software: Sie können es unter den Bedingungen
# der GNU General Public License, wie von der Free Software Foundation veröffentlicht,
# weiterverbreiten und/oder modifizieren, entweder gemäß Version 3 der Lizenz oder
# (nach Ihrer Wahl) jeder späteren Version.
#
# Dieses Skript wird in der Hoffnung verteilt, dass es nützlich sein wird,
# aber OHNE JEDE GEWÄHRLEISTUNG – sogar ohne die implizite Gewährleistung
# der MARKTFÄHIGKEIT oder EIGNUNG FÜR EINEN BESTIMMTEN ZWECK.
#
# Siehe die GNU General Public License für weitere Details.
# <https://www.gnu.org/licenses/>.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# WireGuard VPN Server Setup Script – von Fingerkrampf / PiNetzwerkDeutschland.de
# VER 2025-05-04  (automatisiertes Bash-Installationsskript für die Einrichtung 
# eines WireGuard VPN-Servers auf Debian/Ubuntu inkl. Client-Konfiguration)
# HINWEIS: Die Nutzung und Ausführung des Skripts erfolgt auf eigene Verantwortung.
# Das Skript dient ausschließlich zur Vereinfachung der VPN-Server-Einrichtung.
# Für etwaige Schäden, Fehlkonfigurationen oder Sicherheitsrisiken wird keine 
# Haftung übernommen.
# Alle verwendeten Pakete stammen aus offiziellen Quellen (APT & WireGuard).
# ------------------------------------------------------------------------------
# Funktionen des Skripts:
#   • Systemupdate & Paketinstallation
#   • Automatische Generierung von Server- und Client-Schlüsseln
#   • Erstellung der Server-Konfigurationsdatei inkl. Firewall & NAT
#   • Aktivierung des WireGuard-Interfaces & Autostart
#   • Erstellung und Anzeige der fertigen Client-Konfiguration
# ------------------------------------------------------------------------------

# Sicherstellen, dass das Skript als root ausgeführt wird
if [[ $EUID -ne 0 ]]; then
  echo "Dieses Skript muss als root ausgeführt werden."
  exit 1
fi

echo "WireGuard-Installation und Konfiguration beginnt..."

# Standardnetzwerkschnittstelle ermitteln
DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}')

if [[ -z "$DEFAULT_INTERFACE" ]]; then
  echo "Fehler: Standardnetzwerkschnittstelle konnte nicht ermittelt werden."
  exit 1
fi

echo "Ermittelte Standardnetzwerkschnittstelle: $DEFAULT_INTERFACE"

# Öffentliche IPv4-Adresse ermitteln
SERVER_IP=$(curl -4 -s https://ifconfig.me)

if [[ -z "$SERVER_IP" ]]; then
  echo "Fehler: Öffentliche IPv4-Adresse konnte nicht ermittelt werden."
  exit 1
fi

echo "Ermittelte Server-IP-Adresse: $SERVER_IP"

# Updates und benötigte Pakete installieren
echo "System aktualisieren und benötigte Pakete installieren..."
apt update && apt-mark hold openssh-server && apt upgrade -y
apt install -y ca-certificates apt-transport-https nano wireguard iptables curl

# IPv4-Forwarding dauerhaft aktivieren
echo "IPv4-Forwarding aktivieren..."
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard.conf
sysctl --system

# WireGuard-Schlüssel erstellen
echo "WireGuard-Schlüssel generieren..."
mkdir -p /etc/wireguard
chmod 700 /etc/wireguard
umask 077
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
wg genkey | tee /etc/wireguard/client1_private.key | wg pubkey > /etc/wireguard/client1_public.key

SERVER_PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)

# Benutzer nach dem Public Key des Clients fragen (Grüne Schriftfarbe)
echo -e "\033[1;32mBitte geben Sie den öffentlichen Schlüssel (Public Key) des Clients ein:\033[0m"
read CLIENT1_PUBLIC_KEY

if [[ -z "$CLIENT1_PUBLIC_KEY" ]]; then
  echo "Fehler: Es wurde kein Public Key eingegeben."
  exit 1
fi

# Benutzer nach dem Private Key des Clients fragen (Grüne Schriftfarbe)
echo -e "\033[1;32mBitte geben Sie den privaten Schlüssel (Private Key) des Clients ein:\033[0m"
read CLIENT1_PRIVATE_KEY

if [[ -z "$CLIENT1_PRIVATE_KEY" ]]; then
  echo "Fehler: Es wurde kein Private Key eingegeben."
  exit 1
fi

# WireGuard-Konfigurationsdatei erstellen
echo "WireGuard-Konfigurationsdatei erstellen..."
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 192.168.200.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIVATE_KEY
PostUp = iptables -A FORWARD -i %i -o $DEFAULT_INTERFACE -j ACCEPT; iptables -A FORWARD -i $DEFAULT_INTERFACE -o %i -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT; iptables -t nat -A POSTROUTING -o $DEFAULT_INTERFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -o $DEFAULT_INTERFACE -j ACCEPT; iptables -D FORWARD -i $DEFAULT_INTERFACE -o %i -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT; iptables -t nat -D POSTROUTING -o $DEFAULT_INTERFACE -j MASQUERADE

# Logging der eingehenden Verbindungen aktivieren
PostUp = iptables -A INPUT -i $DEFAULT_INTERFACE -p udp --dport 51820 -j LOG --log-prefix "WG-IN: " --log-level 4

[Peer]
PublicKey = $CLIENT1_PUBLIC_KEY
AllowedIPs = 192.168.200.2/32
EOF

# WireGuard starten und für Autostart aktivieren
echo "WireGuard-Interface aktivieren..."
wg-quick up wg0
systemctl enable wg-quick@wg0

# Firewall-Regeln in der Systemkonfiguration setzen
echo "Firewall-Regeln einrichten..."
iptables -A INPUT -i $DEFAULT_INTERFACE -p udp --dport 51820 -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i $DEFAULT_INTERFACE -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -P INPUT DROP

# NAT und Forwarding für WireGuard-Clients aktivieren
iptables -A FORWARD -i wg0 -o $DEFAULT_INTERFACE -j ACCEPT
iptables -A FORWARD -i $DEFAULT_INTERFACE -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Portweiterleitung von extern zu WireGuard-Client
iptables -t nat -A PREROUTING -i $DEFAULT_INTERFACE -p tcp -m multiport --dport 31400:31409 -j DNAT --to-destination 192.168.200.2

# Sicherstellen, dass alle Forwarding-Regeln korrekt sind
iptables -P FORWARD ACCEPT

# Client-Konfiguration erstellen und speichern
echo "Erstellung der Client-Konfiguration..."
cat <<EOF > /etc/wireguard/client1.conf
[Interface]
PrivateKey = $CLIENT1_PRIVATE_KEY
Address = 192.168.200.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Sicherstellen, dass die Client-Konfigurationsdatei existiert
if [[ -f /etc/wireguard/client1.conf ]]; then
  echo "Die Client-Konfiguration wurde unter /etc/wireguard/client1.conf gespeichert."
else
  echo "Fehler: Die Client-Konfigurationsdatei konnte nicht erstellt werden."
  exit 1
fi

clear
echo "Installation und Konfiguration erfolgreich abgeschlossen!"
echo " "
echo "Kopieren Sie den folgenden Inhalt zwischen den Strichen und fügen Sie ihn in die WireGuard-Client-Konfigurationsdatei ein:"
echo "------------------------------------------------"
echo -e "\033[1;32m"
cat /etc/wireguard/client1.conf
echo -e "\033[0m"
echo "------------------------------------------------"
