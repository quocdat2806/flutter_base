import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

import 'helpers.dart';

final moleculesFolder = WidgetbookFolder(
  name: 'Molecules',
  children: [
    component('AppOtpInput', {
      'Playground': (context) {
        final k = context.knobs;
        return Center(
          child: AppOtpInput(
            key: UniqueKey(),
            length: k.int.slider(
              label: 'Length',
              initialValue: 6,
              min: 4,
              max: 8,
            ),
            obscure: k.boolean(label: 'Obscure', initialValue: false),
            hasError: k.boolean(label: 'Error', initialValue: false),
            autofocus: false,
            onCompleted: (v) => log('OTP completed: $v'),
          ),
        );
      },
    }),
    component('AppPhoneInput', {
      'Default': (context) => Showcase(
        children: [
          AppPhoneInput(
            dialCode: context.knobs.string(
              label: 'Dial code',
              initialValue: '+84',
            ),
            errorText: context.knobs.stringOrNull(
              label: 'Error',
              initialValue: null,
            ),
            onChanged: (v) => log('phone: ${AppPhoneInput.toE164(v)}'),
          ),
        ],
      ),
    }),
    component('AppSearchBar', {
      'Default': (context) => Showcase(
        children: [
          AppSearchBar(
            hint: context.knobs.string(
              label: 'Hint',
              initialValue: 'Tìm bác sĩ, chuyên khoa',
            ),
            trailing: [
              IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
            ],
            onSubmitted: (v) => log('search: $v'),
          ),
        ],
      ),
    }),
    component('AppDropdown', {
      'Playground': (context) {
        final k = context.knobs;
        return Showcase(
          children: [
            Stateful<String?>(
              initial: null,
              builder: (context, value, set) => AppDropdown<String>(
                label: k.string(label: 'Label', initialValue: 'Chuyên khoa'),
                helperText: k.stringOrNull(label: 'Helper', initialValue: null),
                prefixIcon: Icons.local_hospital_outlined,
                enabled: k.boolean(label: 'Enabled', initialValue: true),
                value: value,
                onChanged: set,
                items: const [
                  AppDropdownItem(
                    value: 'tm',
                    label: 'Tim mạch',
                    icon: Icons.favorite_outline,
                  ),
                  AppDropdownItem(
                    value: 'nk',
                    label: 'Nhi khoa',
                    icon: Icons.child_care,
                  ),
                  AppDropdownItem(
                    value: 'dl',
                    label: 'Da liễu',
                    icon: Icons.face_outlined,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    }),
    component('AppListTile', {
      'Variants': (context) => Material(
        color: context.colors.surface,
        child: ListView(
          children: [
            AppListTile(
              title: 'Hồ sơ cá nhân',
              leadingIcon: Icons.person_outline,
              showChevron: true,
              onTap: () {},
            ),
            const AppDivider(inset: true),
            AppListTile(
              title: 'BS. Lê Minh',
              subtitle: 'Tim mạch · 10 năm kinh nghiệm',
              leading: const AppAvatar(name: 'Lê Minh'),
              trailing: const AppStatusBadge(
                label: 'Online',
                tone: AppTone.success,
              ),
              onTap: () {},
            ),
            AppListTile(
              title: 'Đã chọn',
              leadingIcon: Icons.check_circle_outline,
              selected: true,
              onTap: () {},
            ),
            const AppListTile(
              title: 'Disabled',
              leadingIcon: Icons.block,
              enabled: false,
            ),
          ],
        ),
      ),
    }),
    component('AppEmptyState', {
      'Playground': (context) {
        final k = context.knobs;
        return Material(
          color: context.colors.surface,
          child: AppEmptyState(
            title: k.string(label: 'Title', initialValue: 'Chưa có lịch hẹn'),
            message: k.stringOrNull(
              label: 'Message',
              initialValue: 'Đặt lịch khám để bắt đầu theo dõi sức khoẻ.',
            ),
            icon: Icons.event_busy_outlined,
            actionLabel: k.stringOrNull(
              label: 'Action',
              initialValue: 'Đặt lịch ngay',
            ),
            onAction: () => log('empty action'),
          ),
        );
      },
    }),
    component('AppDialog', {
      'Triggers': (context) => Showcase(
        children: [
          Builder(
            builder: (context) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AppButton.tonal(
                  label: 'Confirm',
                  onPressed: () async => log(
                    'confirm: ${await AppDialog.confirm(context, title: 'Huỷ lịch hẹn?', message: 'Bạn sẽ không thể khôi phục lịch hẹn sau khi huỷ.', icon: Icons.event_busy, confirmLabel: 'Huỷ lịch', cancelLabel: 'Giữ lại', isDestructive: true)}',
                  ),
                ),
                AppButton.tonal(
                  label: 'Alert',
                  onPressed: () => AppDialog.alert(
                    context,
                    title: 'Đặt lịch thành công',
                    message: 'Chúng tôi sẽ nhắc bạn trước 1 giờ.',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                AppButton.tonal(
                  label: 'Custom',
                  onPressed: () => AppDialog.custom<void>(
                    context,
                    title: 'Ghi chú',
                    content: const AppTextField(label: 'Nội dung', maxLines: 3),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Lưu'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    }),
    component('AppBottomSheet', {
      'Trigger': (context) => Showcase(
        children: [
          Builder(
            builder: (context) => AppButton(
              label: 'Mở bottom sheet',
              onPressed: () => AppBottomSheet.show<void>(
                context,
                title: 'Chọn phương thức thanh toán',
                builder: (context) => Column(
                  children: [
                    for (final m in ['Tiền mặt', 'Thẻ ngân hàng', 'Ví điện tử'])
                      AppListTile(
                        title: m,
                        showChevron: true,
                        onTap: () => Navigator.pop(context),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    }),
    component('AppSnackbar', {
      'Tones': (context) => Showcase(
        children: [
          Builder(
            builder: (context) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in AppTone.values)
                  AppButton.outlined(
                    label: t.name,
                    onPressed: () => AppSnackbar.show(
                      context,
                      'Thông báo ${t.name}',
                      tone: t,
                      actionLabel: 'Hoàn tác',
                      onAction: () {},
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    }),
  ],
);
