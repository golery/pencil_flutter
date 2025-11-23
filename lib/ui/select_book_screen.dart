// ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:provider/provider.dart';

class SelectBookScreen extends StatefulWidget {
  const SelectBookScreen({super.key});

  @override
  _SelectBookScreenState createState() => _SelectBookScreenState();
}

class _SelectBookScreenState extends State<SelectBookScreen> {
  Widget getBody(DataProvider dataProvider) {
    var books = dataProvider.bookList ?? [];
    var orientation = MediaQuery.of(context).orientation;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          // Cycle through pastel colors
          final List<Color> pastelColors = [
            const Color(0xFFFFF8E1), // Light Yellow
            const Color(0xFFFCE4EC), // Light Pink
            const Color(0xFFE8F5E9), // Light Green
            const Color(0xFFE0F7FA), // Light Cyan
            const Color(0xFFF3E5F5), // Light Purple
          ];
          final color = pastelColors[index % pastelColors.length];

          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: color,
            child: InkWell(
              onTap: () async {
                await dataProvider.loadBoook(book.id);
                Navigator.pop(context);
              },
              child: Stack(
                children: [
                  // Decorative background circle (mimicking the style)
                  Positioned(
                    right: -20,
                    top: -20,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title at the top
                        Text(
                          book.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Icon or Image placeholder in center/bottom
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.menu_book,
                              size: 48,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        // "View" or dummy text at bottom
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(builder: (context, dataProvider, child) {
      return getBody(dataProvider);
    });
  }
}
