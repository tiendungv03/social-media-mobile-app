import mongoose from "mongoose";
let mongodInstance = null;

const startInMemoryMongo = async () => {
  try {
    const { MongoMemoryServer } = await import("mongodb-memory-server");
    const mongod = await MongoMemoryServer.create();
    mongodInstance = mongod;
    const uri = mongod.getUri();
    await mongoose.connect(uri);
    console.log("Connected to in-memory MongoDB");
  } catch (e) {
    console.error("Failed to start in-memory MongoDB:", e);
    throw e;
  }
};

export const connectDB = async () => {
  const uri = process.env.MONGO_URI;
  if (!uri) {
    console.warn("MONGO_URI not set — starting in-memory MongoDB (dev)");
    await startInMemoryMongo();
    return;
  }

  try {
    await mongoose.connect(uri);
    console.log("MongoDB connected");
  } catch (err) {
    console.error("Failed to connect to provided MongoDB URI:", err.message || err);
    if (process.env.NODE_ENV === "production") {
      console.error("Production environment — exiting.");
      process.exit(1);
    }
    console.log("Falling back to in-memory MongoDB for development/testing");
    await startInMemoryMongo();
  }
};

export const stopInMemoryMongo = async () => {
  try {
    if (mongoose.connection) await mongoose.disconnect();
    if (mongodInstance) await mongodInstance.stop();
  } catch (e) {
    console.warn("Error stopping in-memory MongoDB:", e);
  }
};
