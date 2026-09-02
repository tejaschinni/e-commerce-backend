const bcrypt = require("bcrypt");
const userRespository = require("../repository/user_repository");

class UserService{
    async createUser(data){
        console.log("in user service ");
        const existingEmail = await userRespository.findByEmail(data.email.toLowerCase().trim());
      if (existingEmail) {
      const error = new Error('Email is already registered');
      error.statusCode = 409;
      throw error;
    }

    if (data.phone) {
      const existingPhone = await userRespository.findByPhone(data.phone);
      if (existingPhone) {
        const error = new Error('Phone number is already registered');
        error.statusCode = 409;
        throw error;
      }
    }
    const saltRound = 12;
    const passwordHash = await bcrypt.hash(data.password, saltRound);
    return await userRespository.create({
      email: data.email.toLowerCase().trim(),
      phone: data.phone || null,
      passwordHash,
      firstName: data.firstName,
      lastName: data.lastName,
      role: data.role || 'customer',
      preferences: data.preferences,
    });
    }

    async getUserById(id) {
    const user = await userRespository.findById(id);
    if (!user) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }
    return user;
  }

  async listUsers({ page = 1, limit = 10, role, status }) {
    const parsedLimit = Math.min(Math.max(parseInt(limit, 10) || 10, 1), 100);
    const parsedPage = Math.max(parseInt(page, 10) || 1, 1);
    const offset = (parsedPage - 1) * parsedLimit;

    const { count, rows } = await userRespository.findAll({
      limit: parsedLimit,
      offset,
      role,
      status,
    });

    return {
      total: count,
      page: parsedPage,
      totalPages: Math.ceil(count / parsedLimit),
      users: rows,
    };
  }

  async updateUser(id, updateData) {
    // Prevent updating protected fields directly via generic update
    delete updateData.password;
    delete updateData.passwordHash;
    delete updateData.email;

    const updatedUser = await userRespository.update(id, updateData);
    if (!updatedUser) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }
    return updatedUser;
  }

  async deleteUser(id) {
    const deleted = await userRespository.softDelete(id);
    if (!deleted) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }
    return true;
  }

}

module.exports = new UserService();