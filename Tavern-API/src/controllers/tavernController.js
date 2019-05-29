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
    if (!tavern) return res.sendStatus(401);
    return res.json({
      data: tavern
    });
  });
};

var exec = require('child_process').exec;
function execute(command, callback) {
  exec(command, function (error, stdout, stderr) { callback(stdout); });
};

exports.spin = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) return (err);
    if (!tavern) return res.sendStatus(401);
    else {
      execute("lsof -i :" + tavern.port, function (port) {
        console.log(port.split(' ')[21])
        if (port.split(' ')[21] == undefined) {
          cmd.run(
            "godot --path ../Tavern-Server/ -d ---" + tavern.port
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
      /*
      // spin up godot server using tavern port
      if (godot_servers[tavern.id] == undefined) {
        let godot_tavern = cmd.run(
          "godot --path ../Tavern-Server/ -d ---" + tavern.port
        );
        //let godot_tavern = spawn('godot', ['-d', '---' + tavern.port]);
        godot_servers[tavern.id] = godot_tavern.pid
        //console.log(godot_servers[tavern.id])
        return res.json({
          data: 'Server Starting'
        });
     */
    }
  });
};

// Handle kill tavern godot server
exports.kill = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) res.sendStatus(404)
    else {
      execute("lsof -i :" + tavern.port, function (port) {
        console.log(port.split(' ')[21])
        if (port.split(' ')[21] != undefined) {
          //console.log(godot_servers)
          //cmd.run("kill " + godot_servers[tavern.id])

          cmd.run("kill " + port.split(' ')[21])

          //godot_servers[tavern.id].kill()
          //delete godot_servers[tavern.id]
          //console.log(godot_servers)
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

// Handle user entering tavern
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

exports.tables = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) {
      res.json({
        status: "error",
        message: err
      });
    } else {
      // Array of table objects
      // Table objects have character arrays for each character at table
      // for now 4 tables is max amount hard coded in
      // Tavern object should dictate how many slots it has
      var tableStats = {
        1: 0,
        2: 0,
        3: 0,
        4: 0
      };
      tavern.characters.forEach(function (c) {
        // For each character check if they're at a table
        if (c.table > 0) {
          // Increment the table count by 1 for character at a table
          tableStats[c.table]++
        }
      });
      res.json({
        data: tableStats
      })
    }
  })
}

exports.join = function (req, res) {
  Tavern.findById(req.params.tavern_id, function (err, tavern) {
    if (err) {
      res.json({
        status: "error",
        message: err
      });
    } else {
      tavern.characters.push({
        username: req.body.username,
        character_id: req.body.character_id,
        table: req.body.table
      })
    }
  })
}

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
    tavern.characters.pull(req.body); // req.body == tavern._id
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
