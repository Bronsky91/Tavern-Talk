const mongoose = require('mongoose');

const userModel = mongoose.Schema({
    username: { type: String, required: true, unique: true },
    passwordHash: { type: String, required: true },
    email: {type: String},
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
        style: {
            skin: {type: Number},
            hair: {type: Number},
            eyes: {type: Number},
            clothes: {type: Number}
        },
        inventory: {
            gold: {type: Number},
            items: [{
                name: String,
                about: String,
                worth: Number,
                icon: String,
                texture: String,
                clothing: Boolean
            }]
        }
    }],
    taverns: [{
        name: String,
        code: String
    }]
});

    
var User = module.exports = mongoose.model('user', userModel);

module.exports.get = function (callback, limit) {
    User.find(callback).limit(limit);
}