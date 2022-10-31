const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('ToDoApp Contract', async () => {
    let TodoApp, hardhatTodoApp, owner, addr1,addr2, addrs; 
    beforeEach(async() => {
        TodoApp = await ethers.getContractFactory("ToDoApp");
        [owner, addr1, addr2, addrs] = await ethers.getSigners();
        hardhatTodoApp = await TodoApp.deploy();
    });

    describe("Deployment", async() => {
        
        it('Should have a blank todolist', async () => {
            const todos = await hardhatTodoApp.getTodos();
            expect(todos.length).to.equal(0);
        });
    });

    describe("Created Todo app", async () => {
        it('Created Todo app', async () => {
            const todoData = await hardhatTodoApp.createTodo("testing", 0, 0);
            todoData.wait();
            let todos = await hardhatTodoApp.getTodos();
            expect(todos.length).to.equal(1);
        
            const todoData1 = await hardhatTodoApp.createTodo("testing 2", 0, 0);
            todoData1.wait();
            todos = await hardhatTodoApp.getTodos();
            expect(todos.length).to.equal(2);
        });
    });

    describe("Update Todo Status", async () => {
        it('Updated Todo status to in-progress', async () => {
            const todoData = await hardhatTodoApp.createTodo("testing", 0, 0);
            todoData.wait();
            const inProgressStatus = 1;
            const completedStatus = 2;
            const todoId = 0;
            const updateStatusRequest = await hardhatTodoApp.updateStatus(todoId, inProgressStatus);
            updateStatusRequest.wait();
            // let todos = await hardhatTodoApp.getTodos();
            let todo = await hardhatTodoApp.todos(todoId);
            expect(todo.status).to.equal(inProgressStatus);

            const completedStatusRequest = await hardhatTodoApp.updateStatus(todoId, completedStatus);
            completedStatusRequest.wait();
            todo = await hardhatTodoApp.todos(todoId);
            expect(todo.status).to.equal(completedStatus);
        });

        it('Updated Todo status to completed', async () => {

            const todoData = await hardhatTodoApp.createTodo("testing", 0, 0);
            todoData.wait();
            const inProgressStatus = 1;
            const completedStatus = 2;
            const todoId = 0;

            const completedStatusRequest = await hardhatTodoApp.updateStatus(todoId, completedStatus);
            completedStatusRequest.wait();
            todo = await hardhatTodoApp.todos(todoId);
            expect(todo.status).to.equal(completedStatus);
        });
    });

    describe("Update Todo Task", async () => {

        it('Update todo task name', async () => {
            
            const todoData = await hardhatTodoApp.createTodo("testing", 0, 0);
            todoData.wait();

            const todoId = 0;
            const text = "New todo task";

            const updateTodoTask = await hardhatTodoApp.updateTodo(todoId, text);
            updateTodoTask.wait();

            const todo = await hardhatTodoApp.todos(todoId);
            expect(todo.text).to.equal(text);
        });
    });

    describe("Delete Todo task", () => {

        it('Delete todo task', async() => {

            const address0 = "0x0000000000000000000000000000000000000000";

            const todoData = await hardhatTodoApp.createTodo("testing", 0, 0);
            todoData.wait();

            const todoId = 0;
            
            const deleteTodo = await hardhatTodoApp.deleteToDo(todoId);
            deleteTodo.wait();

            const todo = await hardhatTodoApp.todos(todoId);

            expect(todo.owner).to.equal(address0);
            expect(todo.text).to.equal("");
        
        });

    });

    describe("Get todo tasks", async() => {

        it("Get todo tasks after making updateds", async() => {

            const todoData = await hardhatTodoApp.createTodo("testing1", 0, 0);
            todoData.wait();

            const todoData2 = await hardhatTodoApp.createTodo("testing2", 0, 0);
            todoData2.wait();

            const todoData3 = await hardhatTodoApp.createTodo("testing3", 0, 0);
            todoData3.wait();

            let todos = await hardhatTodoApp.getTodos();
            expect(todos.length).to.equal(3);

            const deleteTodoTask = await hardhatTodoApp.deleteToDo(0);
            deleteTodoTask.wait();

            todos = await hardhatTodoApp.getTodos();
            todos = todos.filter(element => {
                if(element.owner === "0x0000000000000000000000000000000000000000") {
                    return false;
                }
                else {
                    return true;
                }
            })
            expect(todos.length).to.equal(2);
        });

    });

});