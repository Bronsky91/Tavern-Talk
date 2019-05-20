const mongoose = require('mongoose');

const userModel = mongoose.Schema({
    username: { type: String },
    email: { type: String },
    password: { type: String },
    characters: [{
        name : String,
        gender: String,
    }],
});

var User = module.exports = mongoose.model('user', userModel);

module.exports.get = function (callback, limit) {
    User.find(callback).limit(limit);
}