import fs from "node:fs/promises";
import { Client } from "pg";
import { loadEnvFile } from "node:process";

loadEnvFile(".env");

const file = process.argv[2];
if (!file)
  throw new Error("usage: node database/scripts/migrate.ts <filename.sql>");

const client = new Client({
  connectionString: process.env.MIGRATION_DATABASE_URL,
});

let isSuccess = false;
try {
  console.log("✅ starting migration on:", file);
  await client.connect();
  console.log("✅ connected to db");
  console.log("✅ Beggining transaction");
  await client.query("BEGIN");
  console.log("✅ set local role");
  await client.query("SET LOCAL ROLE skyops_owner");
  console.log("✅ reading file");
  await client.query(await fs.readFile(file, "utf-8"));
  await client.query("COMMIT");
  console.log("✅ applied ", file);
  isSuccess = true;
} catch (error) {
  try {
    await client.query("ROLLBACK");
  } catch (err) {
    console.error(`ROLLBACK ON`, err);
    process.exitCode = 1;
  }
  console.error(`failed ${file}`, error);
  process.exitCode = 1;
} finally {
  await client.end();
}

if (isSuccess) {
  try {
    await fs.writeFile(
      "database/migration-logs.txt",
      `[${new Date().toISOString()}]: ${file} migration applied successfully\n`,
      { flag: "a+" },
    );
  } catch (err) {
    console.error("error while writing to logs", err);
  }
}
