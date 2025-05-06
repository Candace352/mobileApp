// ============================
// Firebase Cloud Functions Backend (index.js)
// ============================

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

admin.initializeApp();
const db = admin.firestore();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// POST /registerUser
app.post("/registerUser", async (req, res) => {
    const { fullName, email, password } = req.body;

    if (!fullName || !email || !password) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    try {
      // Step 1: Register the user
      const userRecord = await admin.auth().createUser({
        email,
        password,
        displayName: fullName,
      });

      // Step 2: Save user details to Firestore
      await db.collection("users").doc(userRecord.uid).set({
        uid: userRecord.uid,
        fullName,
        email,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Return success response
      return res.status(201).json({
        message: "User registered successfully",
        uid: userRecord.uid,
      });
    } catch (error) {
      console.error("Registration error:", error);
      return res.status(500).json({ error: error.message });
    }
  });

// GET /user/profile (no authentication needed)
app.get("/user/profile", async (req, res) => {
  const uid = req.user?.uid;

  try {
    const userDoc = await db.collection("users").doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" });
    }

    const userData = userDoc.data();
    return res.status(200).json({
      name: userData.fullName,
      email: userData.email,
    });
  } catch (error) {
    console.error("Error fetching user profile:", error);
    return res.status(500).json({ error: "Failed to load user profile" });
  }
});

// Jobs CRUD Operations
// GET /jobs - No authentication needed
app.get("/jobs", async (req, res) => {
    try {
      const snapshot = await db.collection("jobs")
        .orderBy("createdAt", "desc")
        .get();
      const jobs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      res.status(200).json(jobs);
    } catch (error) {
      console.error("Error fetching jobs:", error);
      res.status(500).send("Internal Server Error");
    }
  });

// POST /jobs - No authentication needed
app.post("/jobs", async (req, res) => {
    const job = req.body;

    if (!job.title || !job.company || !job.description) {
        return res.status(400).json({ error: "Missing required fields" });
    }

    try {
        const docRef = await db.collection("jobs").add({
            ...job,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        res.status(201).json({ id: docRef.id, ...job });
    } catch (err) {
        console.error("Error posting job:", err);
        res.status(500).json({ error: "Failed to post job" });
    }
});

// PUT /jobs/:id - No authentication needed
app.put("/jobs/:id", async (req, res) => {
    const { id } = req.params;
    const updates = req.body;

    try {
        await db.collection("jobs").doc(id).update(updates);
        res.status(200).json({ message: "Job updated successfully" });
    } catch (err) {
        console.error("Error updating job:", err);
        res.status(500).json({ error: "Failed to update job" });
    }
});

// DELETE /jobs/:id - No authentication needed
app.delete("/jobs/:id", async (req, res) => {
    const { id } = req.params;

    try {
        await db.collection("jobs").doc(id).delete();
        res.status(200).json({ message: "Job deleted successfully" });
    } catch (err) {
        console.error("Error deleting job:", err);
        res.status(500).json({ error: "Failed to delete job" });
    }
});

app.use((error, req, res) => {
    console.error("Server Error:", error);
    res.status(500).json({ 
      error: "Internal Server Error",
      message: error.message 
    });
});

// Export the API
exports.api = functions.https.onRequest(app);
