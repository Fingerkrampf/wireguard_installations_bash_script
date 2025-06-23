[ENGLISH]

# Workaround: Running a Pi Node behind DS‑Lite + IPv6

This guide explains how to run a Pi Network Node on **Windows** when your ISP provides only a DS‑Lite + IPv6 connection (no public IPv4). It uses a **WireGuard VPN tunnel** to a VPS to bypass this limitation.

*Last updated: June 23, 2025*

---

## 🛠️ Requirements

* **Windows 11 x64 (Home or Pro)**, fully up-to-date
* Internet connection with **Dual‑Stack‑Lite (DS‑Lite) + IPv6**
* **VPS (Ubuntu 24.04 LTS)** with a **public IPv4 address** and root or sudo access
* **Pi Node software** (v0.5, auto‑upgrading to v0.5.1)
* **WireGuard** (latest Windows client)
* **Docker Desktop** (v4.42.1 or newer)
* **SSH client** (e.g. PuTTY)

---

## 🚀 Step 1: Set Up Windows Client

1. **Download and install**:

   * Pi Node software
   * Docker Desktop v4.42.1
   * WireGuard for Windows
   * PuTTY (SSH client)

2. **Enable Windows features** (run PowerShell as admin):

   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
      ```
      ```powershell
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

   * Restart the PC
   * Install the latest WSL2 Linux kernel update
   * Run:

     ```powershell
     wsl --set-default-version 2
        ```
        ```powershell
     wsl --update
     ```

3. **Configure Windows Firewall for Pi Node**:

   * Open **Windows Defender Firewall > Advanced Settings**
   * Create inbound & outbound rules for **TCP ports 31400–31409**
   * Alternatively, my batch script (https://github.com/Fingerkrampf/Windows_Firewall_Port_Opener_Script) can be downloaded, unzipped and run "as administrator". This batch script automatically inserts all the required ports into the Windows Firewall
   * If your VPS provider has a firewall, open these same ports there too

---

## 🔧 Step 2: Configure WireGuard VPN

### On Windows (Client)

* Open WireGuard and create a new tunnel
* Copy private & public keys. These are required for the Wireguard Linux installation

### On VPS (Ubuntu 24.04)

1. SSH into the server with PuTTY
2. Run the following to install WireGuard:

   ```bash
   sudo su
   apt update \
     && apt-mark hold openssh-server \
     && apt upgrade -y \
     && apt install -y unzip wget \
     && wget https://github.com/Fingerkrampf/wireguard_installations_bash_script/archive/refs/heads/main.zip -O wg.zip \
     && unzip wg.zip \
     && cd wireguard_installations_bash_script-main \
     && sed -i 's/\r//' install_wireguard.sh \
     && chmod +x install_wireguard.sh \
     && ./install_wireguard.sh
   ```
3. Paste the **public + private key** that you see on Windows when prompted
4. Copy the green Config lines at the end of installation or copy the contents of `/etc/wireguard/client1.conf` to your Windows WireGuard client config
5. Save, activate tunnel

> ✅ At this point, your Windows PC is connected to the internet **via the VPS public IPv4 address**

Don’t forget: open **UDP WireGuard port (usually 51820)** and **TCP 31400–31409** in the VPS firewall/web console

---

## 🐳 Step 3: Install Docker & Pi Node

1. Install **Docker Desktop**
2. Install the **Pi Node software**
3. Reboot your PC
4. Docker Desktop and the Pi Node Software should now automatically start. Start Pi Node by toggling the switch. 

   * **Pi Port Checker** (needs TCP 31400–31409 open)
   * **Pi Network Testnet2 / Consensus** (uses TCP ports 31401–31403)

Ensure at least one container is running for port checks to succeed.

---

## 🤝 Summary

This workaround gives your Pi Node a **public IPv4 address via your VPS using WireGuard**, bypassing the IPv4 restrictions of DS‑Lite. It ensures full Pi Node functionality even with an IPv6-only ISP connection.

---

## ✅ References

* Original German workaround on PiNetzwerk Deutschland ([pinetzwerkdeutschland.de][1])
* WireGuard VPN and port forwarding explained ([pinetzwerkdeutschland.de][2])

---

Feel free to contribute improvements or report issues via GitHub.

[1]: https://pinetzwerkdeutschland.de/betrieb-eines-pi-node-mit-einem-ds-lite-und-ipv6-anschluss/?utm_source=chatgpt.com "Betrieb eines Pi Node mit einem DS-lite und IPv6 Anschluss"
[2]: https://pinetzwerkdeutschland.de/pi-network-windows-node-setup-wizard/?utm_source=chatgpt.com "Pi Network Windows Node Setup Wizard - Pi Netzwerk Deutschland"


## 📜 License

This script is free software: you can redistribute and/or modify it under the terms of the GNU General Public License v3.0.

For more information, please visit: https://www.gnu.org/licenses/

## 🙋‍♂️ Author

Fingerkrampf / PiNetzwerkDeutschland.de
If you have any questions or suggestions for improvements, feel free to open an issue or submit a pull request!

---
---

[GERMAN]

# Workaround: Betrieb eines Pi Node hinter DS‑Lite + IPv6

Diese Anleitung erklärt, wie du einen Pi Network Node unter **Windows** betreiben kannst, wenn dein Internetanbieter dir nur eine **DS‑Lite + IPv6**‑Verbindung bereitstellt (also keine öffentliche IPv4-Adresse). Zur Umgehung dieser Einschränkung wird ein **WireGuard-VPN-Tunnel** zu einem VPS verwendet.

*Letzte Aktualisierung: 23. Juni 2025*

---

## 🛠️ Voraussetzungen

* **Windows 11 x64 (Home oder Pro)**, vollständig aktualisiert
* Internetverbindung mit **Dual‑Stack‑Lite (DS‑Lite) + IPv6**
* **VPS (Ubuntu 24.04 LTS)** mit **öffentlicher IPv4-Adresse** und Root- oder Sudo-Zugang
* **Pi Node Software** (v0.5, automatische Aktualisierung auf v0.5.1)
* **WireGuard** (aktuelle Windows-Version)
* **Docker Desktop** (v4.42.1 oder neuer)
* **SSH-Client** (z. B. PuTTY)

---

## 🚀 Schritt 1: Windows-Client vorbereiten

1. **Herunterladen und installieren**:

   * Pi Node Software
   * Docker Desktop v4.42.1
   * WireGuard für Windows
   * PuTTY (SSH-Client)

2. **Windows-Features aktivieren** (PowerShell als Administrator ausführen):

   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
      ```
      ```powershell
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

   * PC neu starten
   * Aktuelles WSL2-Linux-Kernel-Update installieren
   * Danach ausführen:

     ```powershell
     wsl --set-default-version 2
        ```
      ```powershell
     wsl --update
     ```

3. **Windows-Firewall für den Pi Node konfigurieren**:

   * Öffne **Windows Defender Firewall > Erweiterte Einstellungen**
   * Erstelle eingehende und ausgehende Regeln für **TCP-Ports 31400–31409**
   * Alternativ kann mein Batch Skript (https://github.com/Fingerkrampf/Windows_Firewall_Port_Opener_Script) herunterladen, entpacken und "als Administrator ausführen", ausgeführt werden. Dieses Batchskript fügt automatisch alle erforderlichen Ports in die Windows-Firewall ein
   * Falls dein VPS-Anbieter eine eigene Firewall verwendet, dort ebenfalls dieselben Ports freigeben

---

## 🔧 Schritt 2: WireGuard VPN konfigurieren

### Auf Windows (Client)

* Öffne WireGuard und erstelle ein neues Tunnel-Profil
* Öffentlichen & privaten Schlüssel kopieren. Diese werden für die Wireguard Linux Installation benötigt

### Auf dem VPS (Ubuntu 24.04)

1. Per SSH (z. B. mit PuTTY) auf den Server einloggen

2. Folgenden Befehl zur Installation von WireGuard ausführen:

   ```bash
   sudo su
   apt update \
     && apt-mark hold openssh-server \
     && apt upgrade -y \
     && apt install -y unzip wget \
     && wget https://github.com/Fingerkrampf/wireguard_installations_bash_script/archive/refs/heads/main.zip -O wg.zip \
     && unzip wg.zip \
     && cd wireguard_installations_bash_script-main \
     && sed -i 's/\r//' install_wireguard.sh \
     && chmod +x install_wireguard.sh \
     && ./install_wireguard.sh
   ```

3. Fügen Sie den **öffentlichen + privaten Schlüssel**, den Sie unter Windows angezeigt bekommen, ein, wenn Sie dazu aufgefordert werden

4. Die grünen Konfigurationszeilen am Ende der Installation kopieren oder alternativ den Inhalt von `/etc/wireguard/client1.conf` in den Windows-Client einfügen

5. Speichern und Tunnel aktivieren

> ✅ Dein Windows-PC ist nun über die **öffentliche IPv4-Adresse deines VPS** mit dem Internet verbunden

Nicht vergessen: Auf dem VPS die **UDP-Portweiterleitung für WireGuard (Standard: 51820)** und **TCP 31400–31409** in der Firewall oder Weboberfläche öffnen

---

## 🐳 Schritt 3: Docker & Pi Node installieren

1. **Docker Desktop installieren**
2. **Pi Node Software installieren**
3. PC neu starten
4. Docker Desktop und die Pi Node Software sollten jetzt automatisch starten. Aktiviere den Pi Node über den Schiebeschalter.

   * **Pi Port Checker** (benötigt TCP 31400–31409 offen)
   * **Pi Network Testnet2 / Consensus** (nutzt TCP 31401–31403)

Mindestens ein Container muss laufen, damit der Port-Check funktioniert.

---

## 🤝 Zusammenfassung

Mit diesem Workaround erhält dein Pi Node eine **öffentliche IPv4-Adresse über den VPS mittels WireGuard**, wodurch die Einschränkungen eines DS‑Lite-Anschlusses umgangen werden. So funktioniert der Node auch bei IPv6-only‑Anschlüssen zuverlässig.

---

## 📜 Lizenz

Dieses Skript ist freie Software: Du kannst es unter den Bedingungen der **GNU General Public License v3.0** weiterverbreiten und/oder verändern.

Mehr Informationen: [https://www.gnu.org/licenses/](https://www.gnu.org/licenses/)

---

## 🙋‍♂️ Autor

**Fingerkrampf / PiNetzwerkDeutschland.de**
Bei Fragen oder Verbesserungsvorschlägen gerne ein Issue oder Pull Request eröffnen!

---

