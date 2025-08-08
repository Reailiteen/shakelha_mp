const mongoose = require("mongoose");

const letterSchema = new mongoose.Schema({
  letter: {
    type: String,
    required: true
  },
  points: {
    type: Number,
    required: true
  },
  count: {
    type: Number,
    default: 1
  },
  isNew: {
    type: Boolean,
    default: true
  },
});

module.exports = letterSchema;
