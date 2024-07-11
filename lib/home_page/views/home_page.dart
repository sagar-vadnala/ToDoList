import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/home_page/controller/journal_controller.dart';
// import 'journal_controller.dart';

class HomePage extends StatelessWidget {
  final JournalController controller = Get.put(JournalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 97, 132, 160),
        title: Text("TODOLIST"),
        actions: [
          Obx(() {
            return DropdownButton<String>(
              value: controller.selectedPriority.value,
              items: ['All', 'High', 'Medium', 'Low']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                controller.filterByPriority(newValue!);
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.journals.length,
          itemBuilder: (context, index) => Card(
            color: Color.fromARGB(255, 92, 135, 93),
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(controller.journals[index]['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.journals[index]['description']),
                  Text('Priority: ${controller.journals[index]['priority']}'),
                  Text('Timer: ${controller.journals[index]['timerDuration']} minutes'),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _showForm(context, controller, controller.journals[index]['id']),
                      icon: const Icon(Icons.edit)),
                    IconButton(
                      onPressed: () => controller.deleteItem(controller.journals[index]['id']),
                      icon: const Icon(Icons.delete)),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showForm(context, controller, null),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, JournalController controller, int? id) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    String priorityValue = 'Low';
    int timerDuration = 2;

    if (id != null) {
      final existingJournal = controller.journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
      priorityValue = existingJournal['priority'];
      timerDuration = existingJournal['timerDuration'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: "Description"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: priorityValue,
              items: ['High', 'Medium', 'Low'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                priorityValue = newValue!;
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<int>(
              value: timerDuration,
              items: [2, 3, 5, 10].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value minutes'),
                );
              }).toList(),
              onChanged: (newValue) {
                timerDuration = newValue!;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty) {
                  if (id == null) {
                    await controller.addItem(
                      _titleController.text,
                      _descriptionController.text,
                      priorityValue,
                      timerDuration,
                    );
                  } else {
                    await controller.updateItem(
                      id,
                      _titleController.text,
                      _descriptionController.text,
                      priorityValue,
                      timerDuration,
                    );
                  }
                  _titleController.text = '';
                  _descriptionController.text = '';
                  priorityValue = 'Low';
                  timerDuration = 2;
                  Navigator.of(context).pop();
                } else {
                  Get.snackbar('Error', 'Please fill in all fields');
                }
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}