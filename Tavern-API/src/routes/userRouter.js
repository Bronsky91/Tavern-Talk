const express = require('express')
const router = express.Router();
const userController = require('../controllers/userController');

router.route('/')
    .get((req, res) => {
        res.json({
            status: 'API is working',
            message: "Greetings to the Tavern, friend!"
        })
    });

router.route('/users')
    .get(userController.index)
    .post(userController.new)

router.route('/login')    
    .post(userController.login)

router.route('/users/:user_id/character_remove')
    .patch(userController.characterRemove)

router.route('/users/:user_id')
    .get(userController.view)
    .patch(userController.update)
    .put(userController.update)
    .delete(userController.delete);
    

// Export API routes
module.exports = router;