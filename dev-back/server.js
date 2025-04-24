// server.js
const express = require('express');
const app = express();
const cors = require('cors');
const path = require('path');
const bcrypt = require('bcrypt');
const session = require('express-session');
const saltRounds = 10;
require('dotenv').config();

const db = require('./config/db'); // Connexion MySQL
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: 'http://localhost:3000',
  credentials: true
}));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.use(session({
  secret: 'secretkey',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: false,
    maxAge: 1000 * 60 * 60 * 24 // 1 jour
  }
}));

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

    // Stocker l'utilisateur dans la session
    req.session.user = {
      id: user.id_client,
      username: user.username,
      role: user.role
    };

    res.json({ success: true, message: 'Connexion réussie ✅' });
  });
});

// API : Register
app.post('/api/register', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ success: false, message: 'Champs requis manquants' });
  }

  const checkEmailSQL = 'SELECT * FROM Client WHERE email = ?';
  db.query(checkEmailSQL, [email], async (err, result) => {
    if (err) return res.status(500).json({ success: false, message: 'Erreur serveur' });

    if (result.length > 0) {
      return res.status(409).json({ success: false, message: 'Email déjà utilisé' });
    }

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

// API : Déconnexion
app.get('/api/logout', (req, res) => {
  req.session.destroy(err => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Erreur lors de la déconnexion' });
    }
    res.clearCookie('connect.sid');
    res.json({ success: true, message: 'Déconnecté avec succès' });
  });
});

// API : Utilisateur connecté ?
app.get('/api/user', (req, res) => {
  if (req.session.user) {
    res.json({ connected: true, user: req.session.user });
  } else {
    res.json({ connected: false });
  }
});
// API : Récupérer tous les produits
app.get('/api/products', (req, res) => {
  const sql = 'SELECT * FROM product';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des produits :', err);
      return res.status(500).json({ success: false, message: 'Erreur serveur' });
    }
    res.json({ success: true, products: results });
  });
});

// API : Ajouter un produit au panier
app.post('/api/panier', (req, res) => {
  if (!req.session.user) {
    return res.status(401).json({ success: false, message: 'Vous n\'êtes pas connecté à un compte client.' });
  }

  const { id_produit } = req.body;
  const id_client = req.session.user.id;

  if (!id_produit) {
    return res.status(400).json({ success: false, message: 'ID produit manquant.' });
  }

  const sql = 'INSERT INTO panier (id_client, id_produit) VALUES (?, ?)';
  db.query(sql, [id_client, id_produit], (err, result) => {
    if (err) {
      console.error('Erreur lors de l\'ajout au panier :', err);
      return res.status(500).json({ success: false, message: 'Erreur lors de l\'ajout au panier.' });
    }
    res.json({ success: true, message: 'Produit ajouté au panier avec succès.' });
  });
});
// Lancer le serveur
app.listen(PORT, () => {
  console.log(`✅ Serveur lancé sur http://localhost:${PORT}`);
});
