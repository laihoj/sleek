var mongoose = require("mongoose");

var datapointSchema =  mongoose.Schema({
	device_address: String,
	timestamp: Date,
	data: String
});


module.exports = mongoose.model("Datapoint", datapointSchema);