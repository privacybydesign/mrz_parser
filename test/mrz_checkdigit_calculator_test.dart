import 'package:mrz_parser/src/mrz_checkdigit_calculator.dart';
import 'package:test/test.dart';

void main() {
  test('check empty input', () {
    expect(MrzCheckDigitCalculator.getCheckDigit('<<<'), 0);
  });

  test('check document number', () {
    expect(MrzCheckDigitCalculator.getCheckDigit('L898902C3'), 6);
    expect(MrzCheckDigitCalculator.getCheckDigit('C01X00T47'), 8);
    expect(MrzCheckDigitCalculator.getCheckDigit('990000516'), 4);
    expect(MrzCheckDigitCalculator.getCheckDigit('M5127939<'), 2);
    expect(MrzCheckDigitCalculator.getCheckDigit('L4041765<'), 4);
  });

  test('check birth date', () {
    expect(MrzCheckDigitCalculator.getCheckDigit('680229'), 5);
    expect(MrzCheckDigitCalculator.getCheckDigit('640812'), 5);
    expect(MrzCheckDigitCalculator.getCheckDigit('740812'), 2);
  });
}
