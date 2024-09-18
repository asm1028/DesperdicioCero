import 'package:flutter/material.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Clase que representa un widget de autocompletado personalizado.
///
/// Este widget se utiliza para mostrar un campo de texto con funcionalidad de autocompletado.
/// Proporciona una lista de sugerencias y permite al usuario seleccionar una opción de la lista.
///
/// Para utilizar este widget, se debe proporcionar un [TextEditingController] que controlará el valor del campo de texto,
/// una lista de [suggestions] que contiene las sugerencias a mostrar al usuario,
/// una función [onChanged] opcional que se llamará cuando el valor del campo de texto cambie,
/// un [validator] opcional que se utilizará para validar el valor del campo de texto,
/// y un [maxLength] opcional que indica la longitud máxima del texto permitido.
class CustomAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final int maxLength;

  CustomAutocomplete({
    super.key,
    required this.controller,
    required this.suggestions,
    this.onChanged,
    this.validator,
    this.maxLength = 40,
  });

  @override
  _CustomAutocompleteState createState() => _CustomAutocompleteState();
}

/// Clase que representa el estado de un widget de autocompletado personalizado.
class _CustomAutocompleteState extends State<CustomAutocomplete> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${widget.maxLength - widget.controller.text.length} caracteres restantes',
            style: TextStyle(fontSize: 14)
          ),
        ),
        SizedBox(height: 5),
        EasyAutocomplete(
          controller: widget.controller,
          suggestions: widget.suggestions,
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
          onChanged: widget.onChanged,
          validator: widget.validator,
        ),
      ],
    );
  }
}