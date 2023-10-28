import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:kemsu_app/UI/common_views/main_button.dart';
import 'package:kemsu_app/UI/common_views/snack_bar.dart';
import 'package:stacked/stacked.dart';

import '../../../Configurations/localizable.dart';
import '../../widgets.dart';
import 'edit_view_model.dart';

class EditView extends StatefulWidget {
  const EditView({Key? key}) : super(key: key);

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditViewModel>.reactive(
      onViewModelReady: (viewModel) => viewModel.onReady(),
      viewModelBuilder: () => EditViewModel(context),
      builder: (context, model, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              appBar: customAppBar(context, model, "Редактировать"),
              body: model.circle
                  ? Container(
                      color: Theme.of(context).primaryColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    )
                  : _editView(context, model),
            ),
          ),
        );
      },
    );
  }
}

Widget _editView(BuildContext context, EditViewModel model) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // Реализуйте функциональность смены аватара
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 55,
                  child: InkWell(
                    onTap: () {
                      // avatarChoice(context, model);
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(55.0)),
                      child: model.file != null ? Image.file(model.file!, fit: BoxFit.cover, width: 120, height: 120) : const Icon(Icons.person, size: 80, color: Colors.grey),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // avatarChoice(context, model);
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 14,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
            controller: model.emailController,
            onSubmitted: (newEmail) {
              model.updateEmail(newEmail);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Номер телефона'),
            controller: model.phoneController,
            onSubmitted: (newPhoneNumber) {
              model.updatePhoneNumber(newPhoneNumber);
            },
          ),
          const SizedBox(height: 32),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(alignment: Alignment.centerLeft, child: Text("Сменить пароль", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20.0))),
              const SizedBox(height: 16),
              const Text("Пароль должен содержать только символы латинского алфавита", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                  decoration: const InputDecoration(labelText: "Старый пароль"),
                  controller: model.oldPasswordController,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#$%^&*()_+{}|:;<>,.?~\-=[\]\\]'))],
                  onChanged: (_) {
                    model.validateOldPassword();
                  },
                  onTap: () {
                    model.notifyListeners();
                  }),
              const SizedBox(height: 16),
              Visibility(
                  visible: !model.isValidatedOldPassword && model.oldPasswordController.text.isNotEmpty,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Text(model.getDynamicTextError(EditTextFieldType.oldPassword), style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.red)))),
              TextField(
                  decoration: const InputDecoration(labelText: "Новый пароль"),
                  controller: model.newPasswordController,
                  focusNode: model.newPasswordFocus,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#$%^&*()_+{}|:;<>,.?~\-=[\]\\]'))],
                  onTapOutside: (_) {
                    model.validateOldPassword();
                  },
                  onTap: () {
                    model.validateOldPassword();
                  }),
              Visibility(
                visible: model.newPasswordFocus.hasFocus && !model.isPasswordFieldSuccess,
                child: FlutterPwValidator(
                  controller: model.newPasswordController,
                  minLength: 8,
                  uppercaseCharCount: 1,
                  lowercaseCharCount: 1,
                  numericCharCount: 1,
                  specialCharCount: 0,
                  width: 400,
                  height: 150,
                  onSuccess: () {
                    model.isPasswordFieldSuccess = true;
                    model.notifyListeners();
                  },
                  onFail: () {
                    model.isPasswordFieldSuccess = false;
                    model.notifyListeners();
                  },
                  strings: RussianStrings(),
                ),
              ),
              const SizedBox(height: 16),
              Visibility(
                  visible: model.newPasswordController.text == model.oldPasswordController.text && model.newPasswordController.text.isNotEmpty,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Text(model.getDynamicTextError(EditTextFieldType.newPassword), style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.red)))),
              TextField(
                  decoration: const InputDecoration(labelText: "Подтвердите новый пароль"),
                  controller: model.confirmPasswordController,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#$%^&*()_+{}|:;<>,.?~\-=[\]\\]'))],
                  onTap: () {
                    model.validateOldPassword();
                  },
                  onChanged: (_) {
                    model.notifyListeners();
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    model.notifyListeners();
                  }),
              const SizedBox(height: 16),
              Visibility(
                  visible: model.newPasswordController.text != model.confirmPasswordController.text && model.confirmPasswordController.text.isNotEmpty,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(model.getDynamicTextError(EditTextFieldType.confirmPassword),
                          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.red)))),
              SizedBox(height: model.allValidateConditionsAreMet() ? 16 : 48),
              if (model.allValidateConditionsAreMet())
                mainButton(context, onPressed: () {
                  model.changePassword();
                  showSnackBar(context, "Ваш пароль успешно изменен!");
                  Navigator.pop(context);
                }, title: "Сменить пароль", isPrimary: false)
            ],
          ),
        ],
      ),
    ]),
  );
}
