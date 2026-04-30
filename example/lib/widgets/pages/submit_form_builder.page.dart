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
      scrollToFirstInvalidField: true,
      onChanged: () => debugPrint('Form changed'),
      //onUnsavedFormPop: SubmitFormBuilder.ignoreFormPopCallback,    // Uncomment to override behavior set in main.dart
      onSuccess: (result) => showMessage(context, result),
      builder: (context, validate) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Caption
              const Text(
                'SubmitFormBuilder is a wrapper around SubmitBuilder adapted for form validation.\n\n'
                'scrollToFirstInvalidField is enabled: leave the required field empty and scroll down to '
                'the submit button — the view will jump back to the error on validation.',
              ),

              // Required field (validator) — at the top, far from the submit button
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Required field (must not be empty)'),
                validator: (value) => (value == null || value.isEmpty) ? 'Value cannot be empty' : null,
                onSaved: (v) => value = v,
              ),

              // Filler fields (optional, always valid) — push the submit button far down
              const SizedBox(height: 12),
              for (int i = 1; i <= 10; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Optional field $i'),
                  ),
                ),

              // Submit button
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => validate(() => Future.delayed(const Duration(seconds: 2), () => 'Form validated with value: "$value"\n${DateTime.now()}')),
                child: const Text('Validate form and run task'),
              ),
            ],
          ),
        );
      },
    );
  }
}
