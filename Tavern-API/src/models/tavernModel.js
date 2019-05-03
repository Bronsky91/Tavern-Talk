const mongoose = require('mongoose');

const tavernModel = mongoose.Schema({
    name: { type: String },
    code: { type: String },
    ip: {type: String},
    port: { type: Number },
    characters: [{
        user_id: String,
        character_id: String,
        table: Number // 0 means not at a table currently
        }],
});

var Tavern = module.exports = mongoose.model('tavern', tavernModel);

module.exports.get = function (callback, limit) {
    Tavern.find(callback).limit(limit);
}