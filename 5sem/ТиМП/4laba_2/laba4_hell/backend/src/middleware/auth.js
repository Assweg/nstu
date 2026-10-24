const jwt = require('jsonwebtoken');
const { User } = require('../models');

const auth = async (req, res, next) => {
    try {
        // Проверяем заголовок Authorization
        const authHeader = req.header('Authorization');
        
        if (!authHeader) {
            return res.status(401).json({ 
                status: 'error',
                message: 'Требуется аутентификация',
                details: 'Отсутствует заголовок Authorization'
            });
        }

        // Извлекаем токен
        const token = authHeader.startsWith('Bearer ') 
            ? authHeader.slice(7) 
            : authHeader;
        
        if (!token) {
            return res.status(401).json({ 
                status: 'error',
                message: 'Требуется аутентификация',
                details: 'Токен отсутствует или имеет неверный формат'
            });
        }

        try {
            // Проверяем токен
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret_key');
            
            // Проверяем срок действия токена
            if (decoded.exp && Date.now() >= decoded.exp * 1000) {
                return res.status(401).json({
                    status: 'error',
                    message: 'Срок действия токена истек',
                    details: 'Пожалуйста, войдите в систему заново'
                });
            }

            // Находим пользователя
            const user = await User.findOne({ 
                where: { 
                    id: decoded.id,
                    active: true // Проверяем, что пользователь активен
                },
                attributes: ['id', 'username', 'password', 'role', 'active', 'createdAt', 'updatedAt']
            });

            if (!user) {
                return res.status(401).json({ 
                    status: 'error',
                    message: 'Пользователь не найден или неактивен',
                    details: 'Токен содержит недействительный ID пользователя или аккаунт деактивирован'
                });
            }

            // Добавляем пользователя и токен в запрос
            req.user = user;
            req.token = token;

            // Добавляем вспомогательные методы для проверки прав
            req.user.hasRole = (role) => user.role === role;
            req.user.hasAnyRole = (roles) => roles.includes(user.role);

            next();
        } catch (jwtError) {
            console.error('Ошибка проверки токена:', jwtError);
            return res.status(401).json({ 
                status: 'error',
                message: 'Неверный токен',
                details: 'Токен недействителен или срок его действия истек'
            });
        }
    } catch (error) {
        console.error('Ошибка аутентификации:', error);
        res.status(500).json({ 
            status: 'error',
            message: 'Внутренняя ошибка сервера',
            details: 'Произошла ошибка при проверке аутентификации'
        });
    }
};

const roleCheck = (roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                status: 'error',
                message: 'Требуется аутентификация',
                details: 'Пользователь не аутентифицирован'
            });
        }

        if (!req.user.hasAnyRole(roles)) {
            return res.status(403).json({
                status: 'error',
                message: 'Доступ запрещен',
                details: 'У вас нет необходимых прав для выполнения этого действия'
            });
        }
        next();
    };
};

const isOwner = (modelName) => {
    return async (req, res, next) => {
        try {
            if (!req.user) {
                return res.status(401).json({
                    status: 'error',
                    message: 'Требуется аутентификация',
                    details: 'Пользователь не аутентифицирован'
                });
            }

            const Model = require('../models')[modelName];
            const resourceId = req.params.id;

            const resource = await Model.findOne({
                where: {
                    id: resourceId,
                    userId: req.user.id
                }
            });

            if (!resource) {
                return res.status(403).json({
                    status: 'error',
                    message: 'Доступ запрещен',
                    details: 'У вас нет прав для выполнения этого действия над данным ресурсом'
                });
            }

            req.resource = resource;
            next();
        } catch (error) {
            console.error('Ошибка проверки владельца:', error);
            res.status(500).json({
                status: 'error',
                message: 'Внутренняя ошибка сервера',
                details: 'Произошла ошибка при проверке прав доступа'
            });
        }
    };
};

module.exports = {
    auth,
    roleCheck,
    isOwner
}; 