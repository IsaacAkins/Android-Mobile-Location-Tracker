import 'package:flutter/material.dart';
class landingPage extends StatelessWidget {
  const landingPage({super.key});

  @override
  Widget build(BuildContext context) {
    

    return const Scaffold(
      body: Center(
        child: Column( mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row( mainAxisAlignment: MainAxisAlignment.center,
              children: [ 
                Icon(
                  Icons.check_box,
                  color: Colors.green,
                  size: 30,
                  
                ),
                Text("Registration was successful",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ],
            ),
             Text("Tracking in progress"),

            SizedBox(height: 20),

            


          ],
        )
        ),
    );
  }
}