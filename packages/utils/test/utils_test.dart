import 'package:flutter_test/flutter_test.dart';
import 'package:utils/utils.dart';

void main() {
  group('StringX', () {
    test('removes Vietnamese diacritics', () {
      expect('Đặng Thị Hà ước mơ'.withoutDiacritics, 'Dang Thi Ha uoc mo');
      expect('Nguyễn Văn An'.containsIgnoringAccents('van an'), isTrue);
    });
    test('initials, masked, titleCase', () {
      expect('Nguyễn Văn An'.initials(), 'NA');
      expect('0912345678'.masked(), '******5678');
      expect('nguyễn   văn a'.titleCase, 'Nguyễn Văn A');
      expect('  '.isBlank, isTrue);
      expect((null as String?).nullIfBlank, isNull);
    });
  });

  group('PhoneFormatter', () {
    test('normalizes and validates', () {
      expect(PhoneFormatter.toLocal('+84 912-345-678'), '0912345678');
      expect(PhoneFormatter.toE164('0912345678'), '+84912345678');
      expect(PhoneFormatter.isValidVnMobile('84912345678'), isTrue);
      expect(PhoneFormatter.isValidVnMobile('0212345678'), isFalse);
      expect(PhoneFormatter.display('0912345678'), '0912 345 678');
    });
  });

  group('Validators', () {
    test('compose returns first error', () {
      final v = Validators.compose([
        Validators.required(message: 'req'),
        Validators.vnPhone(message: 'phone'),
      ]);
      expect(v(''), 'req');
      expect(v('123'), 'phone');
      expect(v('0912345678'), isNull);
    });
    test('password, otp, optional email', () {
      expect(Validators.password()('Abcdefg1'), isNull);
      expect(Validators.password()('abcdefgh'), isNotNull);
      expect(Validators.otp()('123456'), isNull);
      expect(Validators.otp()('12a456'), isNotNull);
      expect(Validators.optional(Validators.email())(''), isNull);
      expect(Validators.email()('a@b.vn'), isNull);
    });
  });

  test('CurrencyFormatter', () {
    expect(CurrencyFormatter.vnd(150000), contains('150.000'));
    expect(CurrencyFormatter.parse('150.000 ₫'), 150000);
  });

  test('DateTimeX.age', () {
    expect(DateTime(2000, 6, 15).age(at: DateTime(2026, 6, 14)), 25);
    expect(DateTime(2000, 6, 15).age(at: DateTime(2026, 6, 15)), 26);
  });

  test('IterableX', () {
    expect([1, 2, 3, 4, 5].chunked(2).toList(), [
      [1, 2],
      [3, 4],
      [5],
    ]);
    expect([1, 2, 3].separatedBy(0).toList(), [1, 0, 2, 0, 3]);
    expect(['a', 'bb', 'cc'].groupBy((s) => s.length), {
      1: ['a'],
      2: ['bb', 'cc'],
    });
  });

  test('retry stops after maxAttempts', () async {
    var calls = 0;
    await expectLater(
      retry<void>(() async {
        calls++;
        throw Exception('x');
      }, initialDelay: Duration.zero),
      throwsException,
    );
    expect(calls, 3);
  });
}
