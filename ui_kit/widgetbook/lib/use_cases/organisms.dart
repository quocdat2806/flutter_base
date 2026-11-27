import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

import 'helpers.dart';

final organismsFolder = WidgetbookFolder(
  name: 'Organisms',
  children: [
    component('AppAppBar', {
      'Playground': (context) {
        final k = context.knobs;
        final title = k.string(label: 'Title', initialValue: 'Lịch hẹn');
        final center = k.boolean(label: 'Center', initialValue: false);
        final actions = [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ];
        return Scaffold(
          appBar: center
              ? AppAppBar.center(
                  title: title,
                  actions: actions,
                  leading: const BackButton(),
                )
              : AppAppBar(
                  title: title,
                  actions: actions,
                  leading: const BackButton(),
                ),
          body: const SizedBox.shrink(),
        );
      },
    }),
    component('AppBottomNav', {
      'Default': (context) {
        final labelBehavior = context.knobs.object.dropdown(
          label: 'Labels',
          options: NavigationDestinationLabelBehavior.values,
          labelBuilder: (v) => v.name,
        );
        return Stateful<int>(
          initial: 0,
          builder: (context, index, set) => Scaffold(
            body: Center(child: Text('Tab $index')),
            bottomNavigationBar: AppBottomNav(
              currentIndex: index,
              onTap: set,
              labelBehavior: labelBehavior,
              items: const [
                AppNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Trang chủ',
                ),
                AppNavItem(
                  icon: Icons.event_outlined,
                  selectedIcon: Icons.event,
                  label: 'Lịch hẹn',
                  showDot: true,
                ),
                AppNavItem(
                  icon: Icons.chat_bubble_outline,
                  selectedIcon: Icons.chat_bubble,
                  label: 'Tin nhắn',
                  badgeCount: 12,
                ),
                AppNavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Tài khoản',
                ),
              ],
            ),
          ),
        );
      },
    }),
    component('AppDrawer', {
      'Default': (context) => Stateful<int?>(
        initial: 0,
        builder: (context, index, set) => Row(
          children: [
            SizedBox(
              width: 360,
              child: AppDrawer(
                selectedIndex: index,
                onSelected: set,
                header: const Padding(
                  padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
                  child: Row(
                    children: [
                      AppAvatar(name: 'Nguyễn An'),
                      SizedBox(width: 12),
                      Text('Nguyễn An'),
                    ],
                  ),
                ),
                sections: const [
                  AppDrawerSection(
                    items: [
                      AppDrawerItem(
                        icon: Icons.inbox_outlined,
                        selectedIcon: Icons.inbox,
                        label: 'Hộp thư',
                        badge: '24',
                      ),
                      AppDrawerItem(
                        icon: Icons.event_outlined,
                        selectedIcon: Icons.event,
                        label: 'Lịch hẹn',
                      ),
                    ],
                  ),
                  AppDrawerSection(
                    title: 'Khác',
                    items: [
                      AppDrawerItem(
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings,
                        label: 'Cài đặt',
                      ),
                      AppDrawerItem(
                        icon: Icons.help_outline,
                        label: 'Trợ giúp',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: Center(child: Text('Mục $index'))),
          ],
        ),
      ),
    }),
    component('AppCard', {
      'Variants': (context) => Showcase(
        children: [
          for (final v in AppCardVariant.values)
            AppCard(
              variant: v,
              onTap: () {},
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Card ${v.name}'),
                subtitle: const Text('Material 3 card'),
              ),
            ),
        ],
      ),
    }),
    component('AppForm', {
      'Login': (context) => Showcase(
        children: [
          AppForm(
            submitLabel: 'Đăng nhập',
            isLoading: context.knobs.boolean(
              label: 'Loading',
              initialValue: false,
            ),
            onSubmit: () => log('form submitted'),
            children: [
              AppPhoneInput(
                validator: (v) =>
                    (v ?? '').length < 9 ? 'Số điện thoại không hợp lệ' : null,
              ),
              AppTextField(
                label: 'Mật khẩu',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (v) =>
                    (v ?? '').length < 6 ? 'Tối thiểu 6 ký tự' : null,
              ),
            ],
          ),
        ],
      ),
    }),
    component('AppProductCard', {
      'Playground': (context) {
        final k = context.knobs;
        return Center(
          child: SizedBox(
            width: k.double.slider(
              label: 'Width',
              initialValue: 200,
              min: 150,
              max: 320,
            ),
            child: AppProductCard(
              name: k.string(
                label: 'Name',
                initialValue: 'Vitamin C 500mg hộp 100 viên',
              ),
              subtitle: k.stringOrNull(
                label: 'Subtitle',
                initialValue: 'DHG Pharma',
              ),
              price: k.string(label: 'Price', initialValue: '120.000 ₫'),
              originalPrice: k.stringOrNull(
                label: 'Original price',
                initialValue: '150.000 ₫',
              ),
              tag: k.stringOrNull(label: 'Tag', initialValue: '-20%'),
              imageUrl: sampleImage,
              onTap: () {},
              onAddToCart: k.boolean(label: 'Add to cart', initialValue: true)
                  ? () {}
                  : null,
            ),
          ),
        );
      },
      'Grid': (context) => Material(
        color: context.colors.surface,
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
          children: [
            for (var i = 0; i < 6; i++)
              AppProductCard(
                name: 'Sản phẩm số ${i + 1}',
                price: '${(i + 1) * 45}.000 ₫',
                imageUrl: 'https://picsum.photos/seed/p$i/400/400',
                tag: i.isEven ? '-${10 + i}%' : null,
                onAddToCart: () {},
              ),
          ],
        ),
      ),
    }),
    component('AppOrderCard', {
      'Playground': (context) {
        final k = context.knobs;
        final tone = k.object.dropdown(
          label: 'Status tone',
          options: AppTone.values,
          initialOption: AppTone.warning,
          labelBuilder: (v) => v.name,
        );
        return Showcase(
          children: [
            AppOrderCard(
              code: k.string(label: 'Code', initialValue: '#DH240512'),
              statusLabel: k.string(label: 'Status', initialValue: 'Đang giao'),
              statusTone: tone,
              date: k.stringOrNull(
                label: 'Date',
                initialValue: '14/11/2026 · 09:30',
              ),
              itemSummary: k.stringOrNull(
                label: 'Summary',
                initialValue: '3 sản phẩm',
              ),
              total: k.stringOrNull(label: 'Total', initialValue: '320.000 ₫'),
              leading: const AppAvatar(icon: Icons.receipt_long_outlined),
              onTap: () {},
              actions: k.boolean(label: 'Actions', initialValue: true)
                  ? [
                      AppButton.outlined(
                        label: 'Huỷ đơn',
                        size: AppButtonSize.small,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: 'Mua lại',
                        size: AppButtonSize.small,
                        onPressed: () {},
                      ),
                    ]
                  : null,
            ),
          ],
        );
      },
    }),
  ],
);
