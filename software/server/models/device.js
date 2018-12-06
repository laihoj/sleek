var mongoose = require("mongoose");

var deviceSchema =  mongoose.Schema({
	address: String,
	uuid: String,
	name: String,
	user: String
});


module.exports = mongoose.model("Device", deviceSchema);