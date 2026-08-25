import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TemplateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TemplateAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 600;
    final menuItems = [
      ('certificates', 'Certificates'),
      ('projects', 'Projects'),
      ('activities', 'Activities'),
      ('about_me', 'About Me'),
    ];

    return AppBar(
      backgroundColor: Colors.white10.withAlpha(120),
      centerTitle: false,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: isNarrowScreen
          ? [
              PopupMenuButton<String>(
                tooltip: 'Menu',
                icon: const Icon(Icons.list_rounded, color: Colors.black),
                onSelected: (value) => context.go('/$value'),
                itemBuilder: (context) => menuItems
                    .map(
                      (item) =>
                          PopupMenuItem(value: item.$1, child: Text(item.$2)),
                    )
                    .toList(),
              ),
              const SizedBox(width: 8),
            ]
          : <Widget>[
              ...menuItems.map(
                (item) => TextButton(
                  onPressed: () => context.go('/${item.$1}'),
                  child: Text(
                    item.$2,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
    );
  }
}
