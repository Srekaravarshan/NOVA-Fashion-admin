import 'package:flutter/material.dart';
import 'package:nova_fashion_admin/pages/Category.dart';

Widget categoryWidget(
    List categories, int index, BuildContext context, String collectionName) {
  return InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Category(
                categoryName: categories[index]['categoryName'],
                collectionName: collectionName),
          ));
    },
    child: Column(
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Colors.grey,
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(categories[index]['mediaUrl']))),
        ),
        SizedBox(height: 4),
        Text(
          categories[index]['categoryName'],
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
        )
      ],
    ),
  );
}
