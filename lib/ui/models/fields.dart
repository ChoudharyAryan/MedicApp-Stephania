import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medapp/ui/functions.dart';

class InputField extends StatelessWidget {
  final String title;
  final String hint;
  final Function(String)? onChange;
  final OnTap? onTap;
  final bool isStyleOnly;
  const InputField({
    super.key,
    required this.title,
    required this.hint,
    this.onTap,
    this.isStyleOnly = false,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Expanded(
              child: isStyleOnly
                  ? InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(
                        hint,
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : TextFormField(
                      autofocus: false,
                      onChanged: onChange,
                      style: subHeadingStyle,
                      decoration: InputDecoration(
                        hintText: hint,
                      ),
                    ))
        ],
      ),
    );
  }
}
