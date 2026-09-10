import 'package:adaptative_nav_bar/adaptative_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return DemoShell(navigationShell: navigationShell);
          },
      branches: <StatefulShellBranch>[
        _branch('/home', 'Home', Icons.home_rounded),
        _branch('/discover', 'Discover', Icons.explore_rounded),
        _branch('/trade', 'Trade', Icons.swap_horiz),
        _branch('/grow', 'Grow', Icons.hub_rounded),
        _branch('/assets', 'Assets', Icons.account_balance_wallet_rounded),
      ],
    ),
  ],
);

StatefulShellBranch _branch(String path, String title, IconData icon) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: path,
        builder: (BuildContext context, GoRouterState state) =>
            DemoPage(title: title, icon: icon),
      ),
    ],
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Adaptive Nav Bar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        brightness: Brightness.light,
        extensions: const <ThemeExtension<dynamic>>[AdaptiveNavThemeData()],
      ),
      routerConfig: _router,
    );
  }
}

class DemoShell extends StatefulWidget {
  const DemoShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  final AdaptiveNavController _controller = AdaptiveNavController();
  AdaptiveBottomNavStyle _bottomStyle = AdaptiveBottomNavStyle.centerRaised;

  static const List<AdaptiveNavDestination> _destinations =
      <AdaptiveNavDestination>[
        AdaptiveNavDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        AdaptiveNavDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'Discover',
        ),
        AdaptiveNavDestination(
          icon: Icon(Icons.swap_horiz),
          selectedIcon: Icon(Icons.swap_horiz),
          label: 'Trade',
        ),
        AdaptiveNavDestination(
          icon: Icon(Icons.hub_outlined),
          selectedIcon: Icon(Icons.hub_rounded),
          label: 'Grow',
        ),
        AdaptiveNavDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet_rounded),
          label: 'Assets',
          badge: Text('3'),
        ),
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('adaptative_nav_bar'),
        actions: <Widget>[
          PopupMenuButton<AdaptiveBottomNavStyle>(
            tooltip: 'Change compact style',
            initialValue: _bottomStyle,
            onSelected: (AdaptiveBottomNavStyle style) {
              setState(() => _bottomStyle = style);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<AdaptiveBottomNavStyle>>[
                for (final AdaptiveBottomNavStyle style
                    in AdaptiveBottomNavStyle.values)
                  PopupMenuItem<AdaptiveBottomNavStyle>(
                    value: style,
                    child: Text(style.name),
                  ),
              ];
            },
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
      ),
      body: AdaptiveNavScaffold(
        controller: _controller,
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: (int index) {
          widget.navigationShell.goBranch(index);
        },
        onDestinationReselected: (int index) {
          widget.navigationShell.goBranch(index, initialLocation: true);
        },
        compact: AdaptiveNavPresentation.bottom(
          bottomStyle: _bottomStyle,
          maxWidth: 520,
          raisedItem: _bottomStyle == AdaptiveBottomNavStyle.centerRaised
              ? const AdaptiveRaisedNavItem(
                  index: 2,
                  size: 60,
                  offset: 20,
                  elevation: 7,
                )
              : null,
        ),
        medium: const AdaptiveNavPresentation.rail(
          railStyle: AdaptiveRailStyle.indicator,
        ),
        expanded: const AdaptiveNavPresentation.sidebar(
          sidebarStyle: AdaptiveSidebarStyle.collapsible,
          width: 280,
          collapsedWidth: 80,
        ),
        scrollBehavior: const AdaptiveNavScrollBehavior(
          hideOnScroll: true,
          showAtStart: true,
          showOnScrollEnd: true,
        ),
        body: widget.navigationShell,
      ),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({required this.title, required this.icon, super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 30,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 36),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          );
        }
        return Card(
          child: ListTile(
            title: Text('$title item $index'),
            subtitle: const Text(
              'Resize the window to switch between bottom, rail, and sidebar.',
            ),
          ),
        );
      },
    );
  }
}
