import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/main_provider.dart';
import '../constants.dart';
import 'main_screen.dart';
import 'recipe_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;
    return Scaffold(
      backgroundColor: kScreenBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                spacing: 12,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    ),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: kCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: kInk),
                    ),
                  ),
                  Text(
                    'favorites'.tr(),
                    style: kBigTextStyle.copyWith(color: kInk),
                  ),
                ],
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Text(
                        'noFavorites'.tr(),
                        style: kTextStyle.copyWith(
                          color: kInk.withValues(alpha: 0.55),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: favorites.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _FavoriteTile(favorite: favorites[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.favorite});

  final FavoriteRecipe favorite;

  @override
  Widget build(BuildContext context) {
    final recipe = favorite.recipe;
    return GestureDetector(
      onTap: () {
        final data = context.read<MainProvider>();
        data.answer = recipe;
        data.favoriteId = favorite.id;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RecipeScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              recipe.recipeName,
              style: kBigTextStyle.copyWith(color: kInk),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (recipe.calories.isNotEmpty)
                  _Pill(label: recipe.calories, color: kInk),
                if (recipe.cookingTime > 0)
                  _Pill(
                    label: '${recipe.cookingTime} ${'minUnit'.tr()}',
                    color: kInk,
                  ),
                if (recipe.isVegan) _Pill(label: 'vegan'.tr(), color: kAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(label, style: kTextStyle.copyWith(color: Colors.white)),
    );
  }
}
