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
import 'package:twyshe/classes/upload_file.dart';
import 'package:twyshe/classes/user.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';
import 'package:twyshe/utils/assist.dart';

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
                  child: Text('File or Document'),
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
      if (mounted) {
        showLoaderDialog(context);
      }

      TwysheTaskResult res = await TwysheAPI.uploadFileToCloud(result.files[0]);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (res.succeeded) {
        TwysheUploadFile uploadFile = res.data as TwysheUploadFile;

        //add the message to chat
        _postMessage(null, MessageType.file, uploadFile.uri, uploadFile.size,
            uploadFile.mimeType, uploadFile.name);
      } else {
        if (mounted) {
          Assist.showSnackBar(context, res.message);
        }
      }
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

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      if (mounted) {
        showLoaderDialog(context);
      }

      TwysheTaskResult res = await TwysheAPI.uploadImageFileToCloud(result);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (res.succeeded) {
        TwysheUploadFile uploadFile = res.data as TwysheUploadFile;

        //add the message to chat
        _postMessage(null, MessageType.image, uploadFile.uri, uploadFile.size,
            uploadFile.mimeType, uploadFile.name);
      } else {
        if (mounted) {
          Assist.showSnackBar(context, res.message);
        }
      }
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
      'sender': twysheUser.phone
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

      Assist.updateOwnConversation(
          message: text,
          conversation: widget.conversation,
          twysheUser: twysheUser);

      Assist.updateOtherConversation(
          message: text,
          conversation: widget.conversation,
          twysheUser: twysheUser);
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
                return Assist.getSnapShotMessage(
                    document: document, chat: true, conversation: widget.conversation, twysheUser:  twysheUser);
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
