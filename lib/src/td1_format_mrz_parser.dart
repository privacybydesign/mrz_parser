import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_parser/src/mrz_checkdigit_calculator.dart';
import 'package:mrz_parser/src/mrz_field_parser.dart';
import 'package:mrz_parser/src/mrz_field_recognition_defects_fixer.dart';

class TD1MrzFormatParser {
  TD1MrzFormatParser._();

  static const _linesLength = 30;
  static const _linesCount = 3;

  static bool isValidInput(List<String> input) =>
      input.length == _linesCount &&
      input.every((s) => s.length == _linesLength);

  static PassportMrzResult parse(List<String> input) {
    if (!isValidInput(input)) {
      throw const InvalidMrzInputException();
    }

    final firstLine = input[0];
    final secondLine = input[1];
    final thirdLine = input[2];

    final documentTypeRaw = firstLine.substring(0, 2);
    final countryCodeRaw = firstLine.substring(2, 5);

    final String documentNumberRaw;
    final String documentNumberCheckDigitRaw;
    final String optionalDataRaw;
    final bool isLongDocumentNumber;

    if (firstLine[14] == '<') {
      // Implementation for ICAO 9303 Part 5, section 4.2.4
      // TD1 check digit for long document numbers
      // https://www.icao.int/publications/Documents/9303_p5_cons_en.pdf

      final tmpString =
          firstLine.substring(15, 28).replaceAll(RegExp(r'<+$'), '');

      documentNumberCheckDigitRaw = tmpString[tmpString.length - 1];

      documentNumberRaw = firstLine.substring(5, 14) +
          tmpString.substring(0, tmpString.length - 1);

      //Unclear if optionalData1 is even allowed in this case.
      //The ICAO doc is not so clear about it.
      //Revise when a sample is availble...
      optionalDataRaw = firstLine.substring(15 + tmpString.length, 30);
      isLongDocumentNumber = true;
    } else {
      // Normal TD1 case
      documentNumberRaw = firstLine.substring(5, 14);
      documentNumberCheckDigitRaw = firstLine[14];
      optionalDataRaw = firstLine.substring(15, 30);
      isLongDocumentNumber = false;
    }

    final birthDateRaw = secondLine.substring(0, 6);
    final birthDateCheckDigitRaw = secondLine[6];
    final sexRaw = secondLine.substring(7, 8);
    final expiryDateRaw = secondLine.substring(8, 14);
    final expiryDateCheckDigitRaw = secondLine[14];
    final nationalityRaw = secondLine.substring(15, 18);
    final optionalData2Raw = secondLine.substring(18, 29);
    final finalCheckDigitRaw = secondLine[29];
    final namesRaw = thirdLine.substring(0, 30);

    final documentTypeFixed =
        MrzFieldRecognitionDefectsFixer.fixDocumentType(documentTypeRaw);
    final countryCodeFixed =
        MrzFieldRecognitionDefectsFixer.fixCountryCode(countryCodeRaw);
    final documentNumberFixed = documentNumberRaw;

    final documentNumberCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(
      documentNumberCheckDigitRaw,
    );

    final optionalDataFixed = optionalDataRaw;

    final birthDateFixed =
        MrzFieldRecognitionDefectsFixer.fixDate(birthDateRaw);

    final birthDateCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(birthDateCheckDigitRaw);

    final sexFixed = MrzFieldRecognitionDefectsFixer.fixSex(sexRaw);
    final expiryDateFixed =
        MrzFieldRecognitionDefectsFixer.fixDate(expiryDateRaw);
    final expiryDateCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(expiryDateCheckDigitRaw);
    final nationalityFixed =
        MrzFieldRecognitionDefectsFixer.fixNationality(nationalityRaw);
    final optionalData2Fixed = optionalData2Raw;
    final finalCheckDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(finalCheckDigitRaw);
    final namesFixed = MrzFieldRecognitionDefectsFixer.fixNames(namesRaw);

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

    final String documentNumberFixedForCheckString;
    if (isLongDocumentNumber) {
      // Long document number requires to re-introduce the < at position 15
      documentNumberFixedForCheckString =
          '${documentNumberFixed.substring(0, 9)}<${documentNumberFixed.substring(9, documentNumberFixed.length)}';
    } else {
      documentNumberFixedForCheckString = documentNumberFixed;
    }

    final finalCheckStringFixed =
        '$documentNumberFixedForCheckString$documentNumberCheckDigitFixed'
        '$optionalDataFixed'
        '$birthDateFixed$birthDateCheckDigitFixed'
        '$expiryDateFixed$expiryDateCheckDigitFixed'
        '$optionalData2Fixed';

    final finalCheckStringIsValid = int.tryParse(finalCheckDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(finalCheckStringFixed);

    if (!finalCheckStringIsValid) {
      throw const InvalidMrzValueException();
    }

    final documentType = MrzFieldParser.parseDocumentType(documentTypeFixed);
    final countryCode = MrzFieldParser.parseCountryCode(countryCodeFixed);
    final documentNumber =
        MrzFieldParser.parseDocumentNumber(documentNumberFixed);
    final optionalData = MrzFieldParser.parseOptionalData(optionalDataFixed);
    final birthDate = MrzFieldParser.parseBirthDate(birthDateFixed);
    final sex = MrzFieldParser.parseSex(sexFixed);
    final expiryDate = MrzFieldParser.parseExpiryDate(expiryDateFixed);
    final nationality = MrzFieldParser.parseNationality(nationalityFixed);
    final optionalData2 = MrzFieldParser.parseOptionalData(optionalData2Fixed);
    final names = MrzFieldParser.parseNames(namesFixed);

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
      personalNumber2: optionalData2,
    );
  }
}
