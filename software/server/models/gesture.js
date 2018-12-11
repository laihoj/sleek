var mongoose = require("mongoose");

var gestureSchema =  mongoose.Schema({
	start_timestamp: Date,
	end_timestamp: Date,
	label: String,
	user: String
});


module.exports = mongoose.model("Gesture", gestureSchema);