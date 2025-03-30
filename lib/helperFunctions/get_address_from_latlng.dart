import 'dart:convert';
import 'package:http/http.dart' as http;
String formatAddress(Map<String, dynamic> data) {
  final address = data['address'];
  if (address == null) return '';

  // Try to get the most relevant parts in order of preference
  final parts = [
    address['road'],           // Street name
    address['suburb'],         // Suburb/neighborhood
    address['city'],           // City
    address['town'],           // Town (if city is not available)
    address['state_district'], // District
    address['state'],          // State/Region
    address['country'],        // Country
  ].where((part) => part != null && part.isNotEmpty).toList();

  return parts.join(', ');
}
Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      print('Attempting to get address for coordinates: $lat, $lng');
      
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'GreatPlaces/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: $data');
        
        if (data['address'] != null) {
          final formattedAddress = formatAddress(data);
          if (formattedAddress.isNotEmpty) {
            print('Final address: $formattedAddress');
            return formattedAddress;
          }
        }
      }
      
      print('No address found, returning coordinates');
      return "Location: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
    } catch (e, stackTrace) {
      print('Error getting address: $e');
      print('Stack trace: $stackTrace');
      return "Location: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
    }
  }