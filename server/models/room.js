const mongoose = require("mongoose");
const playerSchema = require("./player");
const boardSchema = require("./board");
const letterDistributionSchema = require("./letterDistribution");

const roomSchema = new mongoose.Schema({
  occupancy: {
    type: Number,
    default: 2
  },
  maxRounds: {
    type: Number,
    default: 6
  },
  currentRound: {
    type: Number,
    required: true,
    default: 1
  },
  players: [playerSchema],
  isJoin: {
    type: Boolean,
    default: true
  },
  turn: playerSchema,
  turnIndex: {
    type: Number,
    default: 0
  },
  letterDistribution: letterDistributionSchema,
  board: boardSchema
});

const roomModel = mongoose.model("Room", roomSchema);
module.exports = roomModel;
