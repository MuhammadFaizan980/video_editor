import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Color.fromRGBO(23, 58, 112, 1),
      fontSize: 16.0,
    );
  }

  static push(context, object) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => object),
    );
  }

  static pushReplacement(context, object) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => object),
    );
  }

  static double getScreenWidth(context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(context) {
    return MediaQuery.of(context).size.height;
  }

  static circularLoader(context) {
    return Container(
      width: Utils.getScreenWidth(context),
      height: Utils.getScreenHeight(context),
      color: Colors.black12,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        backgroundColor: Colors.black38,
      ),
    );
  }

  static errorBody(String error) {
    return Center(
      child: Text(
        error,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget getTextField({
    @required controller,
    @required label,
    @required icon,
    @required fieldNode,
    @required textInputType,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: fieldNode,
      keyboardType: textInputType,
      obscureText: isPassword,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(16),
        labelText: label,
        labelStyle: TextStyle(
          color: fieldNode.hasFocus ? Colors.white : Colors.grey,
        ),
        prefixIcon: Icon(
          icon,
          color: fieldNode.hasFocus ? Colors.white : Colors.grey,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // static getOutlinedButton(
  //   String label,
  //   IButtonClicked iButtonClicked,
  //   ButtonType buttonType,
  // ) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: TextButton(
  //           onPressed: () {
  //             iButtonClicked.onButtonClicked(buttonType);
  //           },
  //           child: Text(
  //             label,
  //             style: TextStyle(
  //               color: Colors.grey,
  //             ),
  //           ),
  //           style: ButtonStyle(
  //             shape: MaterialStateProperty.all(
  //               RoundedRectangleBorder(
  //                 side: BorderSide(
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // static getButton(
  //   String label,
  //   IButtonClicked iButtonClicked,
  //   ButtonType buttonType,
  // ) {
  //   return TextButton(
  //     onPressed: () {
  //       iButtonClicked.onButtonClicked(buttonType);
  //     },
  //     child: Text(
  //       label,
  //       style: TextStyle(
  //         color: MyColors.DARK_BLUE,
  //       ),
  //     ),
  //     style: ButtonStyle(
  //       backgroundColor: MaterialStateProperty.all(Colors.white),
  //       shape: MaterialStateProperty.all(
  //         RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(32),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  static void hideKeyboard(context) {
    FocusScope.of(context).unfocus();
  }
}
