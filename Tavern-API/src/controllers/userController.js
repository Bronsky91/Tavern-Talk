const User = require('../models/userModel');
const bcrypt = require('bcryptjs')

// Handle index actions
exports.index = function (req, res) {
    User.get(function (err, users) {
        if (err) {
            res.json({
                status: "error",
                message: err,
            });
        }
        res.json({
            status: "success",
            data: users
        });
    });
};

// Handle user login
exports.login = function (req, res) {
    User.findOne({ username: req.body.username},
         function (err, user) {
            if(!user) {
                return res.status(401).send({ message: "The username does not exist" });
            }
            if(!bcrypt.compareSync(req.body.password, user.passwordHash)) {
                return res.status(401).send({ message: "The password is invalid" });
            }
            res.json(user);
    });
};

// Handle create user actions
exports.new = function (req, res) {
    var user = new User();
    user.username = req.body.username;
    user.email = req.body.email;
    user.passwordHash = bcrypt.hashSync(req.body.password, 10);
    // save the user and check for errors
    user.save(function (err) {
        //if (err)
          //  res.sendStatus(500);
        res.json({
            data: user
        });
    });
};

// Handle view user info
exports.view = function (req, res) {
    User.findById(req.params.user_id, function (err, user) {
        if (err)
            res.send(err);
        res.json({
            data: user
        });
    });
};

// Handle user update 
exports.update = function (req, res) {
    User.findById(req.params.user_id, function (err, user) {
        if (err)
            res.send(err);
        user.username = req.body.username ? req.body.username : user.username;
        // Only adds characters right now
        req.body.characters ? user.characters.push(req.body.characters) : user.characters;
        // ------------------------------
        user.email = req.body.email ? req.body.email : user.email;
        user.password = req.body.password ? req.body.password : user.password;
        // save the user and check for errors
        user.save(function (err) {
            if (err)
                res.json(err);
            res.json({
                data: user
            });
        });
    });
};

exports.getInventory = function (req, res) {
    User.findById(req.params.user_id, function (err, user) {
        if (err)
            res.send(err);
        let inventory = {};
        for(let character of user.characters){
            if(character._id == req.params.character_id){
                // If there's no gold then it's zero
                character.inventory.gold = character.inventory.gold ? character.inventory.gold : 0;
                inventory = character.inventory;
            }
        }
        res.json({
            data: inventory
        });
    });
};

exports.updateInventory = function (req, res) {
    User.findById(req.params.user_id, function (err, user) {
        if (err)
            res.send(err);
        let msg = 'Could not find character';
        let updatedInventory = {};
        for(let character of user.characters){
            if(character._id == req.params.character_id){
                // If there's no gold then it's zero, ya poor
                character.inventory.gold = character.inventory.gold ? character.inventory.gold : 0;
                if (req.body.gold){
                    if (req.body.gold != character.inventory.gold){
                        character.inventory.gold = character.inventory.gold + req.body.gold;
                    }
                }
                character.inventory.items = req.body.items ? req.body.items : character.inventory.items;
                updatedInventory = character.inventory;
                msg = 'Inventory updated';
            }
        }
        user.save(function (err) {
            if (err)
                res.json(err);
            res.json({
                msg: msg,
                inventory: updatedInventory
            });
        });
    });
};

// Handle removing characters from user profile
exports.characterRemove = function (req, res) {
    User.findById(req.params.user_id, function (err, user) {
        if (err)
            res.send(err);
        user.characters.pull(req.body)
        // save the contact and check for errors
        user.save(function (err) {
            if (err) res.json(err);
        res.sendStatus(404);
        });
    });
};

// Handle removing taerns from user profile
exports.removeTavern = function (req, res) {
    User.findById(req.params.user_id, function (err, user) {
        if (err)
            res.send(err);
        user.taverns.pull(req.body)
        // save the contact and check for errors
        user.save(function (err) {
            if (err) res.json(err);
            res.sendStatus(404);
        });
    });
};

exports.addTavern = function (req, res) {
    User.findById(req.params.user_id, function (err, user){
        if (err)
            res.send(err);
        user.taverns.push(req.body)
        user.save(function (err){
            if (err) res.json(err);
            res.sendStatus(200)
        })
    })
};

exports.viewTaverns = function (req, res){
    User.findById(req.params.user_id, function(err, user){
        if (err)
            res.send(err);
        res.json({
            data: user.taverns
        });
    })
}

// Handle delete user
exports.delete = function (req, res) {
    User.deleteOne({
        _id: req.params.user_id
    }, function (err, user) {
        if (err)
            res.send(err);
        res.json({
            data: 'User deleted'
        });
    });
};