import 'package:mrz_parser/src/mrz_string_extensions.dart';

class MrzFieldRecognitionDefectsFixer {
  MrzFieldRecognitionDefectsFixer._();

  static String fixDocumentType(String input) =>
      input.replaceSimilarDigitsWithLetters();

  static String fixCheckDigit(String input) =>
      input.replaceSimilarLettersWithDigits();

  static String fixDate(String input) =>
      input.replaceSimilarLettersWithDigits();

  static String fixSex(String input) => input.replaceAll('P', 'F');

  static String fixCountryCode(String input) =>
      input.replaceSimilarDigitsWithLetters();

  static String fixNames(String input) =>
      input.replaceSimilarDigitsWithLetters();

  static String fixNationality(String input) =>
      input.replaceSimilarDigitsWithLetters();
}
