const sql = require('sql.js');
const fs = require('fs');

async function main() {
  const S = await sql();
  const buffer = fs.readFileSync('data/database.sqlite');
  const d = new S.Database(buffer);
  d.run('UPDATE listings SET avg_rating=0, review_count=0');
  fs.writeFileSync('data/database.sqlite', Buffer.from(d.export()));
  console.log('评价数已清零');
  d.close();
}
main();
