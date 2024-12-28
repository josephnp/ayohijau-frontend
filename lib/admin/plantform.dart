import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/admin/manageplants.dart';
import 'package:flutter_app/assets/textfield_admin.dart';
import 'package:flutter_app/model/plant_model.dart';
import 'package:flutter_app/services/plant_services.dart';
import 'package:image_picker/image_picker.dart';

class PlantForm extends StatefulWidget {
  final Plant? data;
  const PlantForm({super.key, this.data});

  @override
  State<PlantForm> createState() => _PlantFormState();
}

class _PlantFormState extends State<PlantForm> {
  var nameController = TextEditingController();
  var priceController = TextEditingController();
  var descController = TextEditingController();
  var waterController = TextEditingController();
  var sunlightController = TextEditingController();
  var temperatureController = TextEditingController();
  var fertilizerController = TextEditingController();
  
  File? image;

  bool valid = true;
  bool imageLoading = false;
  bool isLoading = false;
  List<bool> formValid = List.filled(10, true);
  
  @override
  void initState(){
    super.initState();

    if (widget.data != null) initializeData();
  }

  void initializeData() {
    nameController.text = widget.data!.name.toString();
    priceController.text = widget.data!.price.toString();
    descController.text = widget.data!.desc.toString();
    waterController.text = widget.data!.water.toString();
    sunlightController.text = widget.data!.sunlight.toString();
    temperatureController.text = widget.data!.temperature.toString();
    fertilizerController.text = widget.data!.fertilizer.toString();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  Future<void> showSuccessDialog() async {
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
        title: widget.data == null ? const Text("Add Plant") : const Text("Update Plant"),
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
                  child: image == null
                    ? widget.data == null
                      ? Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(
                              color: formValid[0] ? Colors.grey.shade200 : Colors.red
                            )
                          ),
                          child: imageLoading
                            ? const CircularProgressIndicator()
                            : Icon(
                              Icons.add_a_photo,
                              color: Colors.grey[800],
                            ),
                        )
                      : Image.network(
                          widget.data!.imageUrl,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                    : Image.file(
                        image!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldAdmin(
                        controller: nameController,
                        label: "Name",
                        valid: formValid[1],
                      ),
                    ),
                    Expanded(
                      child: TextFieldAdmin(
                        controller: priceController,
                        label: "Price",
                        number: true,
                        valid: formValid[2],
                      ),
                    ),
                  ],
                ),
                TextFieldAdmin(
                  controller: descController,
                  label: "Description",
                  desc: true,
                  valid: formValid[3],
                ),
                TextFieldAdmin(
                  controller: waterController,
                  label: "Water",
                  desc: true,
                  valid: formValid[4],
                ),
                TextFieldAdmin(
                  controller: sunlightController,
                  label: "Sunlight",
                  desc: true,
                  valid: formValid[5],
                ),
                TextFieldAdmin(
                  controller: temperatureController,
                  label: "Temperature",
                  desc: true,
                  valid: formValid[6],
                ),
                TextFieldAdmin(
                  controller: fertilizerController,
                  label: "Fertilizer",
                  desc: true,
                  valid: formValid[7],
                  last: true,
                ),
                const SizedBox(height: 20),
                if(!valid) 
                  const Text("All input must not be empty",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() {
                      isLoading = true;
                    });

                    setState(() {
                      if (image == null && widget.data == null) formValid[0] = false;
                      formValid[1] = nameController.value.text.isNotEmpty;
                      formValid[2] = priceController.value.text.isNotEmpty;
                      formValid[3] = descController.value.text.isNotEmpty;
                      formValid[4] = waterController.value.text.isNotEmpty;
                      formValid[5] = sunlightController.value.text.isNotEmpty;
                      formValid[6] = temperatureController.value.text.isNotEmpty;
                      formValid[7] = fertilizerController.value.text.isNotEmpty;

                      valid = formValid.every((valid) => valid);
                    });
                    
                    if (valid) {
                      if (widget.data == null) {
                        await PlantService.createPlant({
                          "name": nameController.text,
                          "price": priceController.text,
                          "desc": descController.text,
                          "water": waterController.text,
                          "sunlight": sunlightController.text,
                          "temperature": temperatureController.text,
                          "fertilizer": fertilizerController.text
                        }, image);
                      } else {
                        await PlantService.updatePlant(widget.data!.id, {
                          "id": widget.data!.id,
                          "name": nameController.text,
                          "price": priceController.text,
                          "desc": descController.text,
                          "water": waterController.text,
                          "sunlight": sunlightController.text,
                          "temperature": temperatureController.text,
                          "fertilizer": fertilizerController.text,
                        }, image, widget.data!.imageUrl);
                      }
                      showSuccessDialog();
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: isLoading
                      ? MaterialStateProperty.all(const Color.fromARGB(255, 204, 204, 204))
                      : MaterialStateProperty.all(Colors.green[300]),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    textStyle: MaterialStateProperty.all(const TextStyle(
                      shadows: [Shadow(color: Colors.black, blurRadius: 50)],
                      fontSize: 14
                    ))
                  ),
                  child: isLoading
                    ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2,))
                    : widget.data == null ? const Text("Add Plant") : const Text("Update Data"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}