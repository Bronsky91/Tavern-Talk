const express = require('express')
const router = express.Router();
const tavernController = require('../controllers/tavernController');

router.route('/')
    .get((req, res) => {
        res.json({
            status: 'API is working',
            message: "Greetings to the Tavern, friend!"
        })
    });

router.route('/taverns')
    .get(tavernController.index)
    .post(tavernController.new)

router.route('/enter')    
    .post(tavernController.enter)

router.route('/:tavern_id/tables')
    .get(tavernController.tables)
    .post(tavernController.join)

router.route('/:tavern_id/character_remove')
    .patch(tavernController.characterRemove)

router.route('/:tavern_id/board')
    .get(tavernController.getBoard)
    .patch(tavernController.updatePost)

router.route('/:tavern_id')
    .get(tavernController.view)
    .patch(tavernController.update)
    .put(tavernController.update)
    .delete(tavernController.delete);
    

// Export API routes
module.exports = router;