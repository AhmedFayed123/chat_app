import 'dart:io';

import 'package:chat/widgets/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


final _firebase = FirebaseAuth.instance;
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  File? _selectedImageFile;
  bool _isLogin = true;
  final  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _enteredEmail = TextEditingController();
  TextEditingController _enteredUserName = TextEditingController();
  TextEditingController _enteredPassword = TextEditingController();
  bool _isUploading=false;

  void _submit()async {
    final valid = _formKey.currentState!.validate();
    if (!valid||(!_isLogin&&_selectedImageFile==null)) {
      return;
    }
      try {
      setState(() {
        _isUploading=true;
      });
        if (_isLogin) {
          final UserCredential userCredential = await _firebase
              .signInWithEmailAndPassword(
            email: _enteredEmail.text.trim(),
            password: _enteredPassword.text.trim(),
          );
        }
        else {
          final UserCredential userCredential = await _firebase
              .createUserWithEmailAndPassword(
            email: _enteredEmail.text.trim(),
            password: _enteredPassword.text.trim(),
          );
          final Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child('${userCredential.user!.uid}.jpg');
          await storageRef.putFile(_selectedImageFile!);
          final imageUrl=await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username':_enteredUserName.text,
            'email':_enteredEmail.text,
            'image_url':imageUrl,
          });

        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Authentication failed'))
        );
      }
    setState(() {
      _isUploading=false;
    });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('lib/assets/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if(!_isLogin)  UserImage(onPickImage: (File pickedImage) { _selectedImageFile=pickedImage; },),
                          if(!_isLogin)
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Username',
                            ),
                            controller: _enteredUserName,
                            validator: (value){
                              if(value==null||value.trim().length<4){
                                return 'please enter more than 4 chars.';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            controller: _enteredEmail,
                            validator: (value){
                              if(value==null||value.trim().isEmpty||!value.contains('@')){
                                return 'please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            controller: _enteredPassword,
                            validator: (value){
                              if(value==null||value.trim().length<6){
                                return 'must be at least 6 chars.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15,),
                          if(_isUploading)
                           const CircularProgressIndicator(),
                          if(!_isUploading)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                              onPressed: _submit,
                              child: Text(_isLogin?'Log in':'Sign up'),
                          ),
                          if(!_isUploading)
                            TextButton(
                            onPressed: (){
                              setState(() {
                                _isLogin=!_isLogin;
                              });
                            },
                            child: Text(_isLogin?'Create account':'I already have an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
