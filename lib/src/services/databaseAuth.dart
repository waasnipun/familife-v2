import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DatabaseAuth {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  var fs = FirebaseFirestore.instance;

  saveUserData(data) async {
    print("---------------");
    print(data);
    print("---------------");

    bool saveDataStatus = true;
    String userID = data["userID"];
    //uploading image
    if (data["imageUrl"] == null) {
      data["imageUrl"] = "";
      await fs
          .collection("users")
          .doc(data["userID"])
          .set(data)
          .catchError((e) {
        print(e.toString());
        toast("$e");
        saveDataStatus = false;
      });
    } else {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('Users')
          .child('/$userID.jpg');
      firebase_storage.UploadTask uploadTask;
      uploadTask = ref.putFile(data["imageUrl"]);
      await uploadTask.whenComplete(() async {
        print('File Uploaded');
        //uploading to firestore
        await ref.getDownloadURL().then((fileURL) async {
          data["imageUrl"] = fileURL;
          await fs
              .collection("users")
              .doc(data["userID"])
              .set(data)
              .catchError((e) {
            print(e.toString());
            toast("$e");
            saveDataStatus = false;
          });
        });
      });
    }
    return saveDataStatus;
  }

  createFamilyData(data) async {
    bool saveDataStatus = true;
    await fs
        .collection("families")
        .doc(data["familyID"])
        .set(data)
        .catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  joinFamilyData(data) async {
    bool saveDataStatus = true;
    await fs.collection("families").doc(data["familyID"]).update(
      {
        'members': FieldValue.arrayUnion([data["newMember"]]),
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });

    //for chatting area
    await fs.collection("rooms").doc(data["familyID"]).update(
      {
        'userIds': FieldValue.arrayUnion([data["newMember"]]),
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  Future checkFamilyCodeValidity(familyId) async {
    var data = {"status": "INVALID"};
    await fs.collection("families").get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.id == familyId) {
          data = {"status": "OK", "familyName": doc["familyName"]};
        }
      });
    });
    return data;
  }

  Future checkUserDataAvailability(userID) async {
    bool status = false;
    var data;
    await fs.collection("users").get().then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.length == 0) {
        return false;
      }
      querySnapshot.docs.forEach((doc) {
        if (doc.id == userID) {
          data = doc.data();
          if (!data["delete"]) {
            status = true;
          }
        }
      });
    });
    return status;
  }

  Future fetchUserAndFamilyData(userID) async {
    var data;
    await fs
        .collection("users")
        .doc(userID)
        .get()
        .then((DocumentSnapshot docSnapshot) async {
      if (docSnapshot.exists) {
        data = docSnapshot.data();
        data["documentExist"] = true;
      } else {
        data["documentExist"] = false;
      }
    });
    return data;
  }
}
