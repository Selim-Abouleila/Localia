**Localia**

**Description**
Localia est un site e-commerce sobre qui propose des produits faits main et durables, respectant une fabrication écologique.
Les produits disponibles sont principalement des articles de :
- Textiles
- Décoration
- Mobilier

**Fonctionnalités principales :**
- Authentification (admin/user)
- Gestion de panier et paiement
- Likes sur les produits
- Recherche et filtrage d'articles
- Gestion des produits pour les administrateurs

**Instructions pour cloner, configurer et exécuter le projet en local**
- Cloner le projet
    git clone https://github.com/Selim-Abouleila/Localia.git
    cd localia

- Configurer l'environnement 
    - Installer les dépendances :
        - npm install
    
    - Créer et initialiser la base de données localia :
        - Ouvrez http://localhost/phpmyadmin (apres avoir lancé mysql et apache)
        - Cliquez sur Importer
        - Sélectionnez le fichier localia_complete.sql (fourni dans le projet dans le dossier database)
        - Validez l'importation
        - Cela va automatiquement :
            - Créer la base localia
            - Créer toutes les tables nécessaires
            - Créer les vues, triggers et procédures
            - Insérer les données de base
    
    - Configurer un fichier .env avec vos informations :
        - DB_HOST=localhost
        - DB_USER=root
        - DB_PASSWORD=[votre-mot-de-passe]
        - DB_NAME=localia
    
- Executer le projet : 
    - cd dev-back
    - node server.js
 
- Le serveur sera accessible sur : http://localhost:3000

**Brève description des différentes parties du site :**
Le site Localia se compose de trois parties principales :

- Une page d'accueil (accueil.html) qui introduit le site, présente son concept, propose de contacter le support et de découvrir les produits vendus.
- Une page login/register (login.html et register.html) permettant aux utilisateurs de créer un compte ou de se connecter.
- Une page à propos (about.html) expliquant notre mission écologique, nos engagements et présentant notre équipe.
- Structure technique du projet :
    - dev-front/
        - Contient l'interface utilisateur du site avec les fichiers HTML, CSS et les images nécessaires.
    - dev-back/
        - Contient le serveur Node.js utilisant Express.js, avec :
        - Authentification utilisateur (sessions)
        - Gestion des produits, panier, commandes
        - Connexion et interaction avec la base de données MySQL
    - database/
        - Contient le fichier localia_complete.sql permettant de créer et initialiser toute la base de données : tables, vues, procédures, triggers             et données de base.
