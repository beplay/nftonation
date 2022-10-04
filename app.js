"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.app = void 0;
const express_1 = __importDefault(require("express"));
const body_parser_1 = __importDefault(require("body-parser"));
const path_1 = __importDefault(require("path"));
const express_session_1 = __importDefault(require("express-session"));
const express_handlebars_1 = __importDefault(require("express-handlebars"));
const index_routes_js_1 = require("./routes/index-routes.js");
const handlebar_util_js_1 = require("./utils/handlebar-util.js");
const session_middleware_index_js_1 = require("./utils/session-middleware.index.js");
exports.app = (0, express_1.default)();
const hbs = express_handlebars_1.default.create({
    extname: '.hbs',
    defaultLayout: "default",
    helpers: {
        ...handlebar_util_js_1.helpers
    }
});
exports.app.engine('hbs', hbs.engine);
exports.app.set('view engine', 'hbs');
exports.app.set('views', path_1.default.resolve('views'));
exports.app.use(express_1.default.static(path_1.default.resolve('public')));
exports.app.use((0, express_session_1.default)({ secret: 'casduichasidbnuwezrfinasdcvjkadfhsuilfuzihfioda', resave: false, saveUninitialized: true }));
exports.app.use(session_middleware_index_js_1.sessionUserSettings);
exports.app.use(body_parser_1.default.urlencoded({ extended: false }));
exports.app.use(body_parser_1.default.json());
exports.app.use("/", index_routes_js_1.indexRoutes);
//# sourceMappingURL=app.js.map