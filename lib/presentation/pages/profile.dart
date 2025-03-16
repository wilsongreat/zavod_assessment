import 'package:flutter/material.dart';
import 'package:zavod_assessment_app/presentation/components/custom_btn.dart';
import 'package:zavod_assessment_app/presentation/components/custom_input.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _firstNameController,
                fieldLabel: 'First Name',
                hint: 'First Name',
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _lastNameController,
                fieldLabel: 'Last Name',
                hint: 'Last Name',
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _emailController,
                fieldLabel: 'Email',
                hint: 'Email',
              ),

              const SizedBox(height: 20),
              Spacer(),
              CustomAppButton(
                title: "Save",
                height: 50,
                voidCallback: (){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile saved!')),
                  );
              },),
              const SizedBox(height: 40),


            ],
          ),
        ),
      ),
    );
  }
}
