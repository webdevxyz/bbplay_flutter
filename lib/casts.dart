// cast_details_page.dart
import 'package:flutter/material.dart';
import 'details.dart'; // Import the file where Cast class is defined.

class CastDetailsPage extends StatelessWidget {
  final Cast castMember;

  CastDetailsPage({Key? key, required this.castMember}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(castMember.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.network(
              castMember.imageUrl,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    castMember.name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Text(
                    castMember.type,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 10),
                  Text(
                    castMember.bio,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
