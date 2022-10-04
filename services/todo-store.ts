import Datastore from 'nedb-promises'

export class Todo {
    constructor(
        public title: string,
        public description: string,
        public importance: number,
        public dueDate: Date,
        public state: string | undefined
        ) {
    }
}

export class TodoStore {
    constructor(public db?: Datastore) {
        this.db = db || new Datastore({filename: './data/todos.db', autoload: true});
    }

    async add() {
        //const todo = new Todo();
        //return this.db.insert(todo);
    }

    async delete(id: string) {
        await this.db!.update({_id: id}, {$set: {"state": "DELETED"}});
        return this.get(id);
    }

    async get(id: string) {
        return this.db!.findOne({_id: id});
    }

    async all() {
        return this.db!.find({});
    }
}

export const todoStore = new TodoStore();
