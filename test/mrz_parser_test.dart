import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_parser/src/travel_document_mrz_parser.dart';
import 'package:test/test.dart';

void main() {
  void expectResultPassport({
    List<String?>? input,
    PassportMrzResult? expectedOutput,
  }) =>
      expect(PassportMrzParser().parse(input), expectedOutput);

  void expectResultTravelDocument({
    List<String?>? input,
    PassportMrzResult? expectedOutput,
  }) =>
      expect(TravelDocumentMrzParser().parse(input), expectedOutput);

  void expectResultIdCard({
    List<String?>? input,
    PassportMrzResult? expectedOutput,
  }) =>
      expect(IdCardMrzParser().parse(input), expectedOutput);

  void expectExceptionPassportParser<T>({List<String?>? input}) =>
      expect(() => PassportMrzParser().parse(input), throwsA(isA<T>()));

  void expectExceptionIdCardParser<T>({List<String?>? input}) =>
      expect(() => IdCardMrzParser().parse(input), throwsA(isA<T>()));

  void expectExceptionTravelDocumentParser<T>({List<String?>? input}) =>
      expect(() => TravelDocumentMrzParser().parse(input), throwsA(isA<T>()));

  group('invalid input throws $InvalidMrzInputException', () {
    test(
      'null input',
      () => expectExceptionPassportParser<InvalidMrzInputException>(),
    );

    test(
      '1-line null input',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [null],
      ),
    );

    test(
      '1-line input',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: ['0123456789'],
      ),
    );

    test(
      '4-lines input',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '0123456789',
          '0123456789',
          '0123456789',
          '0123456789',
        ],
      ),
    );
    test(
      '3-lines input with 10 symbols',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '0123456789',
          '0123456789',
          '0123456789',
        ],
      ),
    );

    test(
      '3-lines input with 40 symbols',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '0123456789012345678901234567890123456789',
          '0123456789012345678901234567890123456789',
          '0123456789012345678901234567890123456789',
        ],
      ),
    );

    test(
      '2-lines input with 10 symbols',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '0123456789',
          '0123456789',
        ],
      ),
    );

    test(
      '2-lines input with 40 symbols',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '0123456789012345678901234567890123456789',
          '0123456789012345678901234567890123456789',
        ],
      ),
    );

    test(
      '2-lines input with 50 symbols',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '01234567890123456789012345678901234567890123456789',
          '01234567890123456789012345678901234567890123456789',
        ],
      ),
    );

    test(
      '2-lines input with 36 invalid symbols',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '012345678901234567890123456789!asdfg',
          '012345678901234567890123456789{}>,.?',
        ],
      ),
    );

    test(
      '2-lines input with 44 invalid symbols',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '01234567890123456789012345678901234567!asdfg',
          '01234567890123456789012345678901234567{}>,.?',
        ],
      ),
    );

    test(
      '3-lines input with 30 invalid symbols',
      () => expectExceptionPassportParser<InvalidMrzInputException>(
        input: [
          '012345678901234567890123!asdfg',
          '012345678901234567890123{}>,.?',
        ],
      ),
    );
  });

  group('TD1 ID-cards', () {
    test(
      'correct input parses',
      () => expectResultIdCard(
        input: [
          'I<SWE59000002<8198703142391<<<',
          '8703145M1701027SWE<<<<<<<<<<<8',
          'SPECIMEN<<SVEN<<<<<<<<<<<<<<<<',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'I',
          countryCode: 'SWE',
          surnames: 'SPECIMEN',
          givenNames: 'SVEN',
          documentNumber: '59000002',
          nationalityCountryCode: 'SWE',
          birthDate: DateTime(1987, 03, 14),
          sex: Sex.male,
          expiryDate: DateTime(2017, 01, 02),
          personalNumber: '198703142391',
          personalNumber2: '',
        ),
      ),
    );
    test(
      'correct input with long document number (Belgian ID card from PRADO)',
      () => expectResultIdCard(
        input: [
          'IDBEL600001476<9355<<<<<<<<<<<',
          '1301014F2311207UT0130101987390',
          'SPECIMEN<<SPECIMEN<<<<<<<<<<<<',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'ID',
          countryCode: 'BEL',
          surnames: 'SPECIMEN',
          givenNames: 'SPECIMEN',
          documentNumber: '600001476935',
          nationalityCountryCode: 'UTO',
          birthDate: DateTime(2013),
          sex: Sex.female,
          expiryDate: DateTime(2023, 11, 20),
          personalNumber: '',
          personalNumber2: '13010198739',
        ),
      ),
    );

    test(
      'document number check digit does not match throws $InvalidDocumentNumberException',
      () => expectExceptionIdCardParser<InvalidDocumentNumberException>(
        input: [
          'I<SWE59000002<0198703142391<<<',
          '8703145M1701027SWE<<<<<<<<<<<8',
          'SPECIMEN<<SVEN<<<<<<<<<<<<<<<<',
        ],
      ),
    );

    test(
      'birth date check digit does not match throws $InvalidBirthDateException',
      () => expectExceptionIdCardParser<InvalidBirthDateException>(
        input: [
          'I<SWE59000002<8198703142391<<<',
          '8703140M1701027SWE<<<<<<<<<<<8',
          'SPECIMEN<<SVEN<<<<<<<<<<<<<<<<',
        ],
      ),
    );

    test(
      'expiry date check digit does not match throws $InvalidExpiryDateException',
      () => expectExceptionIdCardParser<InvalidExpiryDateException>(
        input: [
          'I<SWE59000002<8198703142391<<<',
          '8703145M1701020SWE<<<<<<<<<<<8',
          'SPECIMEN<<SVEN<<<<<<<<<<<<<<<<',
        ],
      ),
    );

    test(
      'final check digit does not match throws $InvalidMrzValueException',
      () => expectExceptionIdCardParser<InvalidMrzValueException>(
        input: [
          'I<SWE59000002<8198703142391<<<',
          '8703145M1701027SWE<<<<<<<<<<<0',
          'SPECIMEN<<SVEN<<<<<<<<<<<<<<<<',
        ],
      ),
    );
  });

  group('TD2 passport', () {
    test(
      'correct input parses, long document number',
      () => expectResultTravelDocument(
        input: [
          'P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<',
          'C01X00T478D<<6408125F2702283<<<<<<<4',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'P',
          countryCode: 'D',
          surnames: 'MUSTERMANN',
          givenNames: 'ERIKA',
          documentNumber: 'C01X00T47',
          nationalityCountryCode: 'D',
          birthDate: DateTime(1964, 08, 12),
          sex: Sex.female,
          expiryDate: DateTime(2027, 02, 28),
          personalNumber: '',
        ),
      ),
    );

    test(
      'correct input parses, short document number',
      () => expectResultTravelDocument(
        input: [
          'P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<',
          'C01X00<<<6D<<6408125F2702283<<<<<<<8',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'P',
          countryCode: 'D',
          surnames: 'MUSTERMANN',
          givenNames: 'ERIKA',
          documentNumber: 'C01X00',
          nationalityCountryCode: 'D',
          birthDate: DateTime(1964, 08, 12),
          sex: Sex.female,
          expiryDate: DateTime(2027, 02, 28),
          personalNumber: '',
        ),
      ),
    );

    test(
      'document number check digit does not match throws $InvalidDocumentNumberException',
      () => expectExceptionTravelDocumentParser<InvalidDocumentNumberException>(
        input: [
          'P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<',
          'C01X00T470D<<6408125F2702283<<<<<<<4',
        ],
      ),
    );

    test(
      'birth date check digit does not match throws $InvalidBirthDateException',
      () => expectExceptionTravelDocumentParser<InvalidBirthDateException>(
        input: [
          'P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<',
          'C01X00T478D<<6408120F2702283<<<<<<<4',
        ],
      ),
    );

    test(
      'expiry date check digit does not match rthrows $InvalidExpiryDateException',
      () => expectExceptionTravelDocumentParser<InvalidExpiryDateException>(
        input: [
          'P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<',
          'C01X00T478D<<6408125F2702280<<<<<<<4',
        ],
      ),
    );

    test(
      'final check digit does not match throws $InvalidMrzValueException',
      () => expectExceptionTravelDocumentParser<InvalidMrzValueException>(
        input: [
          'P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<',
          'C01X00T478D<<6408125F2702283<<<<<<<0',
        ],
      ),
    );
  });

  group('MRV-B visa', () {
    test(
      'correct input parses',
      () => expectResultTravelDocument(
        input: [
          'VCFINMEIKAELAEINEN<<MATTI<<<<<<<<<<<',
          '0005467<<2RUS7001017M1111019<M901101',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'VC',
          countryCode: 'FIN',
          surnames: 'MEIKAELAEINEN',
          givenNames: 'MATTI',
          documentNumber: '0005467',
          nationalityCountryCode: 'RUS',
          birthDate: DateTime(1970),
          sex: Sex.male,
          expiryDate: DateTime(2011, 11),
          personalNumber: 'M901101',
        ),
      ),
    );

    test(
      'document number check digit does not match throws $InvalidDocumentNumberException',
      () => expectExceptionTravelDocumentParser<InvalidDocumentNumberException>(
        input: [
          'VCFINMEIKAELAEINEN<<MATTI<<<<<<<<<<<',
          '0005467<<0RUS7001017M1111019<M901101',
        ],
      ),
    );

    test(
      'birth date check digit does not match throws $InvalidBirthDateException',
      () => expectExceptionTravelDocumentParser<InvalidBirthDateException>(
        input: [
          'VCFINMEIKAELAEINEN<<MATTI<<<<<<<<<<<',
          '0005467<<2RUS7001010M1111019<M901101',
        ],
      ),
    );

    test(
      'expiry date check digit does not match throws $InvalidExpiryDateException',
      () => expectExceptionTravelDocumentParser<InvalidExpiryDateException>(
        input: [
          'VCFINMEIKAELAEINEN<<MATTI<<<<<<<<<<<',
          '0005467<<2RUS7001017M1111010<M901101',
        ],
      ),
    );
  });

  group('TD3 passport', () {
    test(
      'correct input parses, long document number',
      () => expectResultPassport(
        input: [
          'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
          'L898902C36UTO7408122F1204159ZE184226B<<<<<10',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'P',
          countryCode: 'UTO',
          surnames: 'ERIKSSON',
          givenNames: 'ANNA MARIA',
          documentNumber: 'L898902C3',
          nationalityCountryCode: 'UTO',
          birthDate: DateTime(1974, 08, 12),
          sex: Sex.female,
          expiryDate: DateTime(2012, 04, 15),
          personalNumber: 'ZE184226B',
        ),
      ),
    );

    test(
      'correct input parses, shorter document number',
      () => expectResultPassport(
        input: [
          'P<AUSMCCABE<<NICOLE<SANDRA<<<<<<<<<<<<<<<<<<',
          'L4041765<4AUS8211169F1305218<<<<<<<<<<<<<<00',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'P',
          countryCode: 'AUS',
          surnames: 'MCCABE',
          givenNames: 'NICOLE SANDRA',
          documentNumber: 'L4041765',
          nationalityCountryCode: 'AUS',
          birthDate: DateTime(1982, 11, 16),
          sex: Sex.female,
          expiryDate: DateTime(2013, 05, 21),
          personalNumber: '',
        ),
      ),
    );

    test(
      'correct input parses, no optional data and no check digit',
      () => expectResultPassport(
        input: [
          'I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
          'D231458907UTO7408122F1204159<<<<<<<<<<<<<<<6',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'I',
          countryCode: 'UTO',
          surnames: 'ERIKSSON',
          givenNames: 'ANNA MARIA',
          documentNumber: 'D23145890',
          nationalityCountryCode: 'UTO',
          birthDate: DateTime(1974, 08, 12),
          sex: Sex.female,
          expiryDate: DateTime(2012, 04, 15),
          personalNumber: '',
        ),
      ),
    );

    test(
      'document number check digit does not match throws $InvalidDocumentNumberException',
      () => expectExceptionPassportParser<InvalidDocumentNumberException>(
        input: [
          'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
          'L898902C37UTO7408122F1204159ZE184226B<<<<<10',
        ],
      ),
    );

    test(
      'birth date check digit does not match throws $InvalidBirthDateException',
      () => expectExceptionPassportParser<InvalidBirthDateException>(
        input: [
          'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
          'L898902C36UTO7408120F1204159ZE184226B<<<<<10',
        ],
      ),
    );

    test(
      'expiry date check digit does not match throws $InvalidExpiryDateException',
      () => expectExceptionPassportParser<InvalidExpiryDateException>(
        input: [
          'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
          'L898902C36UTO7408122F1204150ZE184226B<<<<<10',
        ],
      ),
    );

    test(
      'personal number check digit does not match throws $InvalidOptionalDataException',
      () => expectExceptionPassportParser<InvalidOptionalDataException>(
        input: [
          'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
          'L898902C36UTO7408122F1204159ZE184226B<<<<<00',
        ],
      ),
    );

    test(
      'final check digit does not match throws $InvalidMrzValueException',
      () => expectExceptionPassportParser<InvalidMrzValueException>(
        input: [
          'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
          'L898902C36UTO7408122F1204159ZE184226B<<<<<19',
        ],
      ),
    );
  });

  group('MRV-A visa', () {
    test(
      'correct input parses',
      () => expectResultPassport(
        input: [
          'VNUSATRAVELER<<HAPPY<<<<<<<<<<<<<<<<<<<<<<<<',
          '12345678<8KOR5001013F1304071B3SE000IL4243934',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'VN',
          countryCode: 'USA',
          surnames: 'TRAVELER',
          givenNames: 'HAPPY',
          documentNumber: '12345678',
          nationalityCountryCode: 'KOR',
          birthDate: DateTime(1950),
          sex: Sex.female,
          expiryDate: DateTime(2013, 04, 07),
          personalNumber: 'B3SE000IL4243934',
        ),
      ),
    );

    test(
      'document number check digit does not match throws $InvalidDocumentNumberException',
      () => expectExceptionPassportParser<InvalidDocumentNumberException>(
        input: [
          'VNUSATRAVELER<<HAPPY<<<<<<<<<<<<<<<<<<<<<<<<',
          '12345678<0KOR5001013F1304071B3SE000IL4243934',
        ],
      ),
    );

    test(
      'birth date check digit does not match throws $InvalidBirthDateException',
      () => expectExceptionPassportParser<InvalidBirthDateException>(
        input: [
          'VNUSATRAVELER<<HAPPY<<<<<<<<<<<<<<<<<<<<<<<<',
          '12345678<8KOR5001010F1304071B3SE000IL4243934',
        ],
      ),
    );

    test(
      'expiry date check digit does not match throws $InvalidExpiryDateException',
      () => expectExceptionPassportParser<InvalidExpiryDateException>(
        input: [
          'VNUSATRAVELER<<HAPPY<<<<<<<<<<<<<<<<<<<<<<<<',
          '12345678<8KOR5001013F1304070B3SE000IL4243934',
        ],
      ),
    );
  });

  group('French ID', () {
    test(
      'correct input parses',
      () => expectResultTravelDocument(
        input: [
          'IDFRABERTHIER<<<<<<<<<<<<<<<<<<<<<<<',
          '8806923102858CORINNE<<<<<<<6512068F6',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'ID',
          countryCode: 'FRA',
          surnames: 'BERTHIER',
          givenNames: 'CORINNE',
          documentNumber: '880692310285',
          nationalityCountryCode: 'FRA',
          birthDate: DateTime(1965, 12, 06),
          sex: Sex.female,
          expiryDate: DateTime(1998, 06),
          personalNumber: '',
          personalNumber2: '923',
        ),
      ),
    );

    test(
      'correct input with department and office in first line parses',
      () => expectResultTravelDocument(
        input: [
          'IDFRABERTHIER<<<<<<<<<<<<<<<<<923255',
          '8806923102858CORINNE<<<<<<<6512068F2',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'ID',
          countryCode: 'FRA',
          surnames: 'BERTHIER',
          givenNames: 'CORINNE',
          documentNumber: '880692310285',
          nationalityCountryCode: 'FRA',
          birthDate: DateTime(1965, 12, 06),
          sex: Sex.female,
          expiryDate: DateTime(1998, 06),
          personalNumber: '923255',
          personalNumber2: '923',
        ),
      ),
    );

    test(
      'correct input with multiple names parses',
      () => expectResultTravelDocument(
        input: [
          'IDFRALOISEAU<<<<<<<<<<<<<<<<<<<<<<<<',
          '970675K002774HERVE<<DJAMEL<7303216M4',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'ID',
          countryCode: 'FRA',
          surnames: 'LOISEAU',
          givenNames: 'HERVE DJAMEL',
          documentNumber: '970675K00277',
          nationalityCountryCode: 'FRA',
          birthDate: DateTime(1973, 03, 21),
          sex: Sex.male,
          expiryDate: DateTime(2007, 06),
          personalNumber: '',
          personalNumber2: '75K',
        ),
      ),
    );

    test(
      'issued before Jan 2014 valid for 10 years',
      () => expectResultTravelDocument(
        input: [
          'IDFRABERTHIER<<<<<<<<<<<<<<<<<<<<<<<',
          '8806923102858CORINNE<<<<<<<6512068F6',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'ID',
          countryCode: 'FRA',
          surnames: 'BERTHIER',
          givenNames: 'CORINNE',
          documentNumber: '880692310285',
          nationalityCountryCode: 'FRA',
          birthDate: DateTime(1965, 12, 06),
          sex: Sex.female,
          expiryDate: DateTime(1998, 06),
          personalNumber: '',
          personalNumber2: '923',
        ),
      ),
    );

    test(
      'issued after Jan 2014 for adult valid for 15 years',
      () => expectResultTravelDocument(
        input: [
          'IDFRABERTHIER<<<<<<<<<<<<<<<<<<<<<<<',
          '1506923102850CORINNE<<<<<<<6512068F2',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'ID',
          countryCode: 'FRA',
          surnames: 'BERTHIER',
          givenNames: 'CORINNE',
          documentNumber: '150692310285',
          nationalityCountryCode: 'FRA',
          birthDate: DateTime(1965, 12, 06),
          sex: Sex.female,
          expiryDate: DateTime(2030, 06),
          personalNumber: '',
          personalNumber2: '923',
        ),
      ),
    );

    test(
      'issued after Jan 2014 for minor valid for 10 years',
      () => expectResultTravelDocument(
        input: [
          'IDFRABERTHIER<<<<<<<<<<<<<<<<<<<<<<<',
          '1506923102850CORINNE<<<<<<<0012061F6',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'ID',
          countryCode: 'FRA',
          surnames: 'BERTHIER',
          givenNames: 'CORINNE',
          documentNumber: '150692310285',
          nationalityCountryCode: 'FRA',
          birthDate: DateTime(2000, 12, 06),
          sex: Sex.female,
          expiryDate: DateTime(2025, 06),
          personalNumber: '',
          personalNumber2: '923',
        ),
      ),
    );

    test(
      'document number check digit does not match throws $InvalidDocumentNumberException',
      () => expectExceptionTravelDocumentParser<InvalidDocumentNumberException>(
        input: [
          'IDFRABERTHIER<<<<<<<<<<<<<<<<<<<<<<<',
          '8806923102850CORINNE<<<<<<<6512068F6',
        ],
      ),
    );

    test(
      'birth date check digit does not match throws $InvalidBirthDateException',
      () => expectExceptionTravelDocumentParser<InvalidBirthDateException>(
        input: [
          'IDFRABERTHIER<<<<<<<<<<<<<<<<<<<<<<<',
          '8806923102858CORINNE<<<<<<<6512060F6',
        ],
      ),
    );

    test(
      'final check digit does not match throws $InvalidMrzValueException',
      () => expectExceptionTravelDocumentParser<InvalidMrzValueException>(
        input: [
          'IDFRABERTHIER<<<<<<<<<<<<<<<<<<<<<<<',
          '8806923102858CORINNE<<<<<<<6512068F0',
        ],
      ),
    );
  });

  group('German ID card', () {
    test(
      'correct input parses',
      () => expectResultIdCard(
        input: [
          'IDD<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<',
          '1220001518D<<6408125<1110078<<<<<<<0',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'ID',
          countryCode: 'D',
          surnames: 'MUSTERMANN',
          givenNames: 'ERIKA',
          documentNumber: '122000151',
          nationalityCountryCode: 'D',
          birthDate: DateTime(1964, 08, 12),
          sex: Sex.none,
          expiryDate: DateTime(2011, 10, 07),
          personalNumber: '',
        ),
      ),
    );
  });

  group('tryParse', () {
    test(
      'invalid input returns null',
      () => expect(PassportMrzParser().tryParse(null), null),
    );

    test(
      'correct input parses',
      () => expect(
        PassportMrzParser().tryParse([
          'VNUSATRAVELER<<HAPPY<<<<<<<<<<<<<<<<<<<<<<<<',
          '12345678<8KOR5001013F1304071B3SE000IL4243934',
        ]),
        PassportMrzResult(
          documentType: 'VN',
          countryCode: 'USA',
          surnames: 'TRAVELER',
          givenNames: 'HAPPY',
          documentNumber: '12345678',
          nationalityCountryCode: 'KOR',
          birthDate: DateTime(1950),
          sex: Sex.female,
          expiryDate: DateTime(2013, 04, 07),
          personalNumber: 'B3SE000IL4243934',
        ),
      ),
    );
  });

  group('Dutch passport O vs 0 edge case', () {
    // Dutch passports never contain the digit '0' (zero), only the letter 'O'
    // to avoid confusion. This test demonstrates that OCR errors reading 'O' as '0'
    // cause check digit validation failures.
    test(
      'Dutch passport with O in document number should parse correctly',
      () => expectResultPassport(
        input: [
          'P<NLDDEVRIES<<JAN<<<<<<<<<<<<<<<<<<<<<<<<<<<',
          'NPOBR4N678NLD8501019M3012316<<<<<<<<<<<<<<08',
        ],
        expectedOutput: PassportMrzResult(
          documentType: 'P',
          countryCode: 'NLD',
          surnames: 'DEVRIES',
          givenNames: 'JAN',
          documentNumber: 'NPOBR4N67',
          nationalityCountryCode: 'NLD',
          birthDate: DateTime(1985),
          sex: Sex.male,
          expiryDate: DateTime(2030, 12, 31),
          personalNumber: '',
        ),
      ),
    );

    test(
      'Dutch passport with OCR error (0 instead of O) should auto-correct with tryParse',
      () {
        // This MRZ has '0' (zero) instead of 'O' in position 3 of document number
        // NP0BR4N67 instead of NPOBR4N67
        // The check digit (8) is correct for NPOBR4N67, but wrong for NP0BR4N67
        final result = PassportMrzParser().tryParse([
          'P<NLDDEVRIES<<JAN<<<<<<<<<<<<<<<<<<<<<<<<<<<',
          'NP0BR4N678NLD8501019M3012316<<<<<<<<<<<<<<08',
        ]);

        // The library now auto-corrects '0' to 'O' in document numbers
        expect(result, isNotNull);
        expect(result!.documentNumber, 'NPOBR4N67');
      },
    );

    test(
      'Dutch passport with OCR error (0 instead of O) should auto-correct',
      () {
        // This test demonstrates the missing functionality
        // The library SHOULD auto-correct '0' to 'O' in Dutch passport numbers
        // because Dutch passports never contain the digit '0'
        expectResultPassport(
          input: [
            'P<NLDDEVRIES<<JAN<<<<<<<<<<<<<<<<<<<<<<<<<<<',
            'NP0BR4N678NLD8501019M3012316<<<<<<<<<<<<<<08',
          ],
          expectedOutput: PassportMrzResult(
            documentType: 'P',
            countryCode: 'NLD',
            surnames: 'DEVRIES',
            givenNames: 'JAN',
            documentNumber:
                'NPOBR4N67', // Should be corrected from NP0BR4N67 to NPOBR4N67
            nationalityCountryCode: 'NLD',
            birthDate: DateTime(1985),
            sex: Sex.male,
            expiryDate: DateTime(2030, 12, 31),
            personalNumber: '',
          ),
        );
      },
    );

    test(
      'Document number with O instead of 0 should auto-correct',
      () {
        // Test the opposite case: O should be corrected to 0
        // Based on the standard ERIKSSON example with '0' replaced by 'O'
        expectResultPassport(
          input: [
            'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
            'L8989O2C36UTO7408122F1204159ZE184226B<<<<<10',
          ],
          expectedOutput: PassportMrzResult(
            documentType: 'P',
            countryCode: 'UTO',
            surnames: 'ERIKSSON',
            givenNames: 'ANNA MARIA',
            documentNumber:
                'L898902C3', // Should be corrected from L8989O2C3 to L898902C3
            nationalityCountryCode: 'UTO',
            birthDate: DateTime(1974, 08, 12),
            sex: Sex.female,
            expiryDate: DateTime(2012, 04, 15),
            personalNumber: 'ZE184226B',
          ),
        );
      },
    );

    test(
      'Document number with invalid check digit should still fail after O/0 correction attempts',
      () {
        // Test that we still throw exception when neither O->0 nor 0->O fixes the check digit
        expect(
          () => PassportMrzParser().parse([
            'P<NLDDEVRIES<<JAN<<<<<<<<<<<<<<<<<<<<<<<<<<<',
            'NP0BR4N679NLD8501019M3012316<<<<<<<<<<<<<<08', // Wrong check digit (9 instead of 8)
          ]),
          throwsA(isA<InvalidDocumentNumberException>()),
        );
      },
    );
  });
}
