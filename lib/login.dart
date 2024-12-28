// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/admin/admin.dart';
import 'package:flutter_app/register.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/assets/textfield_main.dart';
import 'package:flutter_app/user/navbar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  bool valid = true;
  List<bool> formValid = List.filled(2, true);
  String errorText = "";
  bool isLoading = false;

  Future<bool> onWillPop() async {
    SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 255, 242),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Image(image: AssetImage('assets/img/logo.png'), width: 200, height: 200,)
                  ),
                  const SizedBox(height: 30),
                  TextFieldMain(
                    controller: emailController,
                    label: "Username/Email",
                    hintText: "Username / Email",
                    email: true,
                    valid: formValid[0],
                  ),
                  const SizedBox(height: 20),
                  TextFieldMain(
                    controller: passwordController,
                    label: "Password",
                    hintText: "Password",
                    password: true,
                    last: true,
                    valid: formValid[1],
                  ),
                  const SizedBox(height: 30),
                  if(!valid) 
                    Center(
                      child: Text(errorText,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
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

                            formValid[0] = emailController.value.text.isNotEmpty;
                            formValid[1] = passwordController.value.text.isNotEmpty;

                            valid = formValid.every((valid) => valid);
                          });

                          if (valid) {
                            String response = await UserService.login({
                                "email": emailController.text,
                                "password": passwordController.text
                            });
                            
                            if (response == "Admin" || response == "User") {
                              if (response == "Admin") {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const Admin()));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder:(context) => const NavBar(initIndex: 0,)));
                              }
                            } else {
                              setState(() {
                                valid = false;
                                errorText = response;

                                if (errorText.contains("kan")) {
                                  formValid[0] = false;
                                }
                                if (errorText.contains("Password")) {
                                  formValid[1] = false;
                                }
                                
                                isLoading = false;
                              });
                            }
                          } else {
                            setState(() {
                              valid = false;
                              errorText = "Login tidak valid";
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
                            : MaterialStateProperty.all(const Color.fromARGB(255, 22, 166, 0),),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                          )
                        ),
                        child: isLoading
                          ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                          : const Text("Masuk"),
                      ),
                    )
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: IntrinsicWidth(
                      child: Row(
                        children: [
                          const Text("Belum punya akun?"),
                          const SizedBox(width: 8,),
                          GestureDetector(
                            onTap:() {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Register()));
                            },
                            child: const Text("Daftar di sini",
                              style: TextStyle(
                                color: Color.fromARGB(255, 42, 127, 255),
                                decoration: TextDecoration.underline,
                                decorationThickness: 2
                              ),
                            )
                          )
                        ], 
                      ),
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
