const mongoose = require("mongoose");

const moveSchema = new mongoose.Schema({
  wordsMade: [{
    type: String,
    trim: true,
    default: ""
  }],
  points: {
    type: Number,
    default: 0
  },
  time: {
    type: Date,
    default: Date.now
  },
  letterPositions: [{
    x: { type: Number, required: true },
    y: { type: Number, required: true }
  }]
});

module.exports = moveSchema;
