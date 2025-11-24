<div align="center">
<img width="1460" height="337" alt="Image" src="https://github.com/user-attachments/assets/271c082b-15c4-434e-aabf-e60e588ff22f" />
<h1>🧅 ft_onion </h1>
  <h2>Déployer son propre site .onion avec Nginx et Docker</h2>
  <p align="center">
  <!-- <img src="https://img.shields.io/badge/Python-3.8+-blue.svg?style=for-the-badge&logo=python&logoColor=white" alt="Python Version"> -->
  <img src="https://img.shields.io/badge/Status-Active-success.svg?style=for-the-badge" alt="Status">
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg?style=for-the-badge" alt="Platform">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Docker-Compose-blue.svg?style=flat-square" alt="Threads">
  <img src="https://img.shields.io/badge/Recursion-Configurable-blueviolet.svg?style=flat-square" alt="Recursion">
  <img src="https://img.shields.io/badge/Logging-Full%20Support-informational.svg?style=flat-square" alt="Logging">
</p>
</div>

Un projet complet pour héberger un service caché Tor (Hidden Service) avec une architecture Docker Compose propre et persistante.

---
<img width="2327" height="1356" alt="Image" src="https://github.com/user-attachments/assets/554488db-9ec4-4823-87e0-5954f18394f7" />

## 📚 Table des matières

- [Introduction](#-introduction)
  - [Qu'est-ce que Tor ?](#-tor--cest-quoi-)
  - [Les sites .onion](#-les-sites-onion--cest-quoi-)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Persistance des clés](#-persistance-des-clés-onion)
- [Utilisation](#-utilisation)

---

## 🌐 Introduction

### 🔐 Tor : c'est quoi ?

**Tor** (The Onion Router) est un réseau conçu pour offrir **anonymat** et **confidentialité** sur Internet.

Il fonctionne en chiffrant le trafic et en le faisant passer par **plusieurs relais** (3 en général) choisis aléatoirement :

```
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐
│  Toi    │ ---> │ Entrée  │ ---> │ Relais  │ ---> │ Sortie  │ ---> Destination
└─────────┘      └─────────┘      └─────────┘      └─────────┘
                 Connaît ton IP    Ne sait rien     Voit la destination
                 Pas la dest.      d'utile          Pas ton IP
```

À chaque étape, une **couche de chiffrement** est retirée → d'où le nom **"oignon"** 🧅

#### 🎯 Objectifs de Tor

- ✅ **Cacher ton identité** (IP)
- ✅ **Empêcher le traçage** de ton activité réseau
- ✅ **Contourner la censure** géographique
- ⚠️ **Attention** : Si tu te connectes avec ton compte personnel, tu n'es **pas anonyme** !

---

### 🕸️ Les sites .onion : c'est quoi ?

Les sites en `.onion` sont des **services cachés Tor** (*Hidden Services*).  
Ils n'existent qu'**à l'intérieur du réseau Tor** et ne sont pas accessibles via un navigateur classique.

#### Caractéristiques

| Propriété | Description |
|-----------|-------------|
| 🔑 **Adresse .onion** | Identifiant cryptographique généré automatiquement |
| 🌐 **Pas de DNS** | Le routage est assuré par Tor directement |
| 🔒 **Serveur caché** | On ne connaît pas son IP réelle |
| 🤝 **Anonymat mutuel** | Client et serveur sont tous deux anonymes |

#### À quoi ça sert ?

- 📰 **Journalisme** / lanceurs d'alerte (ex : [SecureDrop](https://securedrop.org/))
- 🏢 **Services officiels** (ex : Facebook, BBC, ProtonMail ont leur .onion)
- 🔐 **Sites voulant rester anonymes**
- ⚠️ Marchés noirs / activités illégales (là où Tor a mauvaise réputation)

---

## 🏗️ Architecture

Le projet utilise **Docker Compose** avec une séparation claire des responsabilités :

```
ft_onion/
├── docker-compose.yml       # Orchestration des services
├── html/
│   └── index.html           # Site web à déployer
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf           # Configuration Nginx
└── tor/
    ├── Dockerfile
    └── torrc                # Configuration Tor
```

### 🐳 Architecture Docker Compose

```yaml
services:
  nginx:
    # Serveur web qui héberge le contenu
    build: ./nginx
    ports:
      - "8080:80"            # Accessible en local sur :8080
    volumes:
      - ./html:/usr/share/nginx/html:ro
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro

  tor:
    # Service Tor qui crée le .onion
    build: ./tor
    volumes:
      - ./tor/torrc:/etc/tor/torrc:ro
      - ~/hidden_service_backup:/var/lib/tor/hidden_service
    # ⬆️ IMPORTANT: Volume pour persister les clés
```

#### 🔄 Flux de données

```
Internet (Tor) --> tor:9050 --> nginx:80 --> html/index.html
                    Service caché            Serveur web
```

---

## 🚀 Installation

### Prérequis

- Docker + Docker Compose installés
- Tor Browser (pour tester l'accès)

### 1️⃣ Clone le projet

```bash
git clone https://github.com/monsieurCanard/ft_onion.git
cd ft_onion
```

### 2️⃣ Crée le dossier de sauvegarde

```bash
mkdir -p ~/hidden_service_backup
chmod 700 ~/hidden_service_backup
```

> ⚠️ **Important** : Ce dossier contiendra tes clés privées. Protège-le !

### 3️⃣ Lance les services

```bash
docker-compose up -d
```

### 4️⃣ Récupère ton adresse .onion

```bash
docker exec tor_onion cat /var/lib/tor/hidden_service/hostname
```

**Résultat attendu :**
```
abc123xyz456def789ghi.onion
```

---

## 🔑 Persistance des clés .onion

### 🤔 Le problème

Par défaut, Tor génère une **nouvelle adresse .onion** à chaque démarrage du conteneur.  
Si tu détruis le conteneur → **tu perds ton adresse** !

### ✅ La solution : Volume Docker

Dans le `docker-compose.yml`, on monte un **volume persistant** :

```yaml
tor:
  volumes:
    - ~/hidden_service_backup:/var/lib/tor/hidden_service
    #     ⬆️ Dossier local         ⬆️ Dossier dans le conteneur
```

#### 📂 Contenu du dossier persisté

```bash
~/hidden_service_backup/
├── hostname              # Ton adresse .onion
├── hs_ed25519_public_key # Clé publique
└── hs_ed25519_secret_key # Clé privée (À PROTÉGER !)
```

### 🔄 Avantages

| Avant (sans volume) | Après (avec volume) |
|---------------------|---------------------|
| ❌ Nouvelle adresse à chaque restart | ✅ Adresse .onion permanente |
| ❌ Impossible de sauvegarder | ✅ Backup facile (`cp -r ~/hidden_service_backup`) |
| ❌ Perte de réputation | ✅ URL stable pour tes utilisateurs |


---

## 🎮 Utilisation

1. Ouvre **Tor Browser**
2. Colle ton adresse `.onion` dans la barre d'URL
3. Patiente quelques secondes (le réseau Tor est lent)
4. 🎉 Ton site s'affiche !

### Arrêter les services

```bash
docker-compose down
```


---

**Made with 💜 for privacy**
