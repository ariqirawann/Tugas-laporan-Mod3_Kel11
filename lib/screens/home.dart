import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/country.dart';
import '../providers/favorites_provider.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countries;
  String searchQuery = '';
  String sortBy = 'name';
  bool isAscending = true;

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
      appBar: AppBar(title: const Text('Countries')),
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
          final filtered = allCountries.where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
          filtered.sort((a, b) {
            int cmp = 0;
            switch (sortBy) {
              case 'name':
                cmp = a.name.compareTo(b.name);
                break;
              case 'population':
                cmp = a.population.compareTo(b.population);
                break;
              case 'region':
                cmp = a.region.compareTo(b.region);
                break;
            }
            return isAscending ? cmp : -cmp;
          });
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Countries',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Text('Sort by: '),
                    DropdownButton<String>(
                      value: sortBy,
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(value: 'population', child: Text('Population')),
                        DropdownMenuItem(value: 'region', child: Text('Region')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                      onPressed: () {
                        setState(() {
                          isAscending = !isAscending;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final country = filtered[i];
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
