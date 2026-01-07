import admin from "firebase-admin";
import fs from "fs";

if (!admin.apps.length) {
  const serviceAccountPath = new URL(
    "../serviceAccountKey.json",
    import.meta.url
  );
  const serviceAccount = JSON.parse(
    fs.readFileSync(serviceAccountPath, "utf8")
  );

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

export default admin;
