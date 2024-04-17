import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../di/injection.dart';
import '../../features/movies/presentation/blocs/detail/movie_cubit.dart';
import '../../features/movies/presentation/blocs/favorites/favorites_cubit.dart';
import '../../features/movies/presentation/blocs/list/movie_list_cubit.dart';
import '../../features/movies/presentation/pages/favorites_page.dart';
import '../../features/movies/presentation/pages/movie_detail_page.dart';
import '../../features/movies/presentation/pages/movie_list_page.dart';
import '../../features/splash/presentation/pages/splashscreen_page.dart';
import '../constants/keys.dart';
import '../constants/route_list.dart';
import '../extension/context.dart';
import '../presentation/widgets/top_bar.dart';
import '../resources/vectors.dart';
import '../theme/app_colors.dart';

final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: RouteList.splash.path,
  debugLogDiagnostics: true,
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text(
          'Page not found',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  },
  routes: [
    GoRoute(
      path: RouteList.splash.path,
      name: RouteList.splash.name,
      builder: (context, state) => const SplashScreenPage(),
    ),
    ShellRoute(
      navigatorKey: shellRouteKey,
      builder: (context, state, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => getIt<FavoritesCubit>(),
            ),
            BlocProvider(
              create: (context) => getIt<MovieListCubit>(),
            ),
          ],
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: TopBar(
              title: GestureDetector(
                onTap: () async {
                  await launchUrl(
                    Uri(scheme: 'https', host: 'www.niji.fr'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: SvgPicture.asset(Vectors.niji, height: 30),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: getIndex(state.uri.toString()),
              backgroundColor: AppColors.mineralGreen,
              selectedItemColor: AppColors.cararra,
              items: [
                BottomNavigationBarItem(
                  activeIcon: const Icon(Icons.movie, color: AppColors.cararra),
                  icon: const Icon(Icons.movie, color: AppColors.edward),
                  label: context.translate().bottomNavBarMovies,
                ),
                BottomNavigationBarItem(
                  activeIcon: const Icon(Icons.favorite, color: AppColors.cararra),
                  icon: const Icon(Icons.favorite, color: AppColors.edward),
                  label: context.translate().bottomNavBarFavorites,
                ),
              ],
              onTap: (value) {
                if (value == 0) {
                  GoRouter.of(context).goNamed(RouteList.favorites.name);
                } else {
                  GoRouter.of(context).goNamed(RouteList.favorites.name);
                }
              },
            ),
            body: child,
          ),
        );
      },
      routes: [
        GoRoute(
          path: RouteList.movies.path,
          name: RouteList.movies.name,
          builder: (context, state) => const MovieListPage(),
          routes: [
            GoRoute(
              path: RouteList.movieDetail.path,
              name: RouteList.movieDetail.name,
              builder: (context, state) => BlocProvider(
                create: (context) => getIt<MovieCubit>(),
                child: MovieDetailPage(
                  movieDetailPageArgs: state.extra as MovieDetailPageArgs,
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: RouteList.favorites.path,
          name: RouteList.favorites.name,
          builder: (context, state) => const FavoritesPage(),
        ),
      ],
    ),
  ],
);

int getIndex(String location) {
  if (location.startsWith(RouteList.movies.path)) {
    return 0;
  } else if (location.startsWith(RouteList.favorites.path)) {
    return 1;
  } else {
    return 0;
  }
}
