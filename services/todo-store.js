"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.todoStore = exports.TodoStore = exports.Todo = void 0;
const nedb_promises_1 = __importDefault(require("nedb-promises"));
class Todo {
    constructor(title, description, importance, dueDate, state) {
        this.title = title;
        this.description = description;
        this.importance = importance;
        this.dueDate = dueDate;
        this.state = state;
    }
}
exports.Todo = Todo;
class TodoStore {
    constructor(db) {
        this.db = db;
        this.db = db || new nedb_promises_1.default({ filename: './data/todos.db', autoload: true });
    }
    async add() {
        //const todo = new Todo();
        //return this.db.insert(todo);
    }
    async delete(id) {
        await this.db.update({ _id: id }, { $set: { "state": "DELETED" } });
        return this.get(id);
    }
    async get(id) {
        return this.db.findOne({ _id: id });
    }
    async all() {
        return this.db.find({});
    }
}
exports.TodoStore = TodoStore;
exports.todoStore = new TodoStore();
//# sourceMappingURL=todo-store.js.map