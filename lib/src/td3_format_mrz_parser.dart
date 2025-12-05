import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_parser/src/mrz_checkdigit_calculator.dart';
import 'package:mrz_parser/src/mrz_field_parser.dart';
import 'package:mrz_parser/src/mrz_field_recognition_defects_fixer.dart';

class TD3MrzFormatParser {
  TD3MrzFormatParser._();

  static const _linesLength = 44;
  static const _linesCount = 2;

  static bool isValidInput(List<String> input) =>
      input.length == _linesCount &&
      input.every((s) => s.length == _linesLength);

  static PassportMrzResult parse(List<String> input) {
    if (!isValidInput(input)) {
      throw const InvalidMrzInputException();
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
    final optionalDataRaw = secondLine.substring(28, isVisaDocument ? 44 : 42);
    final optionalDataCheckDigitRaw = isVisaDocument ? null : secondLine[42];
    final finalCheckDigitRaw = isVisaDocument ? null : secondLine.substring(43);

    final documentTypeFixed =
        MrzFieldRecognitionDefectsFixer.fixDocumentType(documentTypeRaw);
    final countryCodeFixed =
        MrzFieldRecognitionDefectsFixer.fixCountryCode(countryCodeRaw);
    final namesFixed = MrzFieldRecognitionDefectsFixer.fixNames(namesRaw);
    var documentNumberFixed = documentNumberRaw;
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
    final optionalDataCheckDigitFixed = optionalDataCheckDigitRaw != null
        ? MrzFieldRecognitionDefectsFixer.fixCheckDigit(
            optionalDataCheckDigitRaw,
          )
        : null;
    final finalCheckDigitFixed = finalCheckDigitRaw != null
        ? MrzFieldRecognitionDefectsFixer.fixCheckDigit(finalCheckDigitRaw)
        : null;

    var documentNumberIsValid = int.tryParse(documentNumberCheckDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(documentNumberFixed);

    // If check digit doesn't match, try common OCR errors: O <-> 0
    if (!documentNumberIsValid) {
      // Try replacing 'O' with '0'
      if (documentNumberFixed.contains('O')) {
        final documentNumberCorrected =
            documentNumberFixed.replaceAll('O', '0');
        final correctedIsValid = int.tryParse(documentNumberCheckDigitFixed) ==
            MrzCheckDigitCalculator.getCheckDigit(documentNumberCorrected);

        if (correctedIsValid) {
          documentNumberFixed = documentNumberCorrected;
          documentNumberIsValid = true;
        }
      }

      // Try replacing '0' with 'O' if still not valid
      if (!documentNumberIsValid && documentNumberFixed.contains('0')) {
        final documentNumberCorrected =
            documentNumberFixed.replaceAll('0', 'O');
        final correctedIsValid = int.tryParse(documentNumberCheckDigitFixed) ==
            MrzCheckDigitCalculator.getCheckDigit(documentNumberCorrected);

        if (correctedIsValid) {
          documentNumberFixed = documentNumberCorrected;
          documentNumberIsValid = true;
        }
      }
    }

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

    if (optionalDataCheckDigitFixed != null) {
      final optionalDataIsValid = (int.tryParse(optionalDataCheckDigitFixed) ==
              MrzCheckDigitCalculator.getCheckDigit(optionalDataFixed)) ||
          ((optionalDataCheckDigitFixed == '<') &&
              MrzFieldParser.parseOptionalData(optionalDataFixed).isEmpty);

      if (!optionalDataIsValid) {
        throw const InvalidOptionalDataException();
      }
    }

    if (finalCheckDigitFixed != null) {
      final finalCheckStringFixed =
          '$documentNumberFixed$documentNumberCheckDigitFixed'
          '$birthDateFixed$birthDateCheckDigitFixed'
          '$expiryDateFixed$expiryDateCheckDigitFixed'
          '$optionalDataFixed${optionalDataCheckDigitFixed ?? ''}';

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
}
