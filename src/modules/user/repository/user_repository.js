const User = require("../../../models/user");
const {Op, where} = require('sequelize');

class UserRespository{
    /// User creation
    async create(userData, transaction = null){
        console.log("user respository");
        return await User.create(userData,{transaction})
    }


    /// find by id
    async findById(id){
        return await User.findByPk(id);
    }


    async findByEmail(email){
        return await User.findOne({where:{email}});
    }

    async findByPhone(phone){
        return await User.findOne({where:{phone}});
    }

    async findAll({limit = 10, offset = 0, role, status}){
        const where  = {};
        if(role) where.role = role;
        if(status) where.status = status;

        return await User.findAndCountAll({
            where,
            limit,
            offset,
            order:[['created_at','DESC']],
        });
    }

    async updateById(id, updateData){
        const user = await User.findByPk(id);
        if(!user) return null;
        return await User.update(updateData);
    }

    async softDelete(id){
        const user = await User.findByPk(id);
        if(!user) return null;
         await user.destroy();
         return true;
    }
}

module.exports = new UserRespository();

