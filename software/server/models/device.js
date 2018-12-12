var mongoose = require("mongoose");

var deviceSchema =  mongoose.Schema({
	label: String,
	address: String,
	uuid: String,
	name: String,
	user: String
});


module.exports = mongoose.model("Device", deviceSchema);