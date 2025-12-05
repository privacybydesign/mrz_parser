import 'package:mrz_parser/src/mrz_field_recognition_defects_fixer.dart';
import 'package:test/test.dart';

void main() {
  test('fixes document type', () {
    expect(MrzFieldRecognitionDefectsFixer.fixDocumentType('V'), 'V');
    expect(MrzFieldRecognitionDefectsFixer.fixDocumentType('P<<'), 'P<<');
    expect(MrzFieldRecognitionDefectsFixer.fixDocumentType('0128'), 'OIZB');
    expect(MrzFieldRecognitionDefectsFixer.fixDocumentType('<'), '<');
  });

  test('fixes check digit', () {
    expect(MrzFieldRecognitionDefectsFixer.fixCheckDigit('8'), '8');
    expect(MrzFieldRecognitionDefectsFixer.fixCheckDigit('<6<'), '<6<');
    expect(MrzFieldRecognitionDefectsFixer.fixCheckDigit('0QUDIZB'), '0000128');
    expect(MrzFieldRecognitionDefectsFixer.fixCheckDigit('<'), '<');
  });

  test('fixes date', () {
    expect(MrzFieldRecognitionDefectsFixer.fixDate('190213'), '190213');
    expect(MrzFieldRecognitionDefectsFixer.fixDate('19021<'), '19021<');
    expect(MrzFieldRecognitionDefectsFixer.fixDate('0QUDIZB'), '0000128');
    expect(MrzFieldRecognitionDefectsFixer.fixDate('<'), '<');
  });

  test('fixes sex', () {
    expect(MrzFieldRecognitionDefectsFixer.fixSex('M'), 'M');
    expect(MrzFieldRecognitionDefectsFixer.fixSex('F'), 'F');
    expect(MrzFieldRecognitionDefectsFixer.fixSex('P'), 'F');
    expect(MrzFieldRecognitionDefectsFixer.fixSex('<'), '<');
  });

  test('fixes country code', () {
    expect(MrzFieldRecognitionDefectsFixer.fixCountryCode('UA'), 'UA');
    expect(MrzFieldRecognitionDefectsFixer.fixCountryCode('D<<'), 'D<<');
    expect(MrzFieldRecognitionDefectsFixer.fixCountryCode('0128'), 'OIZB');
    expect(MrzFieldRecognitionDefectsFixer.fixCountryCode('<'), '<');
  });

  test('fixes names', () {
    expect(
      MrzFieldRecognitionDefectsFixer.fixNames('<SURNAME<<'),
      '<SURNAME<<',
    );
    expect(MrzFieldRecognitionDefectsFixer.fixNames('D<<'), 'D<<');
    expect(MrzFieldRecognitionDefectsFixer.fixNames('0128'), 'OIZB');
    expect(MrzFieldRecognitionDefectsFixer.fixNames('<'), '<');
  });

  test('fixes nationality', () {
    expect(MrzFieldRecognitionDefectsFixer.fixNationality('UA'), 'UA');
    expect(MrzFieldRecognitionDefectsFixer.fixNationality('D<<'), 'D<<');
    expect(MrzFieldRecognitionDefectsFixer.fixNationality('0128'), 'OIZB');
    expect(MrzFieldRecognitionDefectsFixer.fixNationality('<'), '<');
  });
}
