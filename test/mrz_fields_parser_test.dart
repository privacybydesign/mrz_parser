import 'package:collection/collection.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_parser/src/mrz_field_parser.dart';
import 'package:test/test.dart';

void main() {
  test('parses document number', () {
    expect(MrzFieldParser.parseDocumentNumber('FHDJEURI3'), 'FHDJEURI3');
    expect(MrzFieldParser.parseDocumentNumber('R3427<<'), 'R3427');
    expect(MrzFieldParser.parseDocumentNumber('<<<<<'), '');
  });

  test('parses document type', () {
    expect(MrzFieldParser.parseDocumentType('V'), 'V');
    expect(MrzFieldParser.parseDocumentType('P<<'), 'P');
    expect(MrzFieldParser.parseDocumentType('<<<<'), '');
  });

  test('parses country code', () {
    expect(MrzFieldParser.parseCountryCode('UA'), 'UA');
    expect(MrzFieldParser.parseCountryCode('D<<'), 'D');
    expect(MrzFieldParser.parseCountryCode('<<<<'), '');
  });

  test('parses names', () {
    final equality = const DeepCollectionEquality().equals;
    expect(
      equality(
        MrzFieldParser.parseNames('<<SURNAME<<GIVEN<NAMES<<<<<<'),
        ['SURNAME', 'GIVEN NAMES'],
      ),
      isTrue,
    );
    expect(
      equality(
        MrzFieldParser.parseNames('<<SURNAME<<NAME<<<<<<'),
        ['SURNAME', 'NAME'],
      ),
      isTrue,
    );
    expect(
      equality(
        MrzFieldParser.parseNames('<<SURNAME<<<<<<<<<'),
        ['SURNAME', ''],
      ),
      isTrue,
    );
    expect(
      equality(MrzFieldParser.parseNames('<<<<<<<<<<<'), ['', '']),
      isTrue,
    );
  });

  test('parses nationality', () {
    expect(MrzFieldParser.parseNationality('UA'), 'UA');
    expect(MrzFieldParser.parseNationality('D<<'), 'D');
    expect(MrzFieldParser.parseNationality('<<<<'), '');
  });

  test('parses birth date', () {
    expect(MrzFieldParser.parseBirthDate('170213'), DateTime(2017, 02, 13));
    expect(MrzFieldParser.parseBirthDate('190213'), DateTime(2019, 02, 13));
    expect(MrzFieldParser.parseBirthDate('200213'), DateTime(2020, 02, 13));
    expect(MrzFieldParser.parseBirthDate('770213'), DateTime(1977, 02, 13));
  });

  test('parses expiry date', () {
    expect(MrzFieldParser.parseExpiryDate('170213'), DateTime(2017, 02, 13));
    expect(MrzFieldParser.parseExpiryDate('710213'), DateTime(1971, 02, 13));
    expect(MrzFieldParser.parseExpiryDate('700213'), DateTime(2070, 02, 13));
    expect(MrzFieldParser.parseExpiryDate('690213'), DateTime(2069, 02, 13));
  });

  test('parses optional data', () {
    expect(MrzFieldParser.parseOptionalData('FHDJEURI3'), 'FHDJEURI3');
    expect(MrzFieldParser.parseOptionalData('<GDJSKJ34<'), 'GDJSKJ34');
    expect(MrzFieldParser.parseOptionalData('<<<<<'), '');
  });

  test('parses sex', () {
    expect(MrzFieldParser.parseSex('M'), Sex.male);
    expect(MrzFieldParser.parseSex('F'), Sex.female);
    expect(MrzFieldParser.parseSex('<'), Sex.none);
    expect(MrzFieldParser.parseSex('<<<<<'), Sex.none);
  });
}
