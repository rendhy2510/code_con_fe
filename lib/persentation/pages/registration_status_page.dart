import 'dart:math';

import 'package:code_con_fe/data/code_con_repository.dart';
import 'package:code_con_fe/data/domain/entities/reservation.dart';
import 'package:code_con_fe/data/domain/entities/tresult.dart';
import 'package:code_con_fe/persentation/constan.dart';
import 'package:code_con_fe/persentation/extensions/build_context_extension.dart';
import 'package:code_con_fe/persentation/providers/router_provider.dart';
import 'package:code_con_fe/persentation/widgets/code_con_app_bar.dart';
import 'package:code_con_fe/persentation/widgets/error_dialog.dart';
import 'package:code_con_fe/persentation/widgets/registration_status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationStatusPage extends ConsumerStatefulWidget {
  const RegistrationStatusPage({super.key});

  @override
  ConsumerState<RegistrationStatusPage> createState() =>
      _RegistrationStatusPageState();
}

class _RegistrationStatusPageState
    extends ConsumerState<RegistrationStatusPage> {
  final _formKey = GlobalKey<FormState>(); // Tambahkan form key
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tertiaryColor,
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: CodeConAppBar(),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            ListView(
              children: [
                Center(
                  child: SizedBox(
                    width: min(context.contentWidth - 40, 700),
                    child: Form(
                      // Wrap dengan Form
                      key: _formKey,
                      child: Column(
                        children: [
                          sizeBoxHight60,
                          const Text(
                            'Please enter your email to check your registration status',
                            style: TextStyle(fontSize: 16),
                          ),
                          sizeBoxHight40,
                          TextFormField(
                            // Ganti TextField menjadi TextFormField
                            controller: emailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter Your Email',
                              labelText: 'Email',
                              helperText:
                                  'Enter the email you used for registration',
                              helperStyle: TextStyle(fontSize: 12),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email tidak boleh kosong';
                              }

                              final trimmedValue = value.trim();

                              // Basic email format validation
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

                              if (!emailRegex.hasMatch(trimmedValue)) {
                                return 'Format email tidak valid';
                              }

                              // Only allow gmail.com domain if still needed
                              if (!trimmedValue
                                  .toLowerCase()
                                  .endsWith('@gmail.com')) {
                                return 'Hanya email dengan domain gmail.com yang diperbolehkan';
                              }

                              return null;
                            },
                          ),
                          sizeBoxHight40,
                          isLoading
                              ? pingProgressIndicator
                              : ElevatedButton(
                                  style: const ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(secoundaryColor),
                                  ),
                                  onPressed: () {
                                    // Validasi form sebelum melakukan request
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      // Gunakan trimmed value untuk request
                                      final trimmedEmail =
                                          emailController.text.trim();

                                      CodeConRepository()
                                          .checkReservation(trimmedEmail)
                                          .then((value) {
                                        switch (value) {
                                          case Success<Reservation>(
                                              :final data
                                            ):
                                            if (context.mounted) {
                                              context.show(
                                                RegistrationStatusDialog(
                                                    reservation: data),
                                              );
                                            }
                                          case Failure<Reservation>(
                                              :final message
                                            ):
                                            if (context.mounted) {
                                              context.show(
                                                ErrorDialog(message: message),
                                              );
                                            }
                                        }
                                        setState(() {
                                          isLoading = false;
                                        });
                                      });
                                    } else {
                                      // Jika validasi gagal, tampilkan error dialog
                                      context.show(const ErrorDialog(
                                          message:
                                              'Silakan perbaiki email yang dimasukkan'));
                                    }
                                  },
                                  child: const Text(
                                    'Check Registration',
                                    style: TextStyle(color: Colors.white),
                                  )),
                          sizeBoxHight60,
                          const Text("Haven't registered yet?"),
                          Wrap(
                            children: [
                              const Text('Please register '),
                              InkWell(
                                onTap: () {
                                  ref.watch(routerProvider).goNamed('register');
                                },
                                child: const Text(
                                  'Here',
                                  style: TextStyle(color: secoundaryColor),
                                ),
                              )
                            ],
                          ),
                          sizeBoxHight10,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
