// server.js
const express = require('express');
const app = express();
const cors = require('cors');
const path = require('path');
const bcrypt = require('bcrypt');
const saltRounds = 10;
require('dotenv').config();

const db = require('./config/db'); // Connexion MySQL

const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Servir les fichiers HTML statiques depuis dev-front
app.use(express.static(path.join(__dirname, '../dev-front')));

// Routes HTML
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../dev-front/accueil.html'));
});

app.get('/login', (req, res) => {
  res.sendFile(path.join(__dirname, '../dev-front/login.html'));
});

app.get('/register', (req, res) => {
  res.sendFile(path.join(__dirname, '../dev-front/register.html'));
});

// API : Login
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Champs manquants' });
  }

  const sql = 'SELECT * FROM Client WHERE email = ?';
  db.query(sql, [email], async (err, results) => {
    if (err) {
      console.error('Erreur MySQL :', err);
      return res.status(500).json({ success: false, message: 'Erreur serveur' });
    }

    if (results.length === 0) {
      return res.status(401).json({ success: false, message: 'Email non trouvé ❌' });
    }

    const user = results[0];

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Mot de passe incorrect ❌' });
    }

    res.json({ success: true, message: 'Connexion réussie ✅', user: { id: user.id_client, username: user.username, role: user.role } });
  });
});


app.post('/api/register', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ success: false, message: 'Champs requis manquants' });
  }

  // Vérifier si l'email existe déjà
  const checkEmailSQL = 'SELECT * FROM Client WHERE email = ?';
  db.query(checkEmailSQL, [email], async (err, result) => {
    if (err) return res.status(500).json({ success: false, message: 'Erreur serveur' });

    if (result.length > 0) {
      return res.status(409).json({ success: false, message: 'Email déjà utilisé' });
    }

    // Hasher le mot de passe
    try {
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      const insertSQL = 'INSERT INTO Client (username, password, email, role) VALUES (?, ?, ?, ?)';
      db.query(insertSQL, [username, hashedPassword, email, 'client'], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: 'Erreur lors de l\'inscription' });

        res.status(201).json({ success: true, message: 'Inscription réussie ✅' });
      });
    } catch (hashErr) {
      console.error('Erreur hash bcrypt :', hashErr);
      res.status(500).json({ success: false, message: 'Erreur de sécurité interne' });
    }
  });
});

// Lancer le serveur
app.listen(PORT, () => {
  console.log(`✅ Serveur lancé sur http://localhost:${PORT}`);
});