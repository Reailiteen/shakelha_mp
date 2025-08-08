const mongoose = require("mongoose");
const letterSchema = require("./letter");

const boardSchema = new mongoose.Schema({
  boardSize: {
    type: Number,
    default: 15
  },
  board: {
    type: [[letterSchema]],
    default: () => Array(15).fill().map(() => Array(15).fill({ letter: null })),
  }
});

module.exports = boardSchema;
