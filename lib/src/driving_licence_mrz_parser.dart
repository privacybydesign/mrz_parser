import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_parser/src/mrz_checkdigit_calculator.dart';
import 'package:mrz_parser/src/mrz_field_parser.dart';
import 'package:mrz_parser/src/mrz_field_recognition_defects_fixer.dart';

class DrivingLicenceMrzParser extends MrzParser<DrivingLicenceMrzResult> {
  static const _lineLength = 30;

  /// Parse [input] and return [DrivingLicenceMrzResult] instance.
  ///
  /// The [input] must be a non-null non-empty List with a single line
  /// from a driver license machine-readable zone.
  ///
  /// If [input] format is invalid or parsing was unsuccessful,
  /// an instance of [MrzException] is thrown
  @override
  DrivingLicenceMrzResult parse(List<String?>? input) {
    final polishedInput = _polishInput(input);
    if (polishedInput == null || polishedInput.isEmpty) {
      throw const InvalidMrzInputException();
    }

    if (polishedInput.length != 1 || polishedInput[0].length != _lineLength) {
      throw const InvalidMrzInputException();
    }

    if (!polishedInput[0].startsWith('D')) {
      throw const InvalidMrzInputException();
    }

    return _parseDriverLicense(polishedInput[0]);
  }

  static List<String>? _polishInput(List<String?>? input) {
    if (input == null) {
      return null;
    }

    final polishedInput =
        input.where((s) => s != null).map((s) => s!.toUpperCase()).toList();

    final validMRZInput = RegExp(r'^[A-Z|0-9|<]+$');
    return polishedInput.any((s) => !validMRZInput.hasMatch(s))
        ? null
        : polishedInput;
  }

  /// Parse a driving licence MRZ string and return [DrivingLicenceMrzResult] instance.
  ///
  /// The [line] must be a single 30-character line from a driver license MRZ.
  DrivingLicenceMrzResult _parseDriverLicense(String line) {
    return _DrivingLicenceMRZFormatParser.parse([line]);
  }
}

class _DrivingLicenceMRZFormatParser {
  _DrivingLicenceMRZFormatParser._();

  static const _lineLength = 30;
  static const _linesCount = 1;

  static bool isValidInput(List<String> input) =>
      input.length == _linesCount &&
      input.every((s) => s.length == _lineLength) &&
      input[0].startsWith('D');

  static DrivingLicenceMrzResult parse(List<String> input) {
    if (!isValidInput(input)) {
      throw const InvalidMrzInputException();
    }

    final line = input[0];

    final documentTypeRaw = line.substring(0, 1);
    final configurationRaw = line.substring(1, 2);
    final countryCodeRaw = line.substring(2, 5);
    final versionRaw = line.substring(5, 6);
    final documentNumberRaw = line.substring(6, 16);
    final randomDataRaw = line.substring(16, 29);
    final checkDigitRaw = line.substring(29, 30);

    final documentTypeFixed =
        MrzFieldRecognitionDefectsFixer.fixDocumentType(documentTypeRaw);
    final configurationFixed = configurationRaw;
    final countryCodeFixed =
        MrzFieldRecognitionDefectsFixer.fixCountryCode(countryCodeRaw);
    final versionFixed = versionRaw;
    final documentNumberFixed = documentNumberRaw;
    final randomDataFixed = randomDataRaw;
    final checkDigitFixed =
        MrzFieldRecognitionDefectsFixer.fixCheckDigit(checkDigitRaw);

    final documentNumberIsValid = int.tryParse(checkDigitFixed) ==
        MrzCheckDigitCalculator.getCheckDigit(line.substring(0, 29));
    if (!documentNumberIsValid) {
      throw const InvalidDocumentNumberException();
    }

    final documentType = MrzFieldParser.parseDocumentType(documentTypeFixed);
    final configuration = MrzFieldParser.parseDocumentType(configurationFixed);
    final countryCode = MrzFieldParser.parseCountryCode(countryCodeFixed);
    final version = versionFixed;
    final documentNumber =
        MrzFieldParser.parseDocumentNumber(documentNumberFixed);
    final randomData = MrzFieldParser.parseOptionalData(randomDataFixed);

    return DrivingLicenceMrzResult(
      documentType: documentType,
      configuration: configuration,
      countryCode: countryCode,
      version: version,
      documentNumber: documentNumber,
      randomData: randomData,
    );
  }
}
