import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Calendar Date Formatting Safety', () {
    test('should format regular dates consistently as YYYY-MM-DD', () {
      final date = DateTime(2026, 10, 22);
      final formatted = DateFormat('yyyy-MM-dd').format(date);
      expect(formatted, '2026-10-22');
    });

    test('should format leap day without date boundary shifts', () {
      final leapDay = DateTime(2024, 2, 29);
      final formatted = DateFormat('yyyy-MM-dd').format(leapDay);
      expect(formatted, '2024-02-29');
    });

    test('should format month boundaries accurately (Oct 31 -> Nov 01)', () {
      final oct31 = DateTime(2026, 10, 31);
      final nov01 = DateTime(2026, 11, 1);

      expect(DateFormat('yyyy-MM-dd').format(oct31), '2026-10-31');
      expect(DateFormat('yyyy-MM-dd').format(nov01), '2026-11-01');
    });

    test('should format year rollover accurately (Dec 31 -> Jan 01)', () {
      final dec31 = DateTime(2026, 12, 31);
      final jan01 = DateTime(2027, 1, 1);

      expect(DateFormat('yyyy-MM-dd').format(dec31), '2026-12-31');
      expect(DateFormat('yyyy-MM-dd').format(jan01), '2027-01-01');
    });
  });
}
