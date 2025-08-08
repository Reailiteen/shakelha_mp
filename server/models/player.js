const mongoose = require("mongoose");
const letterSchema = require("./letter");
const moveSchema = require("./move");

const playerSchema = new mongoose.Schema({
  nickname: {
    type: String,
    trim: true
  },
  socketID: String,
  points: {
    type: Number,
    default: 0
  },
  playerType: {
    type: String,
    required: true
  },
  moves: [moveSchema],
  currentLetters: [letterSchema]
});

module.exports = playerSchema;
