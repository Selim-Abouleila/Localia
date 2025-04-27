const mysql = require('mysql2');
const dotenv = require('dotenv');
dotenv.config();

// 👉 This is your full Railway URL saved in an env variable (for example DATABASE_URL)
const DATABASE_URL = process.env.Connect; // or whatever your var is called
const dbUrl = new URL(DATABASE_URL);

// 👉 Parse it manually
const db = mysql.createConnection({
  host: dbUrl.hostname,
  user: dbUrl.username,
  password: dbUrl.password,
  database: dbUrl.pathname.substring(1), // remove the starting "/"
  port: dbUrl.port,
});

db.connect((err) => {
  if (err) {
    console.error('❌ Erreur de connexion à MySQL :', err);
  } else {
    console.log('✅ Connecté à la base de données MySQL');
  }
});

module.exports = db;
