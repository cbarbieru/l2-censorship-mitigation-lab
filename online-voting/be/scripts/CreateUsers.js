const db = require("../app/models");
const { user: User, role: Role } = db;
const citiesByRegion = require('./orase-dupa-judet.min.json');
const randomString = require("randomstring");
const randomEmail = require("random-email");
const mongoose = require("mongoose");
const { uniqueNamesGenerator, starWars, Config } = require("unique-names-generator");
const fs = require('fs');
const { ethers } = require('ethers');

const bcrypt = require("bcryptjs");

const regions = Object.keys(citiesByRegion);
const noOfRegions = regions.length;

const dbConfig = require("../app/config/db.config");

var usersInDb = "";
var users = "";
var usersNoHash = "";

db.mongoose
    .connect(dbConfig.URI)
    .then(() => {
        console.log("Successfully connect to MongoDB.");
    })
    .catch(err => {
        console.error("Connection error", err);
        process.exit();
    });

const candidates = ['65f472ebf3059af2327c3b70', '65f473f6f3059af2327c3b77', '6606c8c154ab41105a49bf85', '6606ca8a54ab41105a49bf88', '6606cb8254ab41105a49bf89',
    '6606cc6054ab41105a49bf8a', '6606cd9454ab41105a49bf8b', '6606cf1954ab41105a49bf8c', '6606d1f654ab41105a49bf8d'];
const electionId = '65f5c57b1e3a3e801733b338';
const salt = 'H0wcS6£.4N';

const randomNumber = function (minimum, maximum) {
    return Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
}

const writeToFile = function (input, provider, nrUsers) {

    let filePath = '/data/' + provider + '-users-' + nrUsers.toString() + '.csv';

    fs.appendFile(filePath, input, err => {
        if (err) {
            console.error("error writing to file" + err);
        }
    });
}

const writeToFileNoHash = function (input, provider, nrUsers) {

    let filePath = '/data/' + provider + '-no-hash' + '-users-' + nrUsers.toString() + '.csv';

    fs.appendFile(filePath, input, err => {
        if (err) {
            console.error("error writing to file" + err);
        }
    });
}

const generateUser = async function (role) {
    var pin = randomString.generate({
        charset: ['numeric'],
        length: 12
    });

    var password = randomString.generate({
        charset: ['numeric', '!', 'abcd'],
        length: 10
    });

    var name = uniqueNamesGenerator({
        dictionaries: [starWars],
        length: 1,
    });

    var email = randomEmail();
    var regionIndex = randomNumber(0, noOfRegions - 1);
    var region = regions[regionIndex];
    var cityIndex = randomNumber(0, citiesByRegion[region].length - 1);
    var city = citiesByRegion[region][cityIndex];

    const user = new User({
        personalIdentificationNumber: pin,
        password: bcrypt.hashSync(password, 8),
        name: name,
        email: email,
        region: region,
        city: city
    });

    usersInDb += name;
    usersInDb += ";"
    usersInDb += pin;
    usersInDb += ";"
    usersInDb += password;

    user.roles = [role._id];
    var newUser = await user.save();

    usersInDb += ";"
    usersInDb += newUser._id;
    usersInDb += "\n";

    return { id: newUser._id, pin: pin, password: password };
}

const generateHashes = async function (isLast, role) {
    const candidateId = candidates[randomNumber(0, 8)];
    var user = await generateUser(role);
    //const userId = new mongoose.Types.ObjectId();

    usersNoHash += "User id: "
    usersNoHash += user.id.toString();
    usersNoHash += ";";
    usersNoHash += "Pin: ";
    usersNoHash += user.pin;
    usersNoHash += ";";
    usersNoHash += "Pass: ";
    usersNoHash += user.password;
    usersNoHash += ";";
    usersNoHash += "Election id: "
    usersNoHash += electionId;
    usersNoHash += ";";
    usersNoHash += "Candidate id: ";
    usersNoHash += candidateId;
    usersNoHash += ";";
    usersNoHash += "Salt: ";
    usersNoHash += salt;
    usersNoHash += ";";


    const userElHash = ethers.solidityPackedKeccak256(['string'], [user.id + electionId]);
    const candidateHash = ethers.solidityPackedKeccak256(['string', 'string'], [candidateId, salt]);

    usersNoHash += "UserElHash: "
    usersNoHash += userElHash;
    usersNoHash += ";";
    usersNoHash += "Candidate hash: ";
    usersNoHash += candidateHash;

    if (!isLast) {
        usersNoHash += "\n";
    }

    users += userElHash;
    users += ";";
    users += candidateHash;
    // users += "\n";
    if (!isLast) {
        users += "\n";
    }
}

const generateUsers = async function (noOfUsers) {

    const role = await Role.findOne({ name: "user" });

    for (var i = 0; i < noOfUsers; i++) {
        // await generateUser(role);
        await generateHashes(i == noOfUsers - 1, role);
        //await generateHashes(2);
    }

    var providers = ['playground'];

    writeToFile(users, providers[0], noOfUsers);
    writeToFileNoHash(usersNoHash, providers[0], noOfUsers);
}

generateUsers(100001);

const generateAdmin= async function(){
    const adminRole = await Role.findOne({ name: "admin" });

    var pin = "user-novotepin";
    var password = "snitel123";
    var name ="user-novotepin";
    var email = "usernovote@onlinevoting.com";   
    var region = "-";    
    var city = "-";

    const user = new User({
        personalIdentificationNumber: pin,
        password: bcrypt.hashSync(password, 8),
        name: name,
        email: email,
        region: region,
        city: city
    });

    usersInDb += name;
    usersInDb += ";"
    usersInDb += pin;
    usersInDb += ";"
    usersInDb += password;

    user.roles = [adminRole._id];
    var newUser = await user.save();
}

generateAdmin();