import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

import 'fetch_builder.page.dart';

class AsyncFormPage extends StatefulWidget {
  const AsyncFormPage({super.key});

  @override
  State<AsyncFormPage> createState() => _AsyncFormPageState();
}

class _AsyncFormPageState extends State<AsyncFormPage> {
  String? value;

  @override
  Widget build(BuildContext context) {
    return AsyncForm<String>(
      onSuccess: (result) async => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result),
      )),
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
