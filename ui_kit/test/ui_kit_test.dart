import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('theme', () {
    test('light and dark are Material 3 with semantic colors', () {
      for (final t in [AppTheme.light(), AppTheme.dark()]) {
        expect(t.useMaterial3, isTrue);
        expect(t.extension<AppSemanticColors>(), isNotNull);
      }
      expect(AppTheme.dark().brightness, Brightness.dark);
    });
  });

  testWidgets('every component renders in light and dark without errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      await tester.pumpWidget(
        _app(
          theme: theme,
          Column(
            children: [
              for (final v in AppButtonVariant.values)
                AppButton(
                  label: v.name,
                  variant: v,
                  onPressed: () {},
                  icon: Icons.add,
                ),
              const AppButton(
                label: 'loading',
                onPressed: null,
                isLoading: true,
              ),
              for (final v in AppIconButtonVariant.values)
                AppIconButton(
                  icon: Icons.favorite,
                  variant: v,
                  onPressed: () {},
                ),
              const AppTextField(label: 'Tên'),
              AppCheckbox(value: true, onChanged: (_) {}, label: 'Đồng ý'),
              AppRadioGroup<int>(
                value: 1,
                onChanged: (_) {},
                options: const [
                  AppRadioOption(value: 1, label: 'A'),
                  AppRadioOption(value: 2, label: 'B'),
                ],
              ),
              AppSwitch(
                value: true,
                onChanged: (_) {},
                label: 'Thông báo',
                showIcon: true,
              ),
              const AppBadge(count: 120, child: Icon(Icons.mail)),
              for (final tone in AppTone.values)
                AppStatusBadge(label: tone.name, tone: tone),
              const AppImage(null, width: 40, height: 40),
              const AppIcon(Icons.home),
              const AppDivider(inset: true),
              const AppAvatar(name: 'Nguyễn Văn An'),
              const AppLoading(message: 'Đang tải'),
              const AppLoading.linear(),
              const AppOtpInput(autofocus: false),
              const AppSearchBar(),
              AppDropdown<int>(
                label: 'Chọn',
                value: 1,
                onChanged: (_) {},
                items: const [AppDropdownItem(value: 1, label: 'Một')],
              ),
              const AppListTile(
                title: 'Hồ sơ',
                leadingIcon: Icons.person,
                showChevron: true,
              ),
              const SizedBox(height: 300, child: AppEmptyState(title: 'Trống')),
              const AppPhoneInput(),
              for (final v in AppCardVariant.values)
                AppCard(variant: v, child: const Text('card')),
              const SizedBox(
                width: 200,
                child: AppProductCard(
                  name: 'Vitamin C 500mg',
                  price: '120.000 ₫',
                  originalPrice: '150.000 ₫',
                  tag: '-20%',
                ),
              ),
              AppOrderCard(
                code: '#DH001',
                statusLabel: 'Đã giao',
                statusTone: AppTone.success,
                date: '14/11/2026',
                total: '320.000 ₫',
                itemSummary: '3 sản phẩm',
                actions: [
                  AppButton.outlined(label: 'Mua lại', onPressed: () {}),
                ],
              ),
              const FadeInAnimation(child: Text('fade')),
              const SlideInAnimation(child: Text('slide')),
              const ScaleInAnimation(child: Text('scale')),
            ],
          ),
        ),
      );
      // Indeterminate spinners never settle; advance past entrance animations.
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('AppButton shows spinner and ignores taps while loading', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(AppButton(label: 'Gửi', onPressed: () => taps++, isLoading: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Gửi'), findsNothing);
    await tester.tap(find.byType(FilledButton));
    expect(taps, 0);
  });

  testWidgets('AppTextField password toggle', (tester) async {
    await tester.pumpWidget(
      _app(const AppTextField(label: 'Mật khẩu', obscureText: true)),
    );
    EditableText field() => tester.widget(find.byType(EditableText));
    expect(field().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });

  testWidgets('AppCheckbox label toggles value', (tester) async {
    bool? value = false;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => AppCheckbox(
            value: value,
            label: 'Đồng ý điều khoản',
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Đồng ý điều khoản'));
    expect(value, isTrue);
  });

  testWidgets('AppRadioGroup selects tapped option', (tester) async {
    int? value = 1;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => AppRadioGroup<int>(
            value: value,
            onChanged: (v) => setState(() => value = v),
            options: const [
              AppRadioOption(value: 1, label: 'Nam'),
              AppRadioOption(value: 2, label: 'Nữ'),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Nữ'));
    expect(value, 2);
  });

  testWidgets('AppOtpInput accepts digits only and completes', (tester) async {
    String? completed;
    await tester.pumpWidget(
      _app(AppOtpInput(length: 4, onCompleted: (v) => completed = v)),
    );
    await tester.enterText(find.byType(TextField), '12a34');
    await tester.pump();
    expect(completed, '1234');
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('AppForm only submits when valid', (tester) async {
    var submitted = 0;
    await tester.pumpWidget(
      _app(
        AppForm(
          onSubmit: () => submitted++,
          children: [
            AppTextField(
              label: 'Tên',
              validator: (v) => (v ?? '').isEmpty ? 'Bắt buộc' : null,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    expect(submitted, 0);
    expect(find.text('Bắt buộc'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'An');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    expect(submitted, 1);
  });

  testWidgets('AppAvatar shows initials from first and last name', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AppAvatar(name: 'nguyễn văn an')));
    expect(find.text('NA'), findsOneWidget);
  });

  test('AppPhoneInput.toE164', () {
    expect(AppPhoneInput.toE164('0912 345 678'), '+84912345678');
    expect(AppPhoneInput.toE164('912345678'), '+84912345678');
  });

  testWidgets('AppDialog.confirm returns true on confirm', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await AppDialog.confirm(context, title: 'Xoá?'),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('AppSnackbar shows message with tone icon', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => AppSnackbar.success(context, 'Đã lưu'),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.text('Đã lưu'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('AppBottomNav reports tapped index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 0,
            onTap: (i) => tapped = i,
            items: const [
              AppNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Trang chủ',
              ),
              AppNavItem(
                icon: Icons.notifications_outlined,
                label: 'Thông báo',
                badgeCount: 3,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Thông báo'));
    expect(tapped, 1);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('AppDrawer renders items with badges', (tester) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppDrawer(
            selectedIndex: 0,
            onSelected: (i) => selected = i,
            sections: const [
              AppDrawerSection(
                items: [
                  AppDrawerItem(
                    icon: Icons.inbox,
                    label: 'Hộp thư',
                    badge: '24',
                  ),
                ],
              ),
              AppDrawerSection(
                title: 'Khác',
                items: [AppDrawerItem(icon: Icons.settings, label: 'Cài đặt')],
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('24'), findsOneWidget);
    await tester.tap(find.text('Cài đặt'));
    expect(selected, 1);
  });
}
