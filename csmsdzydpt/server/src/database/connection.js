const initSqlJs = require('sql.js');
const fs = require('fs');
const path = require('path');
const config = require('../config');

let SQL = null;
let db = null;

// Wrapper class that provides better-sqlite3-like API over sql.js
class DatabaseWrapper {
  constructor(db) {
    this.db = db;
  }

  prepare(sql) {
    return new StatementWrapper(this.db, sql);
  }

  exec(sql) {
    return this.db.exec(sql);
  }

  pragma(str) {
    this.db.run(`PRAGMA ${str}`);
  }

  transaction(fn) {
    const self = this;
    return function (...args) {
      self.db.run('BEGIN TRANSACTION');
      try {
        fn.apply(this, args);
        self.db.run('COMMIT');
      } catch (e) {
        self.db.run('ROLLBACK');
        throw e;
      }
    };
  }
}

class StatementWrapper {
  constructor(db, sql) {
    this.db = db;
    this.sql = sql;
  }

  _bind(params) {
    let sql = this.sql;
    if (Array.isArray(params)) {
      for (let i = 0; i < params.length; i++) {
        const val = params[i];
        if (val === null || val === undefined) {
          sql = sql.replace('?', 'NULL');
        } else if (typeof val === 'number') {
          sql = sql.replace('?', val.toString());
        } else if (typeof val === 'boolean') {
          sql = sql.replace('?', val ? '1' : '0');
        } else {
          sql = sql.replace('?', `'${String(val).replace(/'/g, "''")}'`);
        }
      }
    }
    return sql;
  }

  get(...params) {
    const sql = this._bind(params);
    const results = this.db.exec(sql);
    if (results.length > 0 && results[0].values.length > 0) {
      const columns = results[0].columns;
      const values = results[0].values[0];
      const row = {};
      columns.forEach((col, i) => {
        row[col] = values[i] !== undefined ? values[i] : null;
      });
      return row;
    }
    return undefined;
  }

  all(...params) {
    const sql = this._bind(params);
    const results = this.db.exec(sql);
    if (results.length > 0) {
      const columns = results[0].columns;
      return results[0].values.map(rowValues => {
        const row = {};
        columns.forEach((col, i) => {
          row[col] = rowValues[i] !== undefined ? rowValues[i] : null;
        });
        return row;
      });
    }
    return [];
  }

  run(...params) {
    const sql = this._bind(params);
    this.db.run(sql);
    // Get last insert ID
    const idResult = this.db.exec('SELECT last_insert_rowid() as id');
    return {
      lastInsertRowid: idResult.length > 0 ? idResult[0].values[0][0] : 0,
      changes: this.db.getRowsModified()
    };
  }
}

async function initDatabase() {
  if (!SQL) {
    SQL = await initSqlJs();
  }
  if (!db) {
    // Ensure data directory exists
    const dir = path.dirname(config.DB_PATH);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    if (fs.existsSync(config.DB_PATH)) {
      try {
        const buffer = fs.readFileSync(config.DB_PATH);
        db = new DatabaseWrapper(new SQL.Database(buffer));
      } catch {
        db = new DatabaseWrapper(new SQL.Database());
      }
    } else {
      db = new DatabaseWrapper(new SQL.Database());
    }
  }
  return db;
}

function getDb() {
  if (!db) throw new Error('Database not initialized. Call initDatabase() first.');
  return db;
}

function saveDb() {
  if (db && db.db) {
    const dir = path.dirname(config.DB_PATH);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    const data = db.db.export();
    const buffer = Buffer.from(data);
    fs.writeFileSync(config.DB_PATH, buffer);
  }
}

function closeDb() {
  if (db) {
    saveDb();
    db.db.close();
    db = null;
    SQL = null;
  }
}

let saveInterval = null;
function startAutoSave(intervalMs = 5000) {
  if (saveInterval) clearInterval(saveInterval);
  saveInterval = setInterval(saveDb, intervalMs);
}

module.exports = { getDb, initDatabase, saveDb, closeDb, startAutoSave };
