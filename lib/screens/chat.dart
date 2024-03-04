import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:twyshe/classes/converation.dart';
import 'package:twyshe/classes/user.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twyshe/utils/assist.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  ///The reference for this conversation
  final TwysheConversation conversation;
  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Setting reference to 'tasks' collection
  List<types.Message> _messages = [];

  late final TwysheUser twysheUser;
  late final User _user;

  @override
  void initState() {
    super.initState();
    _setUser();
  }

//
  void _setUser() async {
    twysheUser = await Assist.getUserProfile();

    _user = types.User(id: twysheUser.phone, firstName: twysheUser.nickname);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      uploadFileToPebraCloud(result.files[0], MessageType.file);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    _postMessage(message.text, MessageType.text, null, null, null, null);
  }

  ///update the conversation
  void _updateOwnConversation(String? message, int count) async {
    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationsKey)
        .collection(Assist.firestoreConversationsKey)
        .doc(twysheUser.phone)
        .collection(Assist.firestoreConversationsKey)
        .doc(widget.conversation.pnPhone)
        .set(<String, dynamic>{
      'id': widget.conversation.ref,
      'owner': twysheUser.phone,
      'color': twysheUser.color,
      'other_phone': widget.conversation.pnPhone,
      'other_name': widget.conversation.pnName,
      'name': 'You',
      'count': count,
      'message': message,
      'posted': Timestamp.now(),
      'status': 1,
      //'posts': 0,
    }).then((value) {
      Assist.log(
          'The conversation \'$widget.conversation.ref\' has been successfully added!');
    }).onError((error, stackTrace) {
      Assist.log(
          'Unable to update the conversation for user ${twysheUser.phone} and recipient ${widget.conversation.pnPhone}: $error');
    });
  }

  void _updateOtherConversation(String? message, int count) async {
    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationsKey)
        .collection(Assist.firestoreConversationsKey)
        .doc(widget.conversation.pnPhone)
        .collection(Assist.firestoreConversationsKey)
        .doc(twysheUser.phone)
        .set(<String, dynamic>{
      'id': widget.conversation.ref,
      'owner': widget.conversation.pnPhone,
      'color': twysheUser.color,
      'other_phone': twysheUser.phone,
      'other_name': twysheUser.nickname,
      'name': twysheUser.nickname,
      'count': count,
      'message': message,
      'posted': Timestamp.now(),
      'status': 1,
      //'posts': 0,
    }).then((value) {
      Assist.log(
          'The conversation \'$widget.conversation.ref\' has been successfully added!');
    }).onError((error, stackTrace) {
      Assist.log(
          'Unable to update the conversation for user ${widget.conversation.pnPhone} and sender ${twysheUser.phone}: $error');
    });
  }

  Future<void> uploadImageFileToPebraCloud(XFile file, MessageType type) async {
    int sizeInBytes = await file.length();

    final uri = Uri.parse(
        'https://twyshe.app/files/APIClient.php?task=UploadFile&key=zyKROQ8sMMx676HLah3t9zaaPNtfXyrf&id=chat');
    final multiPartFile = await http.MultipartFile.fromPath('file', file.path,
        filename: file.name);
    final uploadRequest = http.MultipartRequest('POST', uri)
      ..files.add(multiPartFile)
      ..fields.addAll(<String, String>{
        'task': 'UploadFile',
        'key': 'zyKROQ8sMMx676HLah3t9zaaPNtfXyrf',
      });

    final responseStream = await uploadRequest.send();
    final response = await http.Response.fromStream(responseStream);

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      if (parsed['Succeeded']) {
        String url = parsed['Data'];
        Assist.log(
            'The upload succeeded and file url is https://twyshe.app/files$url');

        _postMessage(null, type, 'https://twyshe.app/files$url', sizeInBytes,
            lookupMimeType(file.path), file.name);
      } else {
        Assist.log(
            'The upload failed and returned reason is ${parsed['Message']}');
      }
    } else {
      Assist.log(
          'The upload failed and returned status code is ${response.statusCode}');
    }
  }

  Future<void> uploadFileToPebraCloud(
      PlatformFile file, MessageType type) async {
    int sizeInBytes = file.size;

    final uri = Uri.parse(
        'https://twyshe.app/files/APIClient.php?task=UploadFile&key=zyKROQ8sMMx676HLah3t9zaaPNtfXyrf&id=chat');
    final multiPartFile = await http.MultipartFile.fromPath(
        'file', file.path ?? '',
        filename: file.name);
    final uploadRequest = http.MultipartRequest('POST', uri)
      ..files.add(multiPartFile)
      ..fields.addAll(<String, String>{
        'task': 'UploadFile',
        'key': 'zyKROQ8sMMx676HLah3t9zaaPNtfXyrf',
      });

    final responseStream = await uploadRequest.send();
    final response = await http.Response.fromStream(responseStream);

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      if (parsed['Succeeded']) {
        String url = parsed['Data'];
        Assist.log(
            'The upload succeeded and file url is https://twyshe.app/files$url');

        _postMessage(null, type, 'https://twyshe.app/files$url', sizeInBytes,
            lookupMimeType(file.path!), file.name);
      } else {
        Assist.log(
            'The upload failed and returned reason is ${parsed['Message']}');
      }
    } else {
      Assist.log(
          'The upload failed and returned status code is ${response.statusCode}');
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      uploadImageFileToPebraCloud(result, MessageType.image);
    }
  }

  ///Adds the message to the conversation on firestore
  void _postMessage(String? text, MessageType type, String? url, int? size,
      String? mimeType, String? name) async {
    Map<String, dynamic> author = {
      'firstName': twysheUser.nickname,
      'id': twysheUser.phone,
      'lastname': null,
      'color': twysheUser.color,
    };

    Map<String, dynamic> message = {
      'conversation': widget.conversation.ref,
      'author': author,
      'createdAt': Timestamp.now(),
      'id': null,
      'status': Status.sent.name,
      'state': Assist.messageStateActive,
      'type': type.name,
    };

    if (type == MessageType.text) {
      message['text'] = text;
    } else if (type == MessageType.image) {
      message['uri'] = url;
      message['size'] = size;
      message['name'] = name;
    } else {
      message['uri'] = url;
      message['size'] = size;
      message['mimeType'] = mimeType;
      message['name'] = name;
    }

    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationChatsKey)
        .collection(Assist.firestoreConversationChatsKey)
        .doc(widget.conversation.ref)
        .collection(Assist.firestoreConversationChatsKey)
        .add(message)
        .then((resPost) {
      Assist.log(
          'The message \'$text\' has been successfully posted to the conversation \'${widget.conversation.nickname}\'');

      FirebaseFirestore.instance
          .collection(Assist.firestoreAppCode)
          .doc(Assist.firestoreConversationChatsKey)
          .collection(Assist.firestoreConversationChatsKey)
          .doc(widget.conversation.ref)
          .collection(Assist.firestoreConversationChatsKey)
          .where('state', isEqualTo: Assist.messageStateActive)
          .count()
          .get()
          .then((resCount) {
        _updateOwnConversation(text, resCount.count);
        _updateOtherConversation(text, resCount.count);
      }).onError((errorCount, st) {
        Assist.log(
            'Error counting posts for the conversation \'${widget.conversation.ref}\': $errorCount');
      });
    }).onError((resError, stackTrace) {
      Assist.showSnackBar(
          context, 'Unable to post message to conversation. Please try again');
      Assist.log('Unable to post message to the conversation: $resError');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(widget.conversation.pnName,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text('${widget.conversation.pnPhone} - Last seen Today ',
              style: const TextStyle(color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Open shopping cart',
            onPressed: () {
              // handle the press
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Assist.firestoreAppCode)
            .doc(Assist.firestoreConversationChatsKey)
            .collection(Assist.firestoreConversationChatsKey)
            .doc(widget.conversation.ref)
            .collection(Assist.firestoreConversationChatsKey)
            .where('state', isEqualTo: Assist.messageStateActive)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          _messages = snapshot.data!.docs
              .map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                //get ref
                String ref = document.id;

                //set user
                String userId = data['author']['id'];
                String userFirstName = data['author']['firstName'];
                String? userLastName = data['author']['lastName'];

                User messageUser = User(
                    id: userId,
                    firstName: userFirstName,
                    lastName: userLastName);

                //text message
                Timestamp messageCreatedAt = data['createdAt'];

                String messageStatus = data['status'];

                String messageType = data['type'];

                if (messageType == "text") {
                  String messageText = data['text'];

                  var textMessage = types.TextMessage(
                      author: messageUser,
                      createdAt: messageCreatedAt.millisecondsSinceEpoch,
                      id: ref,
                      text: messageText,
                      status:
                          messageStatus == "seen" ? Status.seen : Status.sent,
                      type: MessageType.text);
                  return textMessage;
                } else if (messageType == "image") {
                  String uri = data['uri'];
                  int size = data['size'];
                  String name = data['name'];

                  var textMessage = types.ImageMessage(
                      author: messageUser,
                      createdAt: messageCreatedAt.millisecondsSinceEpoch,
                      id: ref,
                      uri: uri,
                      name: name,
                      size: size,
                      status:
                          messageStatus == "seen" ? Status.seen : Status.sent,
                      type: MessageType.image);
                  return textMessage;
                } else {
                  String uri = data['uri'];
                  int size = data['size'];
                  String name = data['name'];
                  String mimeType = data['mimeType'];

                  var textMessage = types.FileMessage(
                      author: messageUser,
                      createdAt: messageCreatedAt.millisecondsSinceEpoch,
                      id: ref,
                      uri: uri,
                      name: name,
                      mimeType: mimeType,
                      size: size,
                      status:
                          messageStatus == "seen" ? Status.seen : Status.sent,
                      type: MessageType.file);

                  return textMessage;
                }
              })
              .toList()
              .cast();

          return Chat(
            messages: _messages,
            onAttachmentPressed: _handleAttachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            onMessageLongPress: (context, p1) {},
            user: _user,
          );
        },
      ),
    );
  }
}
