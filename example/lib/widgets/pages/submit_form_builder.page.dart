import 'package:example/utils/message.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class SubmitFormBuilderPage extends StatefulWidget {
  const SubmitFormBuilderPage({super.key});

  @override
  State<SubmitFormBuilderPage> createState() => _SubmitFormBuilderPageState();
}

class _SubmitFormBuilderPageState extends State<SubmitFormBuilderPage> {
  String? value;

  @override
  Widget build(BuildContext context) {
    return SubmitFormBuilder<String>(
      onChanged: () => print('Form changed'),
      //onUnsavedFormPop: SubmitFormBuilder.alwaysAllowFormPopCallback,    // Uncomment to override behavior set in main.dart
      onSuccess: (result) => showMessage(context, result),
      builder: (context, validate) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // Caption
              const Text('AsyncForm is a wrapper around AsyncTaskBuilder adapted for form validation.'),

              // Form
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Enter any value'),
                validator: (value) => value!.isEmpty ? 'Value cannot be empty' : null,
                onSaved: (value) => this.value = value,
              ),

              // Submit button
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => validate(() => Future.delayed(const Duration(seconds: 2), () => 'Form validated with value: "$value"\n${DateTime.now()}')),
                child: const Text('Validate form and run task'),
              ),
            ],
          ),
        );
      }
    );
  }
}
