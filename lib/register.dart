// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_app/login.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/assets/textfield_main.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var nameController = TextEditingController();
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var addressController = TextEditingController();
  var phoneController = TextEditingController();

  bool valid = true;
  List<bool> formValid = List.filled(6, true);
  String errorText = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 255, 242),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 28,
                        color: Colors.black
                      ),
                    ),
                    const SizedBox(width: 40),
                    const Text("PENDAFTARAN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  ]
                ),
                const SizedBox(height: 30),
                TextFieldMain(
                  controller: nameController, 
                  label: "Nama", 
                  hintText: "Nama Lengkap",
                  valid: formValid[0],
                ),
                const SizedBox(height: 20),
                TextFieldMain(
                  controller: usernameController,
                  label: "Username",
                  hintText: "Username",
                  valid: formValid[1],
                ),
                const SizedBox(height: 20),
                TextFieldMain(
                  controller: emailController, 
                  label: "Email", 
                  hintText: "Email",
                  email: true,
                  valid: formValid[2],
                ),
                const SizedBox(height: 20),
                TextFieldMain(
                  controller: passwordController,
                  label: "Password",
                  hintText: "Password (min. 6 karakter)",
                  password: true,
                  valid: formValid[3],
                ),
                const SizedBox(height: 20),
                TextFieldMain(
                  controller: addressController, 
                  label: "Alamat", 
                  hintText: "Alamat Domisili",
                  valid: formValid[4],
                  address: true,
                ),
                const SizedBox(height: 20),
                TextFieldMain(
                  controller: phoneController,
                  label: "Nomor Telepon",
                  hintText: "Nomor Telepon",
                  valid: formValid[5],
                  number: true,
                  last: true,
                ),
                const SizedBox(height: 30),
                if(!valid) 
                  Text(errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 8,),
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () async {
                        setState(() {
                          isLoading = true;

                          formValid[0] = nameController.value.text.isNotEmpty;
                          formValid[1] = usernameController.value.text.isNotEmpty;
                          formValid[2] = emailController.value.text.isNotEmpty;
                          formValid[3] = passwordController.value.text.isNotEmpty;
                          formValid[4] = addressController.value.text.isNotEmpty;
                          formValid[5] = phoneController.value.text.isNotEmpty;

                          valid = formValid.every((valid) => valid);
                        });

                        if (valid) {
                          String response = await UserService.register({
                            "name": nameController.text,
                            "username": usernameController.text,
                            "email": emailController.text,
                            "password": passwordController.text,
                            "address": addressController.text,
                            "phoneNumber": phoneController.text,
                            "role": "User",
                            "point": 0,
                          });
                          
                          if (response == "success") {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                          } else {
                            setState(() {
                              valid = false;
                              errorText = response;

                              if (errorText.contains("Username")) {
                                formValid[1] = false;
                              }
                              if (errorText.contains("Email")) {
                                formValid[2] = false;
                              }
                              if (errorText.contains("Password")) {
                                formValid[3] = false;
                              }
                              
                              isLoading = false;
                            });
                          }
                        } else {
                          setState(() {
                            valid = false;
                            errorText = "Pendaftaran tidak valid";
                            isLoading = false;
                          });
                        }
                      },
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(
                            fontSize: 16,
                          )
                        ),
                        backgroundColor: isLoading
                          ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                          : MaterialStateProperty.all(const Color.fromARGB(255, 94, 91, 255)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                        )
                      ),
                      child: isLoading
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                        : const Text("Daftar"),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}