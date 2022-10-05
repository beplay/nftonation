"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.helpers = void 0;
exports.helpers = {
    'if_eq': function (a, b, opts) {
        if (a === b)
            return opts.fn(this);
        else
            return opts.inverse(this);
    }
};
//# sourceMappingURL=handlebar-util.js.map