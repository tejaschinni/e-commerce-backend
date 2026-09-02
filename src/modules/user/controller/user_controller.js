// src/controllers/user.controller.js
const { logger } = require('sequelize/lib/utils/logger');
const userService = require('../service/user_service');

class UserController {
  async create(req, res, next) {
    try {
        console.log("user create controller ");
      const user = await userService.createUser(req.body);
      res.status(201).json({ success: true, data: user });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const user = await userService.getUserById(req.params.id);
      res.status(200).json({ success: true, data: user });
    } catch (err) {
      next(err);
    }
  }

  async getAll(req, res, next) {
    try {
      const result = await userService.listUsers(req.query);
      res.status(200).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  }

  async update(req, res, next) {
    try {
      const user = await userService.updateUser(req.params.id, req.body);
      res.status(200).json({ success: true, data: user });
    } catch (err) {
      next(err);
    }
  }

  async delete(req, res, next) {
    try {
      await userService.deleteUser(req.params.id);
      res.status(204).send();
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new UserController();