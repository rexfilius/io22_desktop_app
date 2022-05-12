import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:io22_desktop_app/app/login/github_login.dart';
import 'package:io22_desktop_app/credentials.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return GithubLoginWidget(
      builder: (context, httpClient) {
        WindowToFront.activate();
        return FutureBuilder<List<PullRequest>>(
          future: getPullRequests(httpClient.credentials.accessToken),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final pullRequests = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text(title),
              ),
              body: Center(
                child: ListView.builder(
                  itemCount: pullRequests.length,
                  itemBuilder: (context, index) {
                    final pullRequest = pullRequests.elementAt(index);
                    return ListTile(
                      title: Text(pullRequest.title ?? ''),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
      githubClientId: githubClientId,
      githubClientSecret: githubClientSecret,
      githubScopes: githubScopes,
    );
  }
}

Future<CurrentUser> viewerDetail(accessToken) {
  final github = GitHub(auth: Authentication.withToken(accessToken));
  return github.users.getCurrentUser();
}

Future<List<PullRequest>> getPullRequests(accessToken) {
  final github = GitHub(auth: Authentication.withToken(accessToken));
  return github.pullRequests
      .list(RepositorySlug('flutter', 'flutter'))
      .toList();
}
