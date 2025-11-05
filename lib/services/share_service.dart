import 'package:share_plus/share_plus.dart';

abstract class ShareService {
  Future<void> shareText(String text, {String? subject});
}

class ShareServiceImpl implements ShareService {
  @override
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }
}


