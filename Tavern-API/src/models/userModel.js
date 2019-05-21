const mongoose = require('mongoose');

const userModel = mongoose.Schema({
    username: { type: String },
    email: { type: String },
    password: { type: String },
    characters: [{
        name : String,
        gender: String,
        stats: {
            strength: {type: Number},
            dex: {type: Number},
            con: {type: Number},
            wis: {type: Number},
            cha: {type: Number}
        },
    }],
});

var User = module.exports = mongoose.model('user', userModel);

module.exports.get = function (callback, limit) {
    User.find(callback).limit(limit);
}