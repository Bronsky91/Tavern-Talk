Tavern = require("../models/tavernModel");
const cmd = require("node-cmd");
const { spawnSync } = require('child_process');

const PORTS = [3000, 3001, 3002, 3003];
const IP_ADDRESSSES = ["178.128.184.201"];

// var godot_servers = {};

function checkPorts(arr) {
  return PORTS.filter(p => !arr.includes(p));
}

function makeCode() {
  var text = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  for (var i = 0; i < 5; i++)
    text += possible.charAt(Math.floor(Math.random() * possible.length));

  return text
}

// Handle index actions
exports.index = function (req, res) {
  Tavern.get(function (err, taverns) {
    if (err) {
      res.json({
        status: "error",
        message: err
      });
    }
    res.json({
      status: "success",
      data: taverns
    });
  });
};

// Handle user entering tavern
exports.enter = function (req, res) {
  Tavern.findOne({ code: req.body.code }, function (err, tavern) {
    if (err) return (err);
    if (!tavern || !req.body.user_id) 
      return res.sendStatus(401);
    else {
      tavern.characters.push({
        user_id: req.body.user_id,
        character_id: req.body.character_id
      })
    }
    // save the tavern update and check for errors
    tavern.save(function (err) {
      if (err) res.json(err);
      res.json({
        data: tavern
      });
    });
  });
};

var exec = require('child_process').exec;
function execute(command, callback) {
  exec(command, function (error, stdout, stderr) { callback(stdout); });
};

// Handle spinning up Godot server
exports.spin = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) return (err);
    if (!tavern) return res.sendStatus(401);
    else {
      execute("lsof -i :" + tavern.port, function (port) {
        var realPort;
        if (port.split(' ')[21] == 'bronsky')
          realPort = port.split(' ')[20];
        else
          realPort = port.split(' ')[21];
        if (realPort == undefined) {
          cmd.run(
            "godot --path ../Tavern-Server/ -d ---" + tavern.port +" ---"+ tavern._id
          );
          return res.json({
            data: 'Server Starting'
          });
        } else {
          return res.json({
            data: 'Server Up'
          })
        }
      })
    }
  });
};

// Handle kill tavern godot server
exports.kill = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) res.sendStatus(404)
    else {
      execute("lsof -i :" + tavern.port, function (port) {
        var realPort;
        if (port.split(' ')[21] == 'bronsky')
          realPort = port.split(' ')[20]
        else
          realPort = port.split(' ')[21]
        if (realPort != undefined) {
          cmd.run("kill " + realPort)
          res.json({
            data: "Sever going down"
          });
        } else {
          res.json({
            data: "Server not up"
          });
        }
      })

    }
  })
};

// Does the tavern exist with the given code
exports.check = function (req, res) {
  Tavern.findOne({ code: req.body.code }, function (err, tavern) {
    if (err) return next(err);
    if (!tavern) return res.sendStatus(404);
    else {
      return res.json({
        data: tavern
      });
    }
  });
};


// Handle create tavern actions
exports.new = function (req, res) {
  var unavailPorts = [];
  Tavern.get(function (err, taverns) {
    taverns.forEach(function (t) {
      if (t.port) unavailPorts.push(t.port);
    });
    var availPorts = checkPorts(unavailPorts);
    if (availPorts.length == 0) res.json({ data: "No available ports" });
    else {
      var tavern = new Tavern();
      tavern.name = req.body.name;
      tavern.characters.push(req.body.character);
      tavern.code = makeCode(); // TODO: Run Check to make sure Code is not used yet
      tavern.ip = IP_ADDRESSSES[0];
      tavern.port = availPorts[0];
      // save the tavern and check for errors
      tavern.save(function (err) {
        // if (err)
        //     res.json(err);
        res.json({ data: tavern });
      });
    }
  });
};

// Handle view tavern info
exports.view = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) res.sendStatus(404)
    res.json({
      data: tavern
    });
  });
};

// Handle update tavern info
exports.update = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) res.send(err);
    tavern.name = req.body.name ? req.body.name : tavern.name;
    //tavern.characters.equal(req.body.characters)
    // ? tavern.characters.push(req.body.characters)
    //: tavern.characters;
    req.body.board ? tavern.board.push(req.body.board) : tavern.board
    // API should probably update the port and IP directly..
    tavern.port = req.body.port ? req.body.port : tavern.port;
    tavern.ip = req.body.ip ? req.body.ip : tavern.ip;
    // save the tavern and check for errors
    tavern.save(function (err) {
      if (err) res.json(err);
      else
        res.json({
          data: tavern
        });
    });
  });
};

exports.getBoard = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) {
      res.json({
        status: "error",
        message: err
      });
    } else {
      res.json({
        data: tavern.board
      })
    }
  })
}

exports.updatePost = function (req, res) {
  Tavern.update({ "_id": req.params.tavern_id, "board._id": req.body.id }, {
    $set: {
      "board.$.body": req.body.body,
      "board.$.author": req.body.author
    }
  }, (err, doc) => {
    if (err) {
      res.json(err);
      return;
    }
    if (doc) {
      res.json(doc);
      return;
    }
  })
}

// Handle removing post from board
exports.removePost = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    tavern.board.pull(req.body); // req.body == {_id: post.id}._id
    // save the contact and check for errors
    tavern.save(function (err) {
      if (err) res.json(err);
      res.json({
        data: tavern.board
      });
    });
  });
};

// Handle removing characters from user profile
exports.characterRemove = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) res.send(err);
    req.body.forEach(c => {
      tavern.characters.pull(c);
    })
     // req.body == tavern._id
    // save the contact and check for errors
    tavern.save(function (err) {
      if (err) res.json(err);
      res.json({
        data: tavern
      });
    });
  });
};

// Handle delete contact
exports.delete = function (req, res) {
  Tavern.deleteOne(
    {
      _id: req.params.tavern_id
    },
    function (err, tavern) {
      if (err) res.send(err);
      res.json({
        data: "Tavern demolished"
      });
    }
  );
};
