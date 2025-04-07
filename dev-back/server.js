// server.js
const express = require('express');
const app = express();

// Pour les variables d'environnement (ex: PORT)
require('dotenv').config();

const PORT = process.env.PORT || 3000;

// Middleware pour lire les données des formulaires (POST)
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Route de base
app.get('/', (req, res) => {
  res.send('Bienvenue sur le serveur Green Crafts 🌿');
});

// Lancer le serveur
app.listen(PORT, () => {
  console.log(`✅ Serveur lancé sur http://localhost:${PORT}`);
});