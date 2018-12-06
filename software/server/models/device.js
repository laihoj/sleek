var mongoose = require("mongoose");

var deviceSchema =  mongoose.Schema({
	address: String,
	UUID: String,
	name: String,
	user: String
});


module.exports = mongoose.model("Device", deviceSchema);