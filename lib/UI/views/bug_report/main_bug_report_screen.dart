import 'package:flutter/material.dart';
import 'package:kemsu_app/UI/views/bug_report/bug_report_view_model.dart';
import 'package:kemsu_app/UI/widgets.dart';
import 'package:stacked/stacked.dart';

class MainBugReportScreenRoute extends MaterialPageRoute {
  MainBugReportScreenRoute() : super(builder: (context) => const MainBugReportScreen());
}

class MainBugReportScreen extends StatelessWidget {
  const MainBugReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BugReportViewModel>.reactive(
        viewModelBuilder: () => BugReportViewModel(context),
        onModelReady: (viewModel) => viewModel.onReady(context),
        builder: (context, model, child) {
          return model.circle
              ? Container(
                  color: Theme.of(context).primaryColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                      backgroundColor: Colors.white,
                    ),
                  ),
                )
              : Scaffold(
                  appBar: customAppBar(context, model, "Сообщения об ошибках"),
                  body: _body(context, model),
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      showDialog(context: context, builder: (_) => newMessageDialog(context, model));
                    },
                  ),
                );
        });
  }
}

_body(context, BugReportViewModel model) {
  return ListView(
    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    children: [
      const SizedBox(
        height: 34,
      ),
      _errorMessagesTitle(context),
      const SizedBox(
        height: 34,
      ),
      _reportSpace(context, model),
    ],
  );
}

_errorMessagesTitle(context) {
  return Padding(
    padding: const EdgeInsets.only(right: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Ваши обращения",
          style: TextStyle(
              fontSize: 24,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColorDark),
        ),
      ],
    ),
  );
}

_reportSpace(context, BugReportViewModel model) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: model.reportList.isEmpty
        ? const Center(
            child: Text("Нет отправленных обращений.",
                style: TextStyle(fontSize: 12, color: Color(0xFF757575), fontWeight: FontWeight.w500)))
        : ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: model.reportList.length,
            itemBuilder: (context, index) {
              final reportList = model.reportList[index].reportStatus;
              return ExpansionTile(
                title: Text(model.reportList[index].message.toString()),
                subtitle: Text(reportList ?? "Заявка не обработана",
                    style: TextStyle(color: reportList == "Решено" ? Colors.green : Colors.red)),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColorDark),
                            children: <TextSpan>[
                              const TextSpan(text: 'Дата обращения: '),
                              TextSpan(
                                  text: model.reportList[index].messageDate.toString(),
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }),
  );
}

newMessageDialog(context, BugReportViewModel model) {
  return AlertDialog(
    title: const Text("Создать обращение"),
    content: TextField(
      cursorColor: Colors.blue,
      controller: model.errorMsgController,
      decoration: const InputDecoration(
        hintText: 'Введите сообщение',
      ),
      maxLines: null,
    ),
    actions: [
      TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, // Text Color
          ),
          onPressed: () async {
            model.sendAction(context);
          },
          child: const Text("Отправить"))
    ],
  );
}
