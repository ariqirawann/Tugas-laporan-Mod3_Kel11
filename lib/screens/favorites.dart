import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/country.dart';
import '../providers/favorites_provider.dart';
import 'detail.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Country>> countries;

  @override
  void initState() {
    super.initState();
    countries = fetchCountries();
  }

  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse('https://www.apicountries.com/countries');
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final respBody = await response.transform(utf8.decoder).join();
      final List<dynamic> jsonData = jsonDecode(respBody);
      return jsonData.map((j) => Country.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: FutureBuilder<List<Country>>(
        future: countries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No countries found'));
          }
          final allCountries = snapshot.data!;
          final favoriteCountries = allCountries.where((country) => favoritesProvider.isFavorite(country.name)).toList();
          if (favoriteCountries.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return ListView.builder(
            itemCount: favoriteCountries.length,
            itemBuilder: (context, i) {
              final country = favoriteCountries[i];
              return Card(
                child: ListTile(
                  leading: country.flagsPng != null
                      ? Image.network(country.flagsPng!, width: 50)
                      : const SizedBox(width: 50),
                  title: Text(country.name),
                  subtitle: Text(country.region),
                  trailing: IconButton(
                    icon: Icon(
                      favoritesProvider.isFavorite(country.name) ? Icons.favorite : Icons.favorite_border,
                      color: favoritesProvider.isFavorite(country.name) ? Colors.red : null,
                    ),
                    onPressed: () {
                      favoritesProvider.toggleFavorite(country.name);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(country: country),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
