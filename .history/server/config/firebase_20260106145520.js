import admin from "firebase-admin";
import { createRequire } from "module";

const require = createRequire(import.meta.url);
// 👇 Đảm bảo file json chìa khóa của bạn nằm đúng chỗ này
const serviceAccount = require("../serviceAccountKey.json"); 

// 👇 Thay dòng dưới bằng "Bucket URL" của bạn (Xem hướng dẫn bên dưới code)
const BUCKET_NAME = "mini-instagram-xxxxx.firebasestorage.app"; 

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: BUCKET_NAME
});

const bucket = admin.storage().bucket();

export default bucket;