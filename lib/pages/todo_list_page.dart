import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/widgets/todo_list_item.dart';
class TodoListPage extends StatefulWidget {
  TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();

  List<Todo> todos = [];

  Todo? deletedTodo;
  int? deletedTodoPos;

  SnackBar? currentSnackBar;

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Tarefa "${todo.title}" foi removida com sucesso!'),
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: Colors.blue,
        onPressed: () {
          revertDelete(deletedTodo!);
        },
      ),
    ));
  }

  void revertDelete(Todo todo) {
    setState(() {
      todos.insert(deletedTodoPos!, deletedTodo!);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exclusão da tarefa "${todo.title}" revertida.'),
      ),
    );
  }

  void showDeleteAllDialog() {
    if(todos.isEmpty) {
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
          ),
          title: const Text('Impar Tarefas.'),
          content: const Text(
            'Você não tem tarefas para serem excluídas',
            style: TextStyle(
              fontSize: 16
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
              ),
              child: const Text(
                'Fechar',
                style: TextStyle(
                color: Colors.white,
                fontSize: 16
              ),
              ),
            )
          ],
        ),
      );

      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),
        title: const Text('Limpar tudo?'),
        content: const Text(
          'Você tem certeza que deseja excluir todas as tarefas?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              ), 
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              ), 
            ),
            onPressed: () {
              deleteAll();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Excluir tudo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16
              ),
            ),
          )
        ],
      ),
    );
  }

  void deleteAll() {
    setState(() {
      todos.clear();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas as tarefas foram excluídas com sucesso'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adicionar uma tarefa',
                          hintText: 'Ex. Estudar Flutter',
                          hintStyle: TextStyle(color: Colors.black38),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 1.8
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 18
                          )
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;
                        if(text.isEmpty) return;
            
                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            date: DateTime.now(),
                          );

                          todos.add(newTodo);
                        });
            
                        todoController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: todos.isEmpty 
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/empty.png', scale: 3,),
                        const SizedBox(height: 12,),
                        const Text(
                          'Nenhuma tarefa encontrada',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey
                          ),
                        )
                      ],
                    ),
                  )
                  : ListView(
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        todos.isEmpty ? 'Você não tem tarefas pendente' : 'Você possui ${todos.length} tarefas pendentes',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: showDeleteAllDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Limpar tudo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
