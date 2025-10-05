import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/country.dart';
import '../providers/favorites_provider.dart';

class DetailPage extends StatelessWidget {
final Country country;

const DetailPage({super.key, required this.country});

@override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
        actions: [
          IconButton(
            icon: Icon(
              favoritesProvider.isFavorite(country.name) ? Icons.favorite : Icons.favorite_border,
              color: favoritesProvider.isFavorite(country.name) ? Colors.red : null,
            ),
            onPressed: () {
              favoritesProvider.toggleFavorite(country.name);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (country.flagsPng != null)
              Center(child: Image.network(country.flagsPng!, width: 200)),
            const SizedBox(height: 16),
            Text('Name: ${country.name}', style: const TextStyle(fontSize: 18)),
            Text(
              'Capital: ${country.capital ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Region: ${country.region}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Population: ${country.population}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Languages: ${country.languages?.join(', ') ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Currencies: ${country.currencies?.join(', ') ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
