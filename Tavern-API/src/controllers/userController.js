User = require('../models/userModel');

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
    User.findOne({ username: req.body.username, password: req.body.password }, function (err, user) {
        if (err) return next(err);
        if (!user) return res.sendStatus(401)

        return res.json({
            id: user._id
        });
    });
};

// Handle create user actions
exports.new = function (req, res) {
    var user = new User();
    user.username = req.body.username ? req.body.username : user.username;
    user.characters = req.body.characters;
    user.email = req.body.email;
    user.password = req.body.password;
    // save the user and check for errors
    user.save(function (err) {
        // if (err)
        //     res.json(err);
        res.json({
            id: user._id
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

// Handle update contact info
exports.update = function (req, res) {
    User.findById(req.params.user_id, function (err, user) {
        if (err)
            res.send(err);
        user.username = req.body.username ? req.body.username : user.username;
        req.body.characters ? user.characters.push(req.body.characters) : user.characters;
        user.email = req.body.email ? req.body.email : user.email;
        user.password = req.body.password ? req.body.password : user.password;
        // save the contact and check for errors
        user.save(function (err) {
            if (err)
                res.json(err);
            res.json({
                data: user
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
        /*
        user.characters = user.characters.filter(c => {
            !c._id.equals(req.body.characters._id)
        })
        */
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