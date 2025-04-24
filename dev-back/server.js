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

  // 1. Récupérer l'id_panier
  const sqlPanier = 'SELECT id_panier FROM panier WHERE id_client = ?';
  db.query(sqlPanier, [id_client], (err, rows) => {
    if (err || rows.length === 0) {
      return res.status(500).json({ success: false, message: 'Impossible de récupérer le panier client.' });
    }

    const id_panier = rows[0].id_panier;

    // 2. Vérifier si l'article existe déjà dans le panier
    const checkSQL = 'SELECT quantity FROM has WHERE id_panier = ? AND id_produit = ?';
    db.query(checkSQL, [id_panier, id_produit], (err, result) => {
      if (err) return res.status(500).json({ success: false, message: 'Erreur serveur (vérification).' });

      if (result.length > 0) {
        // 3. Si oui → on met à jour la quantité
        const updateSQL = 'UPDATE has SET quantity = quantity + 1 WHERE id_panier = ? AND id_produit = ?';
        db.query(updateSQL, [id_panier, id_produit], (err) => {
          if (err) return res.status(500).json({ success: false, message: 'Erreur mise à jour quantité.' });
          return res.json({ success: true, message: 'Quantité augmentée dans le panier.' });
        });
      } else {
        // 4. Sinon → on insère une nouvelle ligne
        const insertSQL = 'INSERT INTO has (id_panier, id_produit, quantity) VALUES (?, ?, 1)';
        db.query(insertSQL, [id_panier, id_produit], (err) => {
          if (err) return res.status(500).json({ success: false, message: 'Erreur ajout au panier.' });
          return res.json({ success: true, message: 'Produit ajouté au panier.' });
        });
      }
    });
  });
});

// API : Contenu du panier du client connecté
app.get('/api/panier', (req, res) => {
  if (!req.session.user) {
    return res.status(401).json({ success: false, message: 'Non connecté' });
  }

  const id_client = req.session.user.id;

  // Récupérer l'id_panier du client
  const sqlPanier = 'SELECT id_panier FROM panier WHERE id_client = ?';
  db.query(sqlPanier, [id_client], (err, rows) => {
    if (err || rows.length === 0) {
      return res.status(500).json({ success: false, message: 'Panier introuvable.' });
    }

    const id_panier = rows[0].id_panier;

    // Requête JOIN pour récupérer les produits dans le panier
    const sqlContenu = `
      SELECT p.id_produit, p.product_name, p.product_description, p.product_type, p.price, h.quantity
      FROM has h
      JOIN product p ON h.id_produit = p.id_produit
      WHERE h.id_panier = ?
    `;

    db.query(sqlContenu, [id_panier], (err, result) => {
      if (err) {
        console.error('Erreur récupération panier :', err);
        return res.status(500).json({ success: false, message: 'Erreur lecture du panier' });
      }

      res.json({ success: true, produits: result });
    });
  });
});
// API : Supprimer un produit du panier
app.delete('/api/panier/:id_produit', (req, res) => {
  if (!req.session.user) {
    return res.status(401).json({ success: false, message: 'Non connecté' });
  }

  const id_client = req.session.user.id;
  const id_produit = req.params.id_produit;

  // Récupérer le panier du client
  const sqlPanier = 'SELECT id_panier FROM panier WHERE id_client = ?';
  db.query(sqlPanier, [id_client], (err, rows) => {
    if (err || rows.length === 0) {
      return res.status(500).json({ success: false, message: 'Panier introuvable.' });
    }

    const id_panier = rows[0].id_panier;

    // Supprimer l'entrée correspondante dans la table has
    const sqlDelete = 'DELETE FROM has WHERE id_panier = ? AND id_produit = ?';
    db.query(sqlDelete, [id_panier, id_produit], (err, result) => {
      if (err) {
        console.error('Erreur suppression panier :', err);
        return res.status(500).json({ success: false, message: 'Erreur lors de la suppression.' });
      }

      res.json({ success: true, message: 'Produit supprimé du panier.' });
    });
  });
});
app.post('/api/commande', (req, res) => {
  if (!req.session.user) {
    return res.status(401).json({ success: false, message: 'Vous devez être connecté.' });
  }

  const id_client = req.session.user.id;

  // 1. Trouver le panier du client
  const sqlGetPanier = 'SELECT id_panier FROM panier WHERE id_client = ?';
  db.query(sqlGetPanier, [id_client], (err, rows) => {
    if (err || rows.length === 0) {
      return res.status(500).json({ success: false, message: 'Panier introuvable.' });
    }

    const id_panier = rows[0].id_panier;

    // 2. Récupérer les produits du panier
    const sqlGetProduits = 'SELECT * FROM has WHERE id_panier = ?';
    db.query(sqlGetProduits, [id_panier], (err, produits) => {
      if (err || produits.length === 0) {
        return res.status(400).json({ success: false, message: 'Aucun produit dans le panier.' });
      }

      // 3. Créer une commande
      const sqlCommande = 'INSERT INTO commande (Order_date, Status, id_client, id_panier) VALUES (NOW(), "en attente", ?, ?)';
      db.query(sqlCommande, [id_client, id_panier], (err, result) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Erreur lors de la création de la commande.' });
        }

        const id_commande = result.insertId;

        // 4. Insérer chaque produit dans la table involves
        const sqlInvolves = 'INSERT INTO involves (id_commande, id_produit, quantity, price) VALUES ?';
        const valeurs = produits.map(p => [id_commande, p.id_produit, p.quantity, 0]); // prix = 0 pour l’instant, ou tu peux faire un JOIN pour le vrai prix

        db.query(sqlInvolves, [valeurs], (err) => {
          if (err) {
            return res.status(500).json({ success: false, message: 'Erreur lors de l’ajout des produits à la commande.' });
          }

          // 5. Vider le panier
          const sqlViderPanier = 'DELETE FROM has WHERE id_panier = ?';
          db.query(sqlViderPanier, [id_panier], (err) => {
            if (err) {
              return res.status(500).json({ success: false, message: 'Commande validée, mais erreur lors du vidage du panier.' });
            }

            res.json({ success: true, message: 'Commande validée avec succès ✅' });
          });
        });
      });
    });
  });
});
// Lancer le serveur
app.listen(PORT, () => {
  console.log(`✅ Serveur lancé sur http://localhost:${PORT}`);
});
