// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/admin/manageplants.dart';
import 'package:flutter_app/assets/textfield_admin.dart';
import 'package:flutter_app/services/plant_services.dart';
import 'package:image_picker/image_picker.dart';

class AddPlant extends StatefulWidget {
  const AddPlant({super.key});

  @override
  State<AddPlant> createState() => _AddPlantState();
}

class _AddPlantState extends State<AddPlant> {
  var nameController = TextEditingController();
  var priceController = TextEditingController();
  var descController = TextEditingController();
  var waterController = TextEditingController();
  var sunlightController = TextEditingController();
  var temperatureController = TextEditingController();
  var fertilizerController = TextEditingController();

  bool valid = true;
  List<bool> formValid = List.filled(7, true);
  
  File? image;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Success")),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[300]),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagePlants()));
                },
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Plant"),
        backgroundColor: Colors.green[300],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.grey[800],
                    ),
                  )
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldAdmin(
                        controller: nameController,
                        label: "Name",
                        valid: formValid[0],
                      ),
                    ),
                    Expanded(
                      child: TextFieldAdmin(
                        controller: priceController,
                        label: "Price",
                        number: true,
                        valid: formValid[1],
                      ),
                    ),
                  ],
                ),
                TextFieldAdmin(
                  controller: descController,
                  label: "Description",
                  desc: true,
                  valid: formValid[2],
                ),
                TextFieldAdmin(
                  controller: waterController,
                  label: "Water",
                  desc: true,
                  valid: formValid[3],
                ),
                TextFieldAdmin(
                  controller: sunlightController,
                  label: "Sunlight",
                  desc: true,
                  valid: formValid[4],
                ),
                TextFieldAdmin(
                  controller: temperatureController,
                  label: "Temperature",
                  desc: true,
                  valid: formValid[5],
                ),
                TextFieldAdmin(
                  controller: fertilizerController,
                  label: "Fertilizer",
                  desc: true,
                  valid: formValid[6],
                ),
                if(!valid) 
                  const Text("All input must not be empty",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      formValid[0] = nameController.value.text.isNotEmpty;
                      formValid[1] = priceController.value.text.isNotEmpty;
                      formValid[2] = descController.value.text.isNotEmpty;
                      formValid[3] = waterController.value.text.isNotEmpty;
                      formValid[4] = sunlightController.value.text.isNotEmpty;
                      formValid[5] = temperatureController.value.text.isNotEmpty;
                      formValid[6] = fertilizerController.value.text.isNotEmpty;

                      valid = formValid.every((valid) => valid);

                      if (valid) {
                        PlantService.createPlant({
                          "name": nameController.text,
                          "price": priceController.text,
                          "desc": descController.text,
                          "water": waterController.text,
                          "sunlight": sunlightController.text,
                          "temperature": temperatureController.text,
                          "fertilizer": fertilizerController.text
                        }, image);
                        showSuccessDialog();
                      }
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green[300]),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    textStyle: MaterialStateProperty.all(const TextStyle(
                      shadows: [Shadow(color: Colors.black, blurRadius: 50)]
                    ))
                  ),
                  child: const Text("Create Data"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}