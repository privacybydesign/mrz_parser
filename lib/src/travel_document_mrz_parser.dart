import 'package:mrz_parser/src/mrz_exceptions.dart';
import 'package:mrz_parser/src/mrz_parser.dart';
import 'package:mrz_parser/src/mrz_result.dart';
import 'package:mrz_parser/src/mrz_string_extensions.dart';
import 'package:mrz_parser/src/td2_format_mrz_parser.dart';

class TravelDocumentMrzParser extends MrzParser<PassportMrzResult> {
  /// Parse [input] and return [PassportMrzResult] instance.
  ///
  /// The [input] must be a non-null non-empty List of lines
  /// from a documents machine-readable zone.
  ///
  /// If [input] format is invalid or parsing was unsuccessful,
  /// an instance of [MrzException] is thrown
  @override
  PassportMrzResult parse(List<String?>? input) {
    final polishedInput = _polishInput(input);
    if (polishedInput == null) {
      throw const InvalidMrzInputException();
    }

    if (TD2MrzFormatParser.isValidInput(polishedInput)) {
      return TD2MrzFormatParser.parse(polishedInput);
    }

    throw const InvalidMrzInputException();
  }

  static List<String>? _polishInput(List<String?>? input) {
    if (input == null) {
      return null;
    }

    final polishedInput =
        input.where((s) => s != null).map((s) => s!.toUpperCase()).toList();

    return polishedInput.any((s) => !s.isValidMRZInput) ? null : polishedInput;
  }
}
