import 'package:flutter/material.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;

  CustomAutocomplete({
    Key? key,
    required this.controller,
    required this.suggestions,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyAutocomplete(
      controller: controller,
      suggestions: suggestions,
      decoration: InputDecoration(
        hintText: 'Nombre del producto',
        hintStyle: TextStyle(color: Colors.grey[550]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        prefixIcon: Icon(FontAwesomeIcons.carrot, color: Color.fromARGB(255, 192, 70, 70)),
      ),
      suggestionBuilder: (data) {
        return Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!))
          ),
          child: Text(
            data,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            )
          )
        );
      },
      onChanged: onChanged,
      validator: validator,
    );
  }
}
