import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_parser/src/mrz_checkdigit_calculator.dart';
import 'package:mrz_parser/src/mrz_field_parser.dart';
import 'package:mrz_parser/src/mrz_field_recognition_defects_fixer.dart';

class TD2MrzFormatParser {
  TD2MrzFormatParser._();

  static const _linesLength = 36;
  static const _linesCount = 2;

  static bool isValidInput(List<String> input) =>
      input.length == _linesCount &&
      input.every((s) => s.length == _linesLength);

  static PassportMrzResult parse(List<String> input) {
    if (!isValidInput(input)) {
      throw const InvalidMrzInputException();
    }

    if (_isFrenchId(input)) {
      return _parseFrenchId(input);
    }

    final firstLine = input[0];
    final secondLine = input[1];

    final isVisaDocument = firstLine[0] == 'V';
    final documentTypeRaw = firstLine.substring(0, 2);
    final countryCodeRaw = firstLine.substring(2, 5);
    final namesRaw = firstLine.substring(5);
    final documentNumberRaw = secondLine.substring(0, 9);
    final documentNumberCheckDigitRaw = secondLine[9];
    final nationalityRaw = secondLine.substring(10, 13);
    final birthDateRaw = secondLine.substring(13, 19);
    final birthDateCheckDigitRaw = secondLine[19];
    final sexRaw = secondLine.substring(20, 21);
    final expiryDateRaw = secondLine.substring(21, 27);
    final expiryDateCheckDigitRaw = secondLine[27];
    final optionalDataRaw = secondLine.substring(28, isVisaDocument ? 36 : 35);
    final finalCheckDigitRaw = isVisaDocument ? null : secondLine.substring(35);

    final documentTypeFixed =
        MrzFieldRecognitionDefectsFixer.fixDocumentType(documentTypeRaw);
    final countryCodeFixed =
        MrzFieldRecognitionDefectsFixer.fixCountryCode(countryCodeRaw);
    final namesFixed = MrzFieldRecognitionDefectsFixer.fixNames(namesRaw);
    final documentNumberFixed = documentNumberRaw;
    final documentNumberCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(
      documentNumberCheckDigitRaw,
    );
    final nationalityFixed =
        MrzFieldRecognitionDefectsFixer.fixNationality(nationalityRaw);
    final birthDateFixed =
        MrzFieldRecognitionDefectsFixer.fixDate(birthDateRaw);
    final birthDateCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(birthDateCheckDigitRaw);
    final sexFixed = MrzFieldRecognitionDefectsFixer.fixSex(sexRaw);
    final expiryDateFixed =
        MrzFieldRecognitionDefectsFixer.fixDate(expiryDateRaw);
    final expiryDateCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(expiryDateCheckDigitRaw);
    final optionalDataFixed = optionalDataRaw;
    final finalCheckDigitFixed = finalCheckDigitRaw != null
        ? MrzFieldRecognitionDefectsFixer.fixCheckDigit(finalCheckDigitRaw)
        : null;

    final documentNumberIsValid = int.tryParse(documentNumberCheckDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(documentNumberFixed);

    if (!documentNumberIsValid) {
      throw const InvalidDocumentNumberException();
    }

    final birthDateIsValid = int.tryParse(birthDateCheckDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(birthDateFixed);

    if (!birthDateIsValid) {
      throw const InvalidBirthDateException();
    }

    final expiryDateIsValid = int.tryParse(expiryDateCheckDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(expiryDateFixed);

    if (!expiryDateIsValid) {
      throw const InvalidExpiryDateException();
    }

    if (finalCheckDigitFixed != null) {
      final finalCheckStringFixed =
          '$documentNumberFixed$documentNumberCheckDigitFixed'
          '$birthDateFixed$birthDateCheckDigitFixed'
          '$expiryDateFixed$expiryDateCheckDigitFixed'
          '$optionalDataFixed';

      final finalCheckStringIsValid = int.tryParse(finalCheckDigitFixed) ==
          MrzCheckDigitCalculator.getCheckDigit(finalCheckStringFixed);

      if (!finalCheckStringIsValid) {
        throw const InvalidMrzValueException();
      }
    }

    final documentType = MrzFieldParser.parseDocumentType(documentTypeFixed);
    final countryCode = MrzFieldParser.parseCountryCode(countryCodeFixed);
    final names = MrzFieldParser.parseNames(namesFixed);
    final documentNumber =
        MrzFieldParser.parseDocumentNumber(documentNumberFixed);
    final nationality = MrzFieldParser.parseNationality(nationalityFixed);
    final birthDate = MrzFieldParser.parseBirthDate(birthDateFixed);
    final sex = MrzFieldParser.parseSex(sexFixed);
    final expiryDate = MrzFieldParser.parseExpiryDate(expiryDateFixed);
    final optionalData = MrzFieldParser.parseOptionalData(optionalDataFixed);

    return PassportMrzResult(
      documentType: documentType,
      countryCode: countryCode,
      surnames: names[0],
      givenNames: names[1],
      documentNumber: documentNumber,
      nationalityCountryCode: nationality,
      birthDate: birthDate,
      sex: sex,
      expiryDate: expiryDate,
      personalNumber: optionalData,
    );
  }

  static bool _isFrenchId(List<String> input) =>
      input[0][0] == 'I' && input[0].substring(2, 5) == 'FRA';

  static PassportMrzResult _parseFrenchId(List<String> input) {
    final firstLine = input[0];
    final secondLine = input[1];

    final documentTypeRaw = firstLine.substring(0, 2);
    final countryCodeRaw = firstLine.substring(2, 5);
    final lastNamesRaw = firstLine.substring(5, 30);
    final departmentAndOfficeRaw = firstLine.substring(30, 36);

    final issueDateRaw = secondLine.substring(0, 4);
    final departmentRaw = secondLine.substring(4, 7);
    final documentNumberRaw = secondLine.substring(0, 12);
    final documentNumberCheckDigitRaw = secondLine[12];
    final givenNamesRaw = secondLine.substring(13, 27);
    final birthDateRaw = secondLine.substring(27, 33);
    final birthDateCheckDigitRaw = secondLine[33];
    final sexRaw = secondLine.substring(34, 35);
    final finalCheckDigitRaw = secondLine.substring(35);

    final documentTypeFixed =
        MrzFieldRecognitionDefectsFixer.fixDocumentType(documentTypeRaw);
    final countryCodeFixed =
        MrzFieldRecognitionDefectsFixer.fixCountryCode(countryCodeRaw);
    final lastNamesFixed =
        MrzFieldRecognitionDefectsFixer.fixNames(lastNamesRaw);
    final departmentAndOfficeFixed = departmentAndOfficeRaw;
    final issueDateFixed =
        MrzFieldRecognitionDefectsFixer.fixDate(issueDateRaw);
    final departmentFixed = departmentRaw;
    final documentNumberFixed = documentNumberRaw;
    final documentNumberCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(
      documentNumberCheckDigitRaw,
    );
    final givenNamesFixed =
        MrzFieldRecognitionDefectsFixer.fixNames(givenNamesRaw);
    final birthDateFixed =
        MrzFieldRecognitionDefectsFixer.fixDate(birthDateRaw);
    final birthDateCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(birthDateCheckDigitRaw);
    final sexFixed = MrzFieldRecognitionDefectsFixer.fixSex(sexRaw);
    final finalCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(finalCheckDigitRaw);

    final documentNumberIsValid = int.tryParse(documentNumberCheckDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(documentNumberFixed);

    if (!documentNumberIsValid) {
      throw const InvalidDocumentNumberException();
    }

    final birthDateIsValid = int.tryParse(birthDateCheckDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(birthDateFixed);

    if (!birthDateIsValid) {
      throw const InvalidBirthDateException();
    }

    final finalCheckStringFixed =
        '$documentTypeFixed$countryCodeFixed$lastNamesFixed'
        '$departmentAndOfficeFixed'
        '$documentNumberFixed$documentNumberCheckDigitFixed'
        '$givenNamesFixed$birthDateFixed$birthDateCheckDigitFixed$sexFixed';

    final finalCheckStringIsValid = int.tryParse(finalCheckDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(finalCheckStringFixed);

    if (!finalCheckStringIsValid) {
      throw const InvalidMrzValueException();
    }

    final documentType = MrzFieldParser.parseDocumentType(documentTypeFixed);
    final countryCode = MrzFieldParser.parseCountryCode(countryCodeFixed);
    final givenNames = MrzFieldParser.parseNames(givenNamesFixed)
        .where((element) => element.isNotEmpty)
        .toList()
        .join(' ');
    final lastNames = MrzFieldParser.parseNames(lastNamesFixed)
        .where((element) => element.isNotEmpty)
        .toList()
        .join(' ');
    final documentNumber =
        MrzFieldParser.parseDocumentNumber(documentNumberFixed);
    final nationality = MrzFieldParser.parseNationality(countryCodeFixed);
    final birthDate = MrzFieldParser.parseBirthDate(birthDateFixed);
    final sex = MrzFieldParser.parseSex(sexFixed);
    final issueDate = MrzFieldParser.parseExpiryDate('${issueDateFixed}01');
    final yearsValid = issueDate.isBefore(DateTime(2014))
        ? 10
        : birthDate.isBefore(
            DateTime(issueDate.year - 18, issueDate.month, issueDate.day),
          )
            ? 15
            : 10;
    final expiryDate =
        DateTime(issueDate.year + yearsValid, issueDate.month, issueDate.day);
    final optionalData =
        MrzFieldParser.parseOptionalData(departmentAndOfficeFixed);
    final optionalData2 = MrzFieldParser.parseOptionalData(departmentFixed);

    return PassportMrzResult(
      documentType: documentType,
      countryCode: countryCode,
      surnames: lastNames,
      givenNames: givenNames,
      documentNumber: documentNumber,
      nationalityCountryCode: nationality,
      birthDate: birthDate,
      sex: sex,
      expiryDate: expiryDate,
      personalNumber: optionalData,
      personalNumber2: optionalData2,
    );
  }
}
