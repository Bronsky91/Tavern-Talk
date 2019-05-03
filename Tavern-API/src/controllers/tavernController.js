Tavern = require("../models/tavernModel");
const cmd = require("node-cmd");

const PORTS = [3000, 3001, 3002, 3003];
const IP_ADDRESSSES = ["127.0.0.1"];

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
exports.index = function(req, res) {
  Tavern.get(function(err, taverns) {
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
exports.enter = function(req, res) {
  Tavern.findOne({ code: req.body.code }, function(err, tavern) {
    if (err) return next(err);
    if (!tavern) return res.sendStatus(401);
    else {
      // spin up godot server using tavern port
     // cmd.run(
        //"godot --path /mnt/c/Users/breed/Documents/MobileGames/Tavern-Talk-Server-v2/ -d ---" +
        //  tavern.port
      //);
      return res.json({
        data: tavern
      });
    }
  });
};

exports.tables = function(req, res){
    Tavern.findById(req.params.tavern_id, function(err, tavern){
        if(err){
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
                if (c.table > 0){
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

exports.join = function(req, res){
    Tavern.findById(req.params.tavern_id, function(err, tavern){
        if(err){
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
exports.new = function(req, res) {
  var unavailPorts = [];
  Tavern.get(function(err, taverns) {
    taverns.forEach(function(t) {
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
      tavern.save(function(err) {
        // if (err)
        //     res.json(err);
        res.json({ data: tavern });
      });
    }
  });
};

// Handle view user info
exports.view = function(req, res) {
  Tavern.findById(req.params.tavern_id, function(err, tavern) {
    if (err) res.send(err);
    res.json({
      data: tavern
    });
  });
};

// Handle update contact info
exports.update = function(req, res) {
  Tavern.findById(req.params.tavern_id, function(err, tavern) {
    if (err) res.send(err);
    else console.log(tavern);
    tavern.name = req.body.name ? req.body.name : tavern.name;
    tavern.characters.equal(req.body.characters)
      ? tavern.characters.push(req.body.characters)
      : tavern.characters;
    // API should probably update the port and IP directly..
    tavern.port = req.body.port ? req.body.port : tavern.port;
    tavern.ip = req.body.ip ? req.body.ip : tavern.ip;
    // save the tavern and check for errors
    tavern.save(function(err) {
      if (err) res.json(err);
      else
        res.json({
          data: tavern
        });
    });
  });
};

// Handle removing characters from user profile
exports.characterRemove = function(req, res) {
  Tavern.findById(req.params.user_id, function(err, tavern) {
    if (err) res.send(err);
    tavern.characters.pull(req.body); // req.body == tavern._id
    // save the contact and check for errors
    tavern.save(function(err) {
      if (err) res.json(err);
      res.json({
        data: tavern
      });
    });
  });
};

// Handle delete contact
exports.delete = function(req, res) {
  Tavern.deleteOne(
    {
      _id: req.params.tavern_id
    },
    function(err, tavern) {
      if (err) res.send(err);
      res.json({
        data: "Tavern demolished"
      });
    }
  );
};
