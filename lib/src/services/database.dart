import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familife/src/helpers/familiyHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:overlay_support/overlay_support.dart';

class Database {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  var fs = FirebaseFirestore.instance;

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

  Future fetchFamilyData(familyCode) async {
    var members;
    List data = [];
    await fs
        .collection("families")
        .doc(familyCode)
        .get()
        .then((docSnapshot) async {
      if (docSnapshot.exists) {
        members = docSnapshot.data()!["members"];
      }
    });
    for (var i in members) {
      await fs.collection("users").doc(i).get().then((docSnapshot) async {
        if (docSnapshot.exists) {
          data.add({
            "userName": docSnapshot.data()!["firstName"],
            "imageUrl": docSnapshot.data()!["imageUrl"],
            "userID": docSnapshot.data()!["userID"]
          });
        }
      });
    }
    return data;
  }

  //chat functions
  Future<types.Room> fetchRoom(userID, familyCode) async {
    var room;
    await fs.collection('rooms').doc(familyCode).get().then((doc) async {
      final createdAt = doc.data()?['createdAt'] as Timestamp?;
      var imageUrl = doc.data()?['imageUrl'] as String?;
      final metadata = doc.data()?['metadata'] as Map<String, dynamic>?;
      var name = doc.data()?['name'] as String?;
      final type = doc.data()!['type'] as String;
      final userIds = doc.data()!['userIds'] as List<dynamic>;
      final userRoles = doc.data()?['userRoles'] as Map<String, dynamic>?;

      final users = await Future.wait(
        userIds.map(
          (userId) => fetchUser(
            userId as String,
            role: types.getRoleFromString(userRoles?[userId] as String?),
          ),
        ),
      );

      if (type == types.RoomType.direct.toShortString()) {
        try {
          final otherUser = users.firstWhere(
            (u) => u.id != userID,
          );

          imageUrl = otherUser.imageUrl;
          name = '${otherUser.firstName} ${otherUser.lastName}';
        } catch (e) {
          // Do nothing if other user is not found, because he should be found.
          // Consider falling back to some default values.
        }
      }

      room = types.Room(
        createdAt: createdAt?.millisecondsSinceEpoch,
        id: doc.id,
        imageUrl: imageUrl,
        metadata: metadata,
        name: name,
        type: types.getRoomTypeFromString(type),
        users: users,
      );
    });

    return room;
  }

  Future updateSelectedFamily(_familyCode, _userID) async {
    bool status = true;
    await fs
        .collection("users")
        .doc(_userID)
        .update({"selectedFamily": _familyCode}).catchError((e) {
      print(e.toString());
      toast("$e");
      status = false;
    });
    return status;
  }

  joinNewFamilyData(data) async {
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
    await fs.collection("users").doc(data["newMember"]).update(
      {
        'families': FieldValue.arrayUnion([
          {data["familyID"]: data["familyName"]}
        ]),
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

  Future leaveFamily(userID, families) async {
    bool saveDataStatus = true;
    for (var familyCode in families) {
      await fs.collection("families").doc(familyCode).update({
        'members': FieldValue.arrayRemove([userID]),
      }).catchError((e) {
        print(e.toString());
        toast("$e");
        saveDataStatus = false;
      });
    }
    if (!saveDataStatus) {
      return saveDataStatus;
    }
    await fs.collection("users").doc(userID).update({
      "delete": true,
    }).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    await fs.collection("users").doc(userID).update({
      "families": [],
    }).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  Future createEvent(data, familyCode) async {
    bool saveDataStatus = true;
    await fs.collection("families").doc(familyCode).update(
      {
        'events': FieldValue.arrayUnion([data]),
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  Future fetchEvent(familyCode) async {
    var data;
    await fs.collection('families').doc(familyCode).get().then((doc) async {
      data = doc.data()!["events"];
    });
    return data;
  }

  Future deleteEvent(data, familyCode) async {
    bool saveDataStatus = true;
    await fs.collection("families").doc(familyCode).update(
      {
        'events': FieldValue.arrayRemove([data]),
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  Future createFoodplan(data, familyCode) async {
    bool saveDataStatus = true;
    await fs.collection("families").doc(familyCode).update(
      {
        'foodplan': FieldValue.arrayUnion([data]),
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  Future fetchFoodplan(familyCode) async {
    var data;
    await fs.collection('families').doc(familyCode).get().then((doc) async {
      data = doc.data()!["foodplan"];
    });
    return data;
  }

  Future updateFoodplan(data, familyCode, date) async {
    bool saveDataStatus = true;
    var fetchedData;
    await fs.collection('families').doc(familyCode).get().then((doc) async {
      fetchedData = doc.data()!["foodplan"];
    });
    var updateFetchedDataIndex = fetchedData.indexWhere((e) => e[date] != null);
    fetchedData[updateFetchedDataIndex] = data;
    await fs.collection("families").doc(familyCode).update(
      {
        'foodplan': fetchedData,
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  Future createTodo(data, familyCode) async {
    bool saveDataStatus = true;
    await fs.collection("families").doc(familyCode).update(
      {
        'todos': FieldValue.arrayUnion([data]),
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  Future fetchTodos(familyCode) async {
    var data;
    await fs.collection('families').doc(familyCode).get().then((doc) async {
      data = doc.data()!["todos"];
    });
    return data;
  }

  Future updateTodo(data, familyCode) async {
    bool saveDataStatus = true;
    await fs.collection("families").doc(familyCode).update(
      {
        'todos': data,
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  Future updateNotificationsdb(value, userID) async {
    bool saveDataStatus = true;
    await fs.collection("users").doc(userID).update(
      {
        'notificationStatus': value,
      },
    ).catchError((e) {
      print(e.toString());
      toast("$e");
      saveDataStatus = false;
    });
    return saveDataStatus;
  }

  /// Get the token, save it to the database for current user
  saveDeviceToken(uid) async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    // Get the token for this device
    String? fcmToken = await _fcm.getToken();

    // Save it to Firestore
    await fs.collection('users').doc(uid).update({
      'deviceID': {
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem
      }
    });
  }
}
