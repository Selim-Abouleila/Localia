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
    npm run dev

