"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.indexController = exports.IndexController = void 0;
class IndexController {
    index(req, res) {
        res.render("index", { data: ["Hello", "World", "!"], dark: true });
    }
}
exports.IndexController = IndexController;
exports.indexController = new IndexController();
//# sourceMappingURL=index-controller.js.map