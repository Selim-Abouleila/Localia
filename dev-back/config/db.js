const mysql = require('mysql2');
const dotenv = require('dotenv');
dotenv.config();


const db = mysql.createConnection(process.env.Connect);

db.connect((err) => {
  if (err) {
    console.error('❌ Erreur de connexion à MySQL :', err);
  } else {
    console.log('✅ Connecté à la base de données MySQL');
  }
});

module.exports = db;
