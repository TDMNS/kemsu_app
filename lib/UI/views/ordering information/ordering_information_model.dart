class BasisOfEducation {
  String? basic;
  int? basicId;
  int? selectedBasic;

  BasisOfEducation({this.basic, this.basicId, this.selectedBasic});

  BasisOfEducation.fromJson(Map<String, dynamic> json) {
    basic = json["BASIC"];
    basicId = json["DIC_ED_BASIC_ID"];
    selectedBasic = json["DEF_SELECT"];
  }
}

class PeriodList {
  int? periodId;
  String? period;
  int? selectedPeriod;

  PeriodList({this.periodId, this.period, this.selectedPeriod});

  PeriodList.fromJson(Map<String, dynamic> json) {
    periodId = json["GL_PERIOD_ID"];
    period = json["PERIOD"];
    selectedPeriod = json["DEF_SELECT"];
  }
}

class RequestReference {
  String? lastName;
  String? firstName;
  String? patronymic;
  String? instituteName;
  int? courseNumber;
  String? educationLevel;
  String? groupName;
  String? basic;
  String? period;
  int? countReferences;
  String? requestDate;

  RequestReference({
    this.lastName,
    this.firstName,
    this.patronymic,
    this.instituteName,
    this.courseNumber,
    this.educationLevel,
    this.groupName,
    this.basic,
    this.period,
    this.countReferences,
    this.requestDate
  });

  RequestReference.fromJson(Map<String, dynamic> json) {
    lastName = json["SURNAME"];
    firstName = json["NAME"];
    patronymic = json["PATRONYMIC"];
    instituteName = json["INSTITUTION"];
    courseNumber = json["KURS_NUM"];
    educationLevel = json["EDU_LEVEL"];
    groupName = json["GROUP_NAME"];
    basic = json["BASIC"];
    period = json["PERIOD"];
    countReferences = json["REF_CNT"];
    requestDate = json["REQUEST_DATE"];
  }
}
