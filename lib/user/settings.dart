// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_app/assets/textfield_main.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/user/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  late SharedPreferences prefs;
  var nameController = TextEditingController();
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var addressController = TextEditingController();
  var confirmController = TextEditingController();
  var phoneController = TextEditingController();
  
  bool valid = true;
  bool confirmValid = true;
  List<bool> formValid = List.filled(6, true);
  String errorText = "";

  String currentUsername = "";
  String currentEmail = "";
  String currentPassword = "";
  
  @override
  void initState(){
    super.initState();
    initializeUser();
  }

  void initializeUser() async {
    prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('name')!;
    usernameController.text = prefs.getString('username')!;
    emailController.text = prefs.getString('email')!;
    passwordController.text = prefs.getString('password')!;
    addressController.text = prefs.getString('address')!;
    phoneController.text = prefs.getString('phoneNumber')!;

    currentUsername = prefs.getString('username')!;
    currentEmail = prefs.getString('email')!;
    currentPassword = prefs.getString('password')!;

    setState(() {});
  }

  void showConfirmDialog(){
    confirmValid = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text("Masukkan Password Lama",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            )
          ),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextField(
                      controller: confirmController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(
                            color: confirmValid ? Colors.black : Colors.red
                          )
                        )
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 5),
                    if(!confirmValid) 
                      const Text("Password salah",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue[300]),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          child: const Text("Cancel"),
                          onPressed: () async{ 
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20,),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green[300]),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          child: const Text("Confirm"),
                          onPressed: () async {
                            if (confirmController.text != currentPassword) {
                              setState(() {
                                confirmValid = false;
                              });
                            }
                            else {
                              setState(() {
                                confirmValid = true;
                              });
                            }

                            if (confirmValid) {
                              await UserService.updateUser({
                                "name": nameController.text,
                                "username": usernameController.text,
                                "email": emailController.text,
                                "password": passwordController.text,
                                "address": addressController.text,
                                "phoneNumber": phoneController.text
                              });

                              Navigator.push(context, MaterialPageRoute(builder: (context) => const NavBar(initIndex: 4)));
                            }
                          },
                        ),
                      ]
                    )
                  ],
                );
              }
            )
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 255, 242),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green[200],
        title: const Text("Atur Profil", style:
          TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                ),
                const SizedBox(height: 20),
                TextFieldMain(
                  controller: phoneController,
                  label: "Nomor Telepon",
                  hintText: "Nomor Telepon",
                  valid: formValid[5],
                  number: true,
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
                    width: 110,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:() async {
                        setState(() {
                          formValid[0] = nameController.value.text.isNotEmpty;
                          formValid[1] = usernameController.value.text.isNotEmpty;
                          formValid[2] = emailController.value.text.isNotEmpty;
                          formValid[3] = passwordController.value.text.isNotEmpty;
                          formValid[4] = addressController.value.text.isNotEmpty;
                          formValid[5] = phoneController.value.text.isNotEmpty;

                          valid = formValid.every((valid) => valid);
                        });

                        if (valid) {
                          String response = await UserService.validateUserData({
                            "username": usernameController.text,
                            "email": emailController.text,
                            "password": passwordController.text,
                            "oldUsername": currentUsername,
                            "oldEmail": currentEmail
                          });

                          if (response == "success") {
                            showConfirmDialog();
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
                            });
                          }
                        } else {
                          setState(() {
                            valid = false;
                            errorText = "Data user tidak valid";
                          });
                        }
                      },
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(
                            fontSize: 16,
                          )
                        ),
                        backgroundColor: MaterialStateProperty.all(Colors.green,),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                        )
                      ),
                      child: const Text("Perbarui"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}