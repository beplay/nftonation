import {Request, Response} from "express";

export class IndexController {
    index(req: Request, res: Response) {
        res.render("index", {data: ["Hello", "World", "!"], dark: false});
    }
}

export const indexController = new IndexController();
