// src/routes/user.routes.js
const express = require('express');
const router = express.Router();
const userController = require('../modules/user/controller/user_controller');

router.post('/', (req, res, next) => userController.create(req, res, next));
router.get('/', (req, res, next) => userController.getAll(req, res, next));
router.get('/:id', (req, res, next) => userController.getById(req, res, next));
router.patch('/:id', (req, res, next) => userController.update(req, res, next));
router.delete('/:id', (req, res, next) => userController.delete(req, res, next));

module.exports = router;