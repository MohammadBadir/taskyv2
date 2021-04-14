import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/constants/strings.dart';
import 'sign_in_widget_model.dart';
import 'widgets/google_sign_in_button.dart';

class SignInWidget extends StatelessWidget {
  const SignInWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInViewModel>(
      create: (_) => SignInViewModel(context.read),
      builder: (_, child) {
        return const Scaffold(
          body: SignInViewBody._(),
        );
      },
    );
  }
}

class SignInViewBody extends StatelessWidget {
  const SignInViewBody._({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select((SignInViewModel viewModel) => viewModel.isLoading);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              Strings.signInMessage,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          isLoading ? _loadingIndicator() : _signInButtons(context),
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return CircularProgressIndicator();
  }

  Widget _signInButtons(BuildContext context) {
    return const GoogleSignInButton();
  }
}
