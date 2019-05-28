const express = require('express');
const userRoutes = require("./routes/userRouter");
const tavernRoutes = require("./routes/tavernRoutes");
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const https = require('https');
const fs = require('fs');
const basicAuth = require('express-basic-auth')

const app = express();
const port = process.env.PORT || 8080;

app.use(basicAuth({
     users: { 'admin': 'strifelord' }
 }))
// Configure bodyparser to handle post requests
app.use(bodyParser.urlencoded({
    extended: true
 }));

app.use(bodyParser.json());

// Connect to Mongoose and set connection variable
mongoose.connect('mongodb://admin:lester1@ds012889.mlab.com:12889/tavern-api');
var db = mongoose.connection;

// Use Api routes in the App
app.use('/api', userRoutes);
app.use('/api/tavern', tavernRoutes);

https.createServer({
     key: fs.readFileSync('./key.pem'),
     cert: fs.readFileSync('./cert.pem'),
     passphrase: 'tipthewench'
 }, app)
 .listen(port, () => {
     console.log("Running RestHub on port " + port);
});