import 'package:flutter/material.dart';

Container historyBlock(BuildContext context,
    {required String name,
    required String startDate,
    required String endDate,
    required List<String> times,
    required int quantity}) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.15,
    width: MediaQuery.of(context).size.width * 0.8,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(15), // Rounded corners
      border: Border.all(
        color: Colors.grey.shade400, // Border color
        width: 1.5, // Border thickness
      ),
    ),
    padding: const EdgeInsets.all(15), // Optional padding inside the container
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
          children: [
            Text(
              startDate,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Status to be filled",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      ],
    ),
  );
}
