import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

import 'helpers.dart';

final atomsFolder = WidgetbookFolder(
  name: 'Atoms',
  children: [
    component('AppButton', {
      'Playground': (context) {
        final k = context.knobs;
        final enabled = k.boolean(label: 'Enabled', initialValue: true);
        return Center(
          child: AppButton(
            label: k.string(label: 'Label', initialValue: 'Đặt lịch khám'),
            variant: k.object.dropdown(
              label: 'Variant',
              options: AppButtonVariant.values,
              labelBuilder: (v) => v.name,
            ),
            size: k.object.segmented(
              label: 'Size',
              options: AppButtonSize.values,
              initialOption: AppButtonSize.medium,
              labelBuilder: (v) => v.name,
            ),
            icon: k.boolean(label: 'Icon', initialValue: false)
                ? Icons.event
                : null,
            isLoading: k.boolean(label: 'Loading', initialValue: false),
            expanded: k.boolean(label: 'Expanded', initialValue: false),
            onPressed: enabled ? () => log('AppButton pressed') : null,
          ),
        );
      },
      'All variants': (context) => Showcase(
        children: [
          for (final v in AppButtonVariant.values)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AppButton(label: v.name, variant: v, onPressed: () {}),
                AppButton(
                  label: 'Icon',
                  variant: v,
                  icon: Icons.add,
                  onPressed: () {},
                ),
                AppButton(label: 'Disabled', variant: v, onPressed: null),
                AppButton(
                  label: 'Loading',
                  variant: v,
                  isLoading: true,
                  onPressed: () {},
                ),
              ],
            ),
        ],
      ),
    }),
    component('AppIconButton', {
      'All variants': (context) => Showcase(
        children: [
          Wrap(
            spacing: 12,
            children: [
              for (final v in AppIconButtonVariant.values)
                AppIconButton(
                  icon: Icons.favorite_border,
                  variant: v,
                  tooltip: v.name,
                  onPressed: () {},
                ),
            ],
          ),
          Text('Toggle', style: context.textTheme.titleSmall),
          Stateful<bool>(
            initial: false,
            builder: (context, selected, set) => Wrap(
              spacing: 12,
              children: [
                for (final v in AppIconButtonVariant.values)
                  AppIconButton(
                    icon: Icons.favorite_border,
                    selectedIcon: Icons.favorite,
                    selected: selected,
                    variant: v,
                    onPressed: () => set(!selected),
                  ),
              ],
            ),
          ),
        ],
      ),
    }),
    component('AppTextField', {
      'Playground': (context) {
        final k = context.knobs;
        return Showcase(
          children: [
            AppTextField(
              label: k.stringOrNull(label: 'Label', initialValue: 'Họ và tên'),
              hint: k.stringOrNull(label: 'Hint', initialValue: 'Nguyễn Văn A'),
              helperText: k.stringOrNull(label: 'Helper', initialValue: null),
              errorText: k.stringOrNull(label: 'Error', initialValue: null),
              prefixIcon: k.boolean(label: 'Prefix icon', initialValue: true)
                  ? Icons.person_outline
                  : null,
              enabled: k.boolean(label: 'Enabled', initialValue: true),
              maxLength: k.intOrNull.input(
                label: 'Max length',
                initialValue: null,
              ),
            ),
          ],
        );
      },
      'States': (context) => const Showcase(
        children: [
          AppTextField(
            label: 'Email',
            hint: 'ten@vidu.com',
            prefixIcon: Icons.mail_outline,
          ),
          AppTextField(
            label: 'Mật khẩu',
            obscureText: true,
            prefixIcon: Icons.lock_outline,
          ),
          AppTextField(
            label: 'Có lỗi',
            initialValue: 'abc',
            errorText: 'Email không hợp lệ',
          ),
          AppTextField(label: 'Helper', helperText: 'Tối thiểu 8 ký tự'),
          AppTextField(
            label: 'Disabled',
            initialValue: 'Không sửa được',
            enabled: false,
          ),
          AppTextField(
            label: 'Ghi chú',
            maxLines: 4,
            minLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    }),
    component('AppCheckbox', {
      'Playground': (context) {
        final k = context.knobs;
        final tristate = k.boolean(label: 'Tristate', initialValue: false);
        final enabled = k.boolean(label: 'Enabled', initialValue: true);
        final isError = k.boolean(label: 'Error', initialValue: false);
        final label = k.stringOrNull(
          label: 'Label',
          initialValue: 'Tôi đồng ý điều khoản',
        );
        return Center(
          child: Stateful<bool?>(
            initial: false,
            builder: (context, value, set) => AppCheckbox(
              value: value,
              tristate: tristate,
              isError: isError,
              label: label,
              onChanged: enabled ? set : null,
            ),
          ),
        );
      },
    }),
    component('AppRadioGroup', {
      'Playground': (context) {
        final direction = context.knobs.object.segmented(
          label: 'Direction',
          options: Axis.values,
          labelBuilder: (v) => v.name,
        );
        return Showcase(
          children: [
            Stateful<String?>(
              initial: 'male',
              builder: (context, value, set) => AppRadioGroup<String>(
                value: value,
                direction: direction,
                onChanged: set,
                options: const [
                  AppRadioOption(value: 'male', label: 'Nam'),
                  AppRadioOption(value: 'female', label: 'Nữ'),
                  AppRadioOption(value: 'other', label: 'Khác', enabled: false),
                ],
              ),
            ),
          ],
        );
      },
    }),
    component('AppSwitch', {
      'Playground': (context) {
        final k = context.knobs;
        final label = k.stringOrNull(
          label: 'Label',
          initialValue: 'Nhận thông báo',
        );
        final subtitle = k.stringOrNull(
          label: 'Subtitle',
          initialValue: 'Nhắc lịch khám và đơn thuốc',
        );
        final showIcon = k.boolean(label: 'Show icon', initialValue: true);
        final enabled = k.boolean(label: 'Enabled', initialValue: true);
        return Showcase(
          children: [
            Stateful<bool>(
              initial: true,
              builder: (context, value, set) => AppSwitch(
                value: value,
                label: label,
                subtitle: subtitle,
                showIcon: showIcon,
                onChanged: enabled ? set : null,
              ),
            ),
          ],
        );
      },
    }),
    component('AppBadge', {
      'Notification badge': (context) {
        final count = context.knobs.intOrNull.slider(
          label: 'Count (null = dot)',
          initialValue: 5,
          min: 0,
          max: 150,
        );
        return Center(
          child: AppBadge(
            count: count,
            child: const Icon(Icons.notifications_outlined, size: 32),
          ),
        );
      },
      'Status badge': (context) => Showcase(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in AppTone.values)
                AppStatusBadge(label: t.name, tone: t),
            ],
          ),
          const Wrap(
            spacing: 8,
            children: [
              AppStatusBadge(
                label: 'Đã xác nhận',
                tone: AppTone.success,
                icon: Icons.check,
              ),
              AppStatusBadge(
                label: 'Chờ thanh toán',
                tone: AppTone.warning,
                icon: Icons.schedule,
              ),
              AppStatusBadge(
                label: 'Đã huỷ',
                tone: AppTone.error,
                icon: Icons.close,
              ),
            ],
          ),
        ],
      ),
    }),
    component('AppAvatar', {
      'Playground': (context) {
        final k = context.knobs;
        return Center(
          child: AppAvatar(
            name: k.stringOrNull(label: 'Name', initialValue: 'Nguyễn Văn An'),
            imageUrl: k.boolean(label: 'Image', initialValue: false)
                ? 'https://i.pravatar.cc/200?img=12'
                : null,
            size: k.object.segmented(
              label: 'Size',
              options: AppAvatarSize.values,
              initialOption: AppAvatarSize.large,
              labelBuilder: (v) => v.name,
            ),
          ),
        );
      },
      'Sizes': (context) => Showcase(
        children: [
          Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final s in AppAvatarSize.values)
                AppAvatar(name: 'Trần Bình', size: s),
              const AppAvatar(),
            ],
          ),
        ],
      ),
    }),
    component('AppImage', {
      'Playground': (context) {
        final k = context.knobs;
        return Center(
          child: AppImage(
            k.boolean(label: 'Broken URL', initialValue: false)
                ? 'https://invalid.example/x.png'
                : sampleImage,
            width: 240,
            height: 240,
            borderRadius: BorderRadius.circular(
              k.double.slider(
                label: 'Radius',
                initialValue: 12,
                min: 0,
                max: 120,
              ),
            ),
          ),
        );
      },
    }),
    component('AppIcon', {
      'Sizes': (context) => Showcase(
        children: [
          Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final s in AppIconSize.values)
                AppIcon(Icons.medical_services_outlined, size: s),
            ],
          ),
        ],
      ),
    }),
    component('AppDivider', {
      'Variants': (context) => Showcase(
        children: [
          const Text('Full'),
          const AppDivider(),
          const Text('Inset'),
          const AppDivider(inset: true),
          SizedBox(
            height: 40,
            child: Row(
              children: const [
                Text('Trái'),
                AppDivider.vertical(space: 24),
                Text('Phải'),
              ],
            ),
          ),
        ],
      ),
    }),
    component('AppLoading', {
      'Variants': (context) {
        final value = context.knobs.doubleOrNull.slider(
          label: 'Progress (null = indeterminate)',
          initialValue: null,
          min: 0,
          max: 1,
        );
        return Showcase(
          children: [
            AppLoading(value: value),
            AppLoading(value: value, message: 'Đang tải dữ liệu...'),
            AppLoading.linear(value: value),
          ],
        );
      },
      'Overlay': (context) => AppLoadingOverlay(
        isLoading: context.knobs.boolean(label: 'Loading', initialValue: true),
        message: 'Đang xử lý',
        child: const Showcase(
          children: [
            AppTextField(label: 'Họ và tên'),
            AppTextField(label: 'Số điện thoại'),
          ],
        ),
      ),
    }),
  ],
);
