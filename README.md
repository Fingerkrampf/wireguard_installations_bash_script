# 🛡️ WireGuard VPN Server Setup Script

Ein vollständig automatisiertes Bash-Skript zur Installation und Konfiguration eines WireGuard-VPN-Servers auf Debian/Ubuntu-Systemen – inklusive Client-Konfiguration und Firewall-Regeln.

---

## 📦 Funktionen

- Systemaktualisierung & Installation aller benötigten Pakete
- Automatische Erkennung der Netzwerkumgebung (Interface & öffentliche IP)
- Generierung sicherer Schlüsselpaare für Server und Client
- Erstellung der WireGuard-Serverkonfiguration (`wg0.conf`)
- Einrichtung von IP-Forwarding und Firewall/NAT mit `iptables`
- Aktivierung und Autostart des VPN-Interfaces
- Erstellung einer vollständigen Client-Konfiguration (`client1.conf`)
- Anzeige der Client-Konfigurationsdaten im Terminal

---

## 🚀 Schnellstart

```bash
sudo bash setup-wireguard.sh
```

> ⚠️ Das Skript **muss als root ausgeführt** werden!

---

## 📄 Voraussetzungen

- Debian oder Ubuntu (frisch installiert empfohlen)
- Root-Zugriff auf das System
- Internetverbindung

---

## 📁 Ausgabe

Nach erfolgreichem Durchlauf befinden sich im Verzeichnis `/etc/wireguard`:

- `wg0.conf` – Server-Konfiguration
- `client1.conf` – Fertige Client-Konfigurationsdatei
- `*.key` – Generierte Schlüsselpaare

---

## 🔒 Sicherheitshinweis

Dieses Skript aktiviert grundlegende Firewall-Regeln mit `iptables`. Für produktive Systeme wird empfohlen, diese Regeln individuell zu überprüfen und ggf. zu erweitern.

---

## 📜 Lizenz

Dieses Skript ist freie Software: Sie können es unter den Bedingungen der  
**GNU General Public License v3.0** weiterverbreiten und/oder modifizieren.

Mehr Informationen: [https://www.gnu.org/licenses/](https://www.gnu.org/licenses/)

---

## 🙋‍♂️ Autor

**Fingerkrampf / PiNetzwerkDeutschland.de**  
Bei Fragen oder Verbesserungsvorschlägen gerne ein Issue oder Pull Request eröffnen!
