import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './checkList_viewmodel.dart';
import 'package:stacked/stacked.dart';

import '../../widgets.dart';

class CheckListView extends StatelessWidget {
  const CheckListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckListViewModel>.reactive(
        onModelReady: (viewModel) => viewModel.onReady(),
        viewModelBuilder: () => CheckListViewModel(context),
        builder: (context, model, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark),
            child: Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              appBar: customAppBar(context, model, 'Обходной лист'),
              bottomNavigationBar: customBottomBar(context, model),
              body: _checkListView(context, model),
            ),
          );
        });
  }
}

_checkListView(BuildContext context, CheckListViewModel model) {
  return ListView(
    children: <Widget>[
      const SizedBox(height: 12),
      Center(
        child: Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: DataTable(
                columnSpacing: 0,
                columns: [
                  DataColumn(label: Expanded(child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Группа'),
                            content: const Text(
                                'Название учебной группы.'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Закрыть'))
                            ],
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Гр.', textAlign: TextAlign.left)),)),
                  DataColumn(label: Expanded(child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Подразделение'),
                            content: const Text(
                                'Название подразделения.'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Закрыть'))
                            ],
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Подр.', textAlign: TextAlign.left)),)),
                  DataColumn(label: Expanded(child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Задолженность'),
                            content: const Text(
                                'Информация о наличии задолженности. Если ячейка пуста, значит, информаиця ещё не заполнена ответственным лицом в подразделении.'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Закрыть'))
                            ],
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Задол.', textAlign: TextAlign.left)),)),
                ],
                rows: model.checkList.map<DataRow>((e) => DataRow(cells: [
                  DataCell(Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(e.groupName.toString(),
                      textAlign: TextAlign.left, softWrap: true))),
                  DataCell(Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(e.departmentTitle.toString(),
                      textAlign: TextAlign.center, softWrap: true))),
                  DataCell(Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Комментарий'),
                            content: Text(e.comment.toString()),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              child: const Text('Закрыть'))
                            ],
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: Text(e.debt.toString(), textAlign: TextAlign.left,
                        style: TextStyle(color: e.debt.toString()=="Есть"? Colors.red : Colors.green)),
                  ))
                  )),
                ])).toList(),
                border: TableBorder.all(
                  color: Colors.black,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
                dataRowHeight: 90,
                showCheckboxColumn: false,
              ),
            )),
      ),
    ],
  );
}