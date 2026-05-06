import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:richtexteditor/src/features/account/widget/profile_screen.dart';
import 'package:richtexteditor/src/features/authentication/widget/signin_screen.dart';
import 'package:richtexteditor/src/features/developer/widget/developer_screen.dart';
import 'package:richtexteditor/src/features/home/widget/home_screen.dart';
import 'package:richtexteditor/src/features/settings/widget/settings_screen.dart';

enum Routes with OctopusRoute {
  signin('signin', title: 'Sign-In'),
  home('home', title: 'Home'),
  profile('profile', title: 'Profile'),
  developer('developer', title: 'Developer'),
  settings('settings', title: 'Settings');

  const Routes(this.name, {this.title});

  @override
  final String name;

  /// title is not necessary
  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
    Routes.signin => const SignInScreen(),
    Routes.home => const HomeScreen(),
    Routes.profile => const ProfileScreen(),
    Routes.developer => const DeveloperScreen(),
    Routes.settings => const SettingsScreen(),
  };
}
