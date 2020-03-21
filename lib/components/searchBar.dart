import 'package:flutter/material.dart';
import 'package:go_home/views/searchView.dart';

import '../views/cityContent.dart';

class SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        showSearch(context: context, delegate: DataSearch());
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Type your search here"),
              Icon(
                Icons.search,
                color: Color(0xFF79c942),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final results = ['Lagos', 'Abuja', 'Oyo', 'Imo'];

  final recentResults = ['Lagos', 'Abuja'];

  @override
  List<Widget> buildActions(BuildContext context) {
    // build actions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of the bar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some results based on selecion
    return SearchView(query: query, hideAppBar: true,);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show when someone searches for something
    final suggestionList = query.isEmpty
        ? recentResults
        : results.where((p) => p.startsWith(query)).toList(); // to fix lowercase searches with or

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = suggestionList[index];
          showResults(context);
          return SearchView(query: query, hideAppBar: true,);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SearchView(query: query,),
          //   ),
          // );
        },
        leading: Icon(Icons.location_city),
        title: RichText(
          text: TextSpan(
            text: suggestionList[index].substring(0, query.length),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: suggestionList[index].substring(query.length),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      itemCount: suggestionList.length,
    );
  }
}
