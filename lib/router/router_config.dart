  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
  import 'package:projet_spotify_gorouter/screens/album_detail_screen.dart';
  import 'package:projet_spotify_gorouter/screens/album_news_screen.dart';
  import 'package:projet_spotify_gorouter/screens/artiste_detail_screen.dart';
  import 'package:projet_spotify_gorouter/screens/chanson_detail_screen.dart';
  import 'package:projet_spotify_gorouter/screens/playlist_screen.dart';
  import 'package:projet_spotify_gorouter/screens/search_detail_screen.dart';
  import 'package:projet_spotify_gorouter/screens/search_screen.dart';
  import 'package:projet_spotify_gorouter/scaffold_with_navigation.dart';

  /// Configuration du router (utilisation de GO_ROUTER)
  /// 
  /// 4 navigators (1 général plus 1 pour chaque branche)
  ///  -> donc 4 keys différentes pour les distinguer
  /// 
  /// Stateful nested navigation based on:
  /// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
    
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
  final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
  final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');

  ///  configuration
  final GoRouter router = GoRouter(
    initialLocation: '/a', // - la branche initiale
    navigatorKey: _rootNavigatorKey,
    // -- pour gérer les erreurs de routage et/ou page inexistante
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: const Scaffold(
        body: Center(
          child: Text('Page introuvable'),
        ),
      ),
    ),
    // --  au premier niveau navigation entre les branches
    routes: [
        StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // utilisation d'un scaffold specifique
          return ScaffoldWithNestedNavigation(
              navigationShell: navigationShell);
        },
        branches: [
          // first branch (A)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAKey,
            // config d'une branche
            routes: [
              GoRoute(
                path: '/a',
                pageBuilder: (context, state) => const NoTransitionPage(
                  //child: RootScreen(label: 'A', detailsPath: '/a/details'),
                  child : AlbumNewsScreen(),
                ),
                routes: [
                  // child route
                    GoRoute(
                      path: 'albumdetails/:id',
                      builder: (BuildContext context, GoRouterState state) {
                        final id = state.pathParameters['id'];
                        return AlbumDetailScreen(albumId: id!);
                      },
                    ),
                    GoRoute(
                      path: 'artistedetails/:id',
                      builder: (BuildContext context, GoRouterState state) {
                        final id = state.pathParameters['id'];
                        if (id != null) {
                          return ArtisteDetailScreen(artistId: id);
                        } else {
                          return Container();
                        }
                      },
                    ),
                    GoRoute(
                      path: 'chansondetails/:id',
                      builder: (BuildContext context, GoRouterState state) {
                        final id = state.pathParameters['id'];
                        if (id != null) {
                          return ChansonDetailScreen(chansonId: id);
                        } else {
                          return Container();
                        }
                      },
                    ),

                ],
              ),
            ],
          ),
          // second branch (B)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBKey,
            routes: [
              // top route inside branch
              GoRoute(
                path: '/b',
                pageBuilder: (context, state) => const NoTransitionPage(
                  // child: RootScreen(label: 'B', detailsPath: '/b/details'),
                  child: SearchScreen()
                ),
                routes: [
                  // child route
                  GoRoute(
                      path: 'searchdetails/:id',
                      builder: (BuildContext context, GoRouterState state) {
                        final id = state.pathParameters['id'];
                        if (id != null) {
                          return SearchDetailsScreen(albumId: id);
                        } else {
                          // Gérez le cas où id est null
                          return Container(); // ou tout autre widget que vous voulez afficher
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
          // second branch (C)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCKey,
            routes: [
              // top route inside branch
              GoRoute(
                path: '/c',
                pageBuilder: (context, state) => const NoTransitionPage(
                  // child: RootScreen(label: 'B', detailsPath: '/b/details'),
                  child: PlaylistScreen()
                ),
                routes: [
                  // child route
                  GoRoute(
                    path: 'albumdetails/:id',
                    builder: (BuildContext context, GoRouterState state) {
                      final id = state.pathParameters['id'];
                      if (id != null) {
                        return AlbumDetailScreen(albumId: id);
                      } else {
                        // Gérez le cas où id est null
                        return Container(); // ou tout autre widget que vous voulez afficher
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      )
    ]
  );