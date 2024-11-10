import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// class ApplicationController extends GetxController {
//   // Singleton instance of ApplicationController using GetX's dependency injection
//   static ApplicationController get instance => Get.find();

//   // Observables for previous transactions and transaction count
//   RxList<List<dynamic>> prevTrans =
//       <List<dynamic>>[].obs; // Observable list of transactions
//   RxInt numTrans = 0.obs; // Observable integer for number of transactions

//   @override
//   void onInit() async {
//     // Called when the controller is initialized, similar to a constructor
//     super.onInit();

//     // Fetch stored previous transactions and the transaction count from SharedPreferences
//     prevTrans.value = await getPrefs();
//     numTrans.value = await getNumTrans();

//     // Debugging logs to see the fetched data
//     print(prevTrans);
//   }

//   // Method to retrieve previous transactions from SharedPreferences
//   Future<List<List<dynamic>>> getPrefs() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Check if the key "prevTrans" exists in SharedPreferences
//     if (prefs.containsKey("prevTrans")) {
//       String? prv = await prefs.getString("prevTrans");

//       if (prv != null) {
//         print(prv); // Log the string format of previous transactions

//         // Attempt to fix JSON format by adding quotes around any word-like keys
//         String jsonReplaced = prv.replaceAllMapped(
//             RegExp(r'([a-zA-Z-:/]+)(?=,)'), (match) => '"${match.group(0)}"');
//         print(jsonReplaced);

//         List<List<dynamic>> output = List.from(jsonDecode(jsonReplaced));
//         print("here");
//         print(output.toString());
//         return output;
//       }
//     }
//     return [];
//   }

//   // Method to create and store a new transaction
//   Future createTransaction(List<dynamic> trn) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Fetch existing transactions and add the new one to the list
//     prevTrans.value = await getPrefs();
//     prevTrans.add(trn);

//     // Store the updated transaction list as a string in SharedPreferences
//     await prefs.setString("prevTrans", prevTrans.toString());

//     print(trn.toString());
//   }

//   // Method to retrieve the current number of transactions from SharedPreferences
//   Future<int> getNumTrans() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Check if the "numTrans" key exists and return its value if found
//     if (prefs.containsKey("numTrans")) {
//       int? numI = await prefs.getInt("numTrans");
//       if (numI != null) {
//         return numI;
//       }
//     } else {
//       // If no value is found, initialize it to 0 in SharedPreferences
//       prefs.setInt("numTrans", 0);
//     }

//     return 0;
//   }

//   // Method to increment the number of transactions
//   Future incrementTransNumber() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Increment the observable transaction count
//     numTrans += 1;

//     // Store the updated number of transactions in SharedPreferences
//     prefs.setInt("numTrans", numTrans.value);
//   }
// }

class ApplicationController extends GetxController {
  // Singleton instance of ApplicationController using GetX's dependency injection
  static ApplicationController get instance => Get.find();

  RxList<List<dynamic>> prevTrans = <List<dynamic>>[].obs;
  RxInt numTrans = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    prevTrans.value = await getPrefs();
    numTrans.value = await getNumTrans();
  }

  Future<List<List<dynamic>>> getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("prevTrans")) {
      String? prv = await prefs.getString("prevTrans");
      if (prv != null) {
        String jsonReplaced = prv.replaceAllMapped(
            RegExp(r'([a-zA-Z-:/]+)(?=,)'), (match) => '"${match.group(0)}"');
        List<List<dynamic>> output = List.from(jsonDecode(jsonReplaced));
        return output;
      }
    }
    return [];
  }

  Future createTransaction(List<dynamic> trn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prevTrans.value = await getPrefs();
    prevTrans.add(trn);
    await prefs.setString("prevTrans", prevTrans.toString());
  }

  Future<int> getNumTrans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("numTrans")) {
      int? numI = await prefs.getInt("numTrans");
      if (numI != null) {
        return numI;
      }
    } else {
      prefs.setInt("numTrans", 0);
    }
    return 0;
  }

  Future incrementTransNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    numTrans += 1;
    prefs.setInt("numTrans", numTrans.value);
  }

  // New method to delete a transaction
  Future deleteTransaction(int transNum) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Find the transaction to delete
    prevTrans.value = await getPrefs();
    prevTrans.removeWhere((trans) =>
        trans[0] == transNum); // Assuming transaction number is in index 0

    // Update SharedPreferences with the new list
    await prefs.setString("prevTrans", prevTrans.toString());

    // Decrement the number of transactions
    numTrans -= 1;
    prefs.setInt("numTrans", numTrans.value);
  }
}
