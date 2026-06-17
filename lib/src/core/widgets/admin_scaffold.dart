import 'package:flutter/material.dart';

import '../session/app_session.dart';
import '../theme/app_theme.dart';
import 'brand_logo.dart';

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({required this.session, required this.child, super.key});

  final AppSession session;
  final Widget child;

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.session,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;
            final sidebarWidth = _sidebarCollapsed ? 84.0 : 264.0;

            if (compact) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.session.selectedSection.title),
                  actions: [
                    IconButton(
                      tooltip: 'Sair',
                      onPressed: widget.session.signOut,
                      icon: const Icon(Icons.logout_outlined),
                    ),
                  ],
                ),
                drawer: Drawer(
                  backgroundColor: AppColors.surface,
                  child: _Sidebar(
                    session: widget.session,
                    closeOnSelect: true,
                    collapsed: false,
                    onToggleCollapsed: null,
                  ),
                ),
                body: _PageBody(child: widget.child),
              );
            }

            return Scaffold(
              body: Row(
                children: [
                  AnimatedContainer(
                    width: sidebarWidth,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: _Sidebar(
                      session: widget.session,
                      closeOnSelect: false,
                      collapsed: _sidebarCollapsed,
                      onToggleCollapsed: () {
                        setState(() {
                          _sidebarCollapsed = !_sidebarCollapsed;
                        });
                      },
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Column(
                      children: [
                        _Topbar(session: widget.session),
                        const Divider(height: 1),
                        Expanded(child: _PageBody(child: widget.child)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.session,
    required this.closeOnSelect,
    required this.collapsed,
    required this.onToggleCollapsed,
  });

  final AppSession session;
  final bool closeOnSelect;
  final bool collapsed;
  final VoidCallback? onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? 10 : 14,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 4 : 10),
              child: Row(
                children: [
                  Expanded(
                    child: collapsed
                        ? const Center(
                            child: BrandLogo(compact: true, fontSize: 28),
                          )
                        : const BrandLogo(fontSize: 26),
                  ),
                  if (!collapsed)
                    IconButton(
                      tooltip: 'Recolher menu',
                      onPressed: onToggleCollapsed,
                      icon: const Icon(Icons.keyboard_double_arrow_left),
                    ),
                ],
              ),
            ),
            if (collapsed && onToggleCollapsed != null) ...[
              const SizedBox(height: 8),
              Center(
                child: IconButton(
                  tooltip: 'Expandir menu',
                  onPressed: onToggleCollapsed,
                  icon: const Icon(Icons.keyboard_double_arrow_right),
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 2),
                child: Text(
                  'Admin',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 28),
            for (final section in AdminSection.values)
              _SidebarItem(
                section: section,
                selected: session.selectedSection == section,
                collapsed: collapsed,
                onTap: () {
                  session.selectSection(section);
                  if (closeOnSelect) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(collapsed ? 8 : 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: collapsed
                  ? const Center(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE8EEFF),
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFE8EEFF),
                          child: Icon(
                            Icons.admin_panel_settings_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.currentUser?.name ?? 'Admin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                session.currentUser?.email ??
                                    'admin@tafeito.com',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: session.signOut,
                icon: const Icon(Icons.logout_outlined),
                label: collapsed ? const SizedBox.shrink() : const Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.section,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final AdminSection section;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? const Color(0xFFE8EEFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                SizedBox(width: collapsed ? 0 : 12),
                Icon(
                  section.icon,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  size: 21,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return collapsed ? Tooltip(message: section.title, child: item) : item;
  }
}

class _Topbar extends StatelessWidget {
  const _Topbar({required this.session});

  final AppSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              session.selectedSection.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE8EEFF),
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              session.currentUser?.name ?? 'Admin',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
