import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key, required this.title, required this.firstName, required this.zipCode, this.searchQuery = ""}) : super(key: key);

  final String title;
  final String firstName;
  final String zipCode;
  final String searchQuery;

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  TextEditingController _searchController = TextEditingController();
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  bool _isLoading = false;

  void _updateMarkers(CameraPosition position) {
    // Fetch new markers based on the updated camera position
    LatLng currentLocation = position.target;
    _fetchRestaurants(currentLocation);
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;  // Initialize with search query
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.zipCode.isNotEmpty) {
        _goToZipCode();  // Call this method after the widget builds
      }
    });
  }

  void _fetchRestaurants(LatLng location) async {
    setState(() {
      _isLoading = true;
    });

    final String apiKey = 'AIzaSyCLZVx8AMzOiyWpTvkblgHnYPc8uqt5umM'; // Replace with your API key
    final String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=1500&type=restaurant&keyword=${_searchController.text}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);  // Debugging output of API response
      _showMarkers(data);
    } else {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Failed to load places: ${response.body}');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load places. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showMarkers(dynamic data) {
    var places = data['results'] as List<dynamic>;
    setState(() {
      _markers.clear();
      for (var place in places) {
        final marker = Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']),
          infoWindow: InfoWindow(title: place['name']),
          onTap: () {
            _showRestaurantDetails(place['place_id']);
          },
        );
        _markers.add(marker);
      }
      _isLoading = false;
    });
  }

  void _showRestaurantDetails(String placeId) async {
    final String apiKey = 'AIzaSyCLZVx8AMzOiyWpTvkblgHnYPc8uqt5umM'; // Replace with your API key
    final String detailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,rating,formatted_address,formatted_phone_number,photos&key=$apiKey';

    final response = await http.get(Uri.parse(detailsUrl));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var restaurantName = data['result']['name'];
      var rating = data['result']['rating'] ?? 0.0;
      var address = data['result']['formatted_address'] ?? 'Address not available';
      var phoneNumber = data['result']['formatted_phone_number'] ?? 'Phone number not available';
      var photos = data['result']['photos'] as List<dynamic>?;

      // Create a PageController
      var pageController = PageController();

      // Display the restaurant details in a custom dialog
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantName ?? 'No Name',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              RatingBar.builder(
                                initialRating: rating.toDouble(),
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                              SizedBox(width: 10),
                              Text(
                                rating.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (photos != null && photos.isNotEmpty)
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: pageController, // Pass the PageController to the PageView
                              itemCount: photos.length,
                              itemBuilder: (context, index) {
                                var photoReference = photos[index]['photo_reference'];
                                return Image.network(
                                  'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to the next page in the PageView
                                  pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
                                },
                                child: Icon(Icons.arrow_forward),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            address,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Phone:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            phoneNumber,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      debugPrint('Failed to load restaurant details: ${response.body}');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load restaurant details. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      throw Exception('Failed to load restaurant details');
    }
  }

  void _goToZipCode() async {
    final String apiKey = 'AIzaSyCLZVx8AMzOiyWpTvkblgHnYPc8uqt5umM'; // Replace with your API key
    final String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=${widget.zipCode}&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['results'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No location found for that ZIP code")));
        return;
      }
      var location = data['results'][0]['geometry']['location'];
      LatLng latLng = LatLng(location['lat'], location['lng']);
      mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)));

      // Fetch restaurants and show markers
      _fetchRestaurants(latLng);
    } else {
      debugPrint('Failed to fetch location: ${response.body}');
      throw Exception('Failed to fetch location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0, // No shadow
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  if (mapController != null) {
                    _goToZipCode();  // Refetch restaurants whenever a new search is submitted
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for a restaurant',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (mapController != null) {
                  _goToZipCode();  // Refetch restaurants whenever a new search is submitted
                }
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (widget.zipCode.isNotEmpty) {
                _goToZipCode();
              }
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(37.77483, -122.41942), // Default to San Francisco
              zoom: 16.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            onCameraMove: _updateMarkers, // Attach update method to onCameraMove callback
          ),
        ],
      ),
    );
  }
}