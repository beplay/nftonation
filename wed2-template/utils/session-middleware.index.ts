import {Response} from "express";

export const sessionUserSettings = (req: any, res: Response, next: (err?: any) => void) :void => {
    const userSettings = req.session?.userSettings || {orderBy: 'title', orderDirection: -1};
    const {orderBy, orderDirection} = req.query;

    if (orderBy) {
        userSettings.orderBy = orderBy;
    }
    if (orderDirection) {
        userSettings.orderDirection = orderDirection;
    }
    req.userSettings = req.session.userSettings = userSettings;
    next();
};
