import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:github_browser/model/github_user.dart';
import 'package:github_browser/model/github_user_list.dart';
import 'package:github_browser/view/user_repos.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _username = "";
  Future<GithubUserList> _response;
  var _controller = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _searchGithub(String name) {
    setState(() {
      this._username = name;
      print("inside searchGithub");
      _response = GithubUserList.fetchUsers(_username, debug: false);
    });
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _username = "";
    });
  }

  Widget buildUserCard(user) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        height: 100,
        child: Row(children: [
          Container(
              decoration: BoxDecoration(
                  color: Color(0xFFFFFFFFFF),
                  border: Border.all(color: Color(0xff838383), width: 1),
                  borderRadius: BorderRadius.circular(45)),
              padding: EdgeInsets.all(3),
              margin: EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45.0),
                child: Image.network(
                  user.avatarUrl,
                  height: 80,
                  width: 80,
                ),
              )),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      () {
                        return user.login != null ? "@${user.login}" : "";
                      }(),
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      foregroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        const Set<MaterialState> interactiveStates =
                            <MaterialState>{
                          MaterialState.pressed,
                          MaterialState.hovered,
                          MaterialState.focused,
                        };
                        if (states.any(interactiveStates.contains)) {
                          return Colors.black;
                        }
                        return Colors.white;
                      }),
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        const Set<MaterialState> interactiveStates =
                            <MaterialState>{
                          MaterialState.pressed,
                          MaterialState.hovered,
                          MaterialState.focused,
                        };
                        if (states.any(interactiveStates.contains)) {
                          return Colors.white;
                        }
                        return Colors.black;
                      }),
                    ),
                    child: Text("Repos"),
                    onPressed: () {
                      return Navigator.push(
                        _scaffoldKey.currentContext,
                        MaterialPageRoute(
                            builder: (context) => UsersRepos(user)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          canvasColor: Color(0xFFfefefefe),
          primarySwatch: MaterialColor(
            0xFF212121,
            <int, Color>{
              50: Color(0xFF000000),
              100: Color(0xFF000000),
              200: Color(0xFF000000),
              300: Color(0xFF000000),
              400: Color(0xFF000000),
              500: Color(0xFF000000),
              600: Color(0xFF000000),
              700: Color(0xFF000000),
              800: Color(0xFF000000),
              900: Color(0xFF000000),
            },
          ),
        ),
        home: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            brightness: Brightness.dark,
            title: Text("Github search"),
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Github username',
                    suffixIcon: IconButton(
                      onPressed: _clear,
                      icon: Icon(Icons.clear),
                    ),
                  ),
                  onSubmitted: _searchGithub,
                  onChanged: _searchGithub,
                ),
              ),
              Expanded(child: () {
                if (_username.isEmpty) return Text("Insert a user name");
                return FutureBuilder<GithubUserList>(
                    future: _response,
                    builder: (context, userList) {
                      if (userList.hasData) {
                        if (userList.data.githubUserList.first.isTemplateUser) {
                          return ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Divider(),
                              itemCount: userList.data.githubUserList.length,
                              itemBuilder: (context, index) {
                                print("index $index");
                                return buildUserCard(GithubUser(
                                    avatarUrl:
                                        "https://avatars.githubusercontent.com/u/1024025?v=4",
                                    login: "dollynho"));
                              });
                        } else if (userList
                            .data.githubUserList.first.isUserNotFound) {
                          return Text("User not found!");
                        } else {
                          // TODO go back to the top of the list when textfield is edited
                          return ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Divider(),
                              itemCount: userList.data.githubUserList.length,
                              itemBuilder: (context, index) {
                                print("index $index");
                                print("total ${userList.data.githubUserList.length}");
                                return buildUserCard(userList
                                    .data.githubUserList
                                    .elementAt(index));
                              });
                        }
                      } else if (userList.hasError) {
                        return Column(children: [Text("Error. Try again!")]);
                      }
                      return ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(),
                          itemCount: 100,
                          itemBuilder: (context, index) {
                            return Center(
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    width: 90,
                                    height: 90,
                                    child: CircularProgressIndicator()));
                          });
                    });
              }()),
            ],
          ),
        ));
  }
}
