const express = require("express");
const router = express.Router();

// Use the MySQL pool in the tasks route
module.exports = (pool) => {
  router.post("/", async (req, res) => {
    try {
      const [results] = await pool.execute(
        "INSERT INTO tasks (task, completed) VALUES (?, ?)",
        [req.body.task, req.body.completed || false]
      );

      const insertedTaskId = results.insertId;

      const [newTask] = await pool.execute("SELECT * FROM tasks WHERE id = ?", [
        insertedTaskId,
      ]);

      res.json({ ...newTask[0], _id: newTask[0].id });
    } catch (error) {
      console.error(error);
      res.status(500).send("Internal Server Error");
    }
  });

  router.get("/", async (req, res) => {
    try {
      const [tasks] = await pool.execute("SELECT * FROM tasks");
      res.json(tasks.map((task) => ({ ...task, _id: task.id })));
    } catch (error) {
      console.error(error);
      res.status(500).send("Internal Server Error");
    }
  });

  router.put("/:id", async (req, res) => {
    try {
    
      const taskId = req.params.id;
      const { task, completed } = req.body;
      console.log(taskId, task, completed);
      await pool.execute(
        "UPDATE tasks SET task = ?, completed = ? WHERE id = ?",
        [task, completed, taskId]
      );

      const [updatedTask] = await pool.execute(
        "SELECT * FROM tasks WHERE id = ?",
        [taskId]
      );

      res.json({ ...updatedTask[0], _id: updatedTask[0].id });
    } catch (error) {
      console.error(error);
      res.status(500).send("Internal Server Error");
    }
  });

  router.delete("/:id", async (req, res) => {
    try {
      const taskId = req.params.id;

      const [deletedTask] = await pool.execute(
        "SELECT * FROM tasks WHERE id = ?",
        [taskId]
      );

      await pool.execute("DELETE FROM tasks WHERE id = ?", [taskId]);

      res.json({ ...deletedTask[0], _id: deletedTask[0].id });
    } catch (error) {
      console.error(error);
      res.status(500).send("Internal Server Error");
    }
  });

  return router;
};
