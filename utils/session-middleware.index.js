"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sessionUserSettings = void 0;
const sessionUserSettings = (req, res, next) => {
    const userSettings = req.session?.userSettings || { orderBy: 'title', orderDirection: -1 };
    const { orderBy, orderDirection } = req.query;
    if (orderBy) {
        userSettings.orderBy = orderBy;
    }
    if (orderDirection) {
        userSettings.orderDirection = orderDirection;
    }
    req.userSettings = req.session.userSettings = userSettings;
    next();
};
exports.sessionUserSettings = sessionUserSettings;
//# sourceMappingURL=session-middleware.index.js.map