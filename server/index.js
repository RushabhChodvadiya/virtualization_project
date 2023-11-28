const tasks = require("./routes/tasks");
const mysql = require("mysql2/promise");
const cors = require("cors");
const express = require("express");
const app = express();

// MySQL connection pool configuration
const pool = mysql.createPool({
  host: process.env.MYSQL_HOST || "localhost",
  port: process.env.MYSQL_PORT || "3306",
  user: process.env.MYSQL_USER || "root",
  password: process.env.MYSQL_PASSWORD || "root",
  database: process.env.MYSQL_DATABASE || "todo",
  waitForConnections: true,
  connectionLimit: 100,
  queueLimit: 0,
});

app.use(express.json());
app.use(cors());

// Pass the MySQL pool to the tasks route
app.use("/api/tasks", tasks(pool));

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`Listening on port ${port}...`));
