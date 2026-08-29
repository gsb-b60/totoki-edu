import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:totoki_extract/business/user/user.dart';
import 'package:totoki_extract/data/user_database/user_dao.dart';

import 'package:totoki_extract/data/user_database/user_db_helper.dart';

class UserNotifier extends ChangeNotifier {
  final UserDao userDao = UserDao(UserDatabaseHelper.instance);

  User? _user;

  User? get user => _user;

  Future<String?> takePictureAndSaveAvatar({
    ImageSource source = ImageSource.camera,
  }) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return null;

    final appDocDir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(appDocDir.path, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final avatarPath = p.join(avatarsDir.path, fileName);
    final avatarFile = File(pickedFile.path).copySync(avatarPath);

    return avatarFile.path;
  }

  Future<void> initialize() async {
    _user = await userDao.getCurrentUser();
    _user ??= await userDao.createLocalUser();
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    await userDao.updateName(name);
    _user = await userDao.getCurrentUser();
    notifyListeners();
  }

  Future<void> updateAvatar(String avatarPath) async {
    await userDao.updateAvatar(avatarPath);
    _user = await userDao.getCurrentUser();
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    if (name != null) await userDao.updateName(name);
    if (email != null) await userDao.updateEmail(email);
    if (phoneNumber != null) await userDao.updatePhoneNumber(phoneNumber);
    _user = await userDao.getCurrentUser();
    notifyListeners();
  }
}
