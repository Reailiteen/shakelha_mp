const mongoose = require("mongoose");
const letterSchema = require("./letter");

const letterDistributionSchema = new mongoose.Schema({
  letters: [letterSchema]
});

module.exports = letterDistributionSchema;
