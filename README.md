# mrz_parser (Dart/Flutter) 
[![Coverage Status](https://coveralls.io/repos/github/foxanna/mrz_parser/badge.svg?branch=master)](https://coveralls.io/github/foxanna/mrz_parser?branch=master)

Parse MRZ (Machine Readable Zone) from identity documents. Heavily
inspired by [QKMRZParser](https://github.com/Mattijah/QKMRZParser).

### Supported formats:
* TD1 - Machine Readable Official Travel Documents (3 lines × 30 characters)
* TD2 - Machine Readable Official Travel Documents (2 lines × 36 characters)
* TD3 - Machine Readable Passports (2 lines × 44 characters)
* MRV-A - Machine Readable Visas Type A (2 lines × 44 characters)
* MRV-B - Machine Readable Visas Type B (2 lines × 36 characters)

### Format examples

All formats follow the [ICAO Doc 9303](https://www.icao.int/publications/pages/publication.aspx?docnum=9303) standard for Machine Readable Travel Documents.

#### TD1 (3 lines × 30 characters)
Used for ID cards and similar sized documents. Defined in [ICAO Doc 9303, Part 5](https://www2023.icao.int/publications/Documents/9303_p5_cons_en.pdf).

```
I<UTOD231458907<<<<<<<<<<<<<<<
7408122F1204159UTO<<<<<<<<<<<6
ERIKSSON<<ANNA<MARIA<<<<<<<<<<
```

#### TD2 (2 lines × 36 characters)
Used for ID cards and other official travel documents. Defined in [ICAO Doc 9303, Part 6](https://www2023.icao.int/publications/Documents/9303_p6_cons_en.pdf).

```
I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
D231458907UTO7408122F1204159<<<<<<<6
```

#### TD3 (2 lines × 44 characters)
Used for passports. Defined in [ICAO Doc 9303, Part 4](https://www2023.icao.int/publications/Documents/9303_p4_cons_en.pdf).

```
P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
L898902C36UTO7408122F1204159ZE184226B<<<<<10
```

#### MRV-A (2 lines × 44 characters)
Used for visa format A (full page). Defined in [ICAO Doc 9303, Part 7](https://www2023.icao.int/publications/Documents/9303_p7_cons_en.pdf).

```
V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
L898902C36UTO7408122F1204159ZE184226B<<<<<<
```

#### MRV-B (2 lines × 36 characters)
Used for visa format B (sticker). Defined in [ICAO Doc 9303, Part 7](https://www2023.icao.int/publications/Documents/9303_p7_cons_en.pdf).

```
V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
L898902C36UTO7408122F12041596<<<<<<<
```

## Usage

### Import the package
Add to `pubspec.yaml`
```yaml
dependencies:
    mrz_parser: ^2.0.0
```

### Parse MRZ
```dart
final mrz = [
  'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
  'L898902C36UTO7408122F1204159ZE184226B<<<<<10'
];

final result = MRZParser.tryParse(mrz);

// Alternatively use parse and catch MRZException descendants
try {
  final result = MRZParser.parse(mrz);
} on MRZException catch(e) {
  print(e);
}
```

### Parse Driver License
```dart
final driverLicense = [
  'D1NLD11234567890ABCDEFGHIJKLM7'
];

final result = DriverLicenseParser.tryParse(driverLicense);

// Alternatively use parse and catch MRZException descendants
try {
  final result = DriverLicenseParser.parse(driverLicense);
  print(result.documentNumber); // 1234567890
  print(result.countryCode); // NLD
} on MRZException catch(e) {
  print(e);
}
```

## Benchmarks

Performance benchmarks for parsing different MRZ formats:

| Format | Type | Average Parse Time |
|--------|------|-------------------|
| TD3 | Passport | ~103.34 µs |
| TD2 | ID Card | ~13.81 µs |
| TD1 | ID Card | ~15.67 µs |
| Driver License | Driver License | ~16.33 µs |

Run benchmarks yourself:
```bash
dart run benchmark/mrz_parser_benchmark.dart
```

## Authors
* [Anna Domashych](https://github.com/foxanna/)
* [Oleksandr Leuschenko](https://github.com/olexale/)

## License
`mrz_parser` is released under a [MIT License](https://opensource.org/licenses/MIT). See `LICENSE` for details.
