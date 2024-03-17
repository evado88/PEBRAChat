import 'dart:async' show Future, StreamSubscription;
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
import 'package:twyshe/classes/user_presence.dart';
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
  late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      subscription;

  bool _startedTyping = false;

  TwysheUserPresence _presence = TwysheUserPresence(
      name: '', timestamp: null, isTyping: false, never: false);

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _setUser();
  }

//
  void _setUser() async {
    twysheUser = await Assist.getUserProfile();

    Assist.updateUserStatus(twysheUser: twysheUser, typing: false);

    _user = types.User(id: twysheUser.phone, firstName: twysheUser.nickname);

    subscription = FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreUsersKey)
        .collection(Assist.firestoreUsersKey)
        .doc(widget.conversation.otherPhone)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data()! as Map<String, dynamic>;

        String name = data['name'];
        Timestamp time = data['timestamp'];
        bool typing = data['typing'];

        if (mounted) {
          setState(() {
            _presence = TwysheUserPresence(
                name: name, timestamp: time, isTyping: typing, never: false);
          });

          Assist.log(
              'The  state if the recipient user ${widget.conversation.otherPhone} has changed: $data');
        } else {
          Assist.log(
              'The  state if the recipient user ${widget.conversation.otherPhone} will be ignored since no ui is available');
        }
      } else {
        setState(() {
          _presence = TwysheUserPresence(
              name: '', timestamp: null, isTyping: false, never: true);
        });
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();

    Assist.log(
        'The subscription to the recipient user ${widget.conversation.otherPhone} has been cancelled');
    super.dispose();
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

  void _handleMessageLongPress(BuildContext _, types.Message message) async {
    List<Widget> buttons = [];

    if (message.author.id == _user.id) {
      buttons.add(
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            _removeChatMessage(message.id);

            Assist.log('The message with id ${message.id} was deleted');

            Navigator.pop(context);
          },
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message'),
          content: ListTile(
            title: const Text(
              'User',
            ),
            subtitle: Text(message.author.firstName ?? '(no name)'),
          ),
          actions: buttons,
        );
      },
    );
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

      //send  notification
      String notice;

      if (type == MessageType.text) {
        notice = text ?? '(no text)';
      } else if (type == MessageType.image) {
        notice = '(image)';
      } else {
        notice = '(file)';
      }

      TwysheAPI.sendDeviceMessage(
          widget.conversation.otherPhone, twysheUser.nickname, notice);
    }).onError((resError, stackTrace) {
      Assist.showSnackBar(
          context, 'Unable to post message to conversation. Please try again');
      Assist.log('Unable to post message to the conversation: $resError');
    });
  }

  void _startTyping() {
    if (_startedTyping) {
      Assist.log('The user is already typing  and request will be ignored');
    } else {
      _startedTyping = true;

      Assist.log('The started typing');

      Assist.updateUserStatus(twysheUser: twysheUser, typing: true);

      Assist.updateOtherConversationStatus(
          typing: twysheUser.nickname,
          conversation: widget.conversation,
          twysheUser: twysheUser);

      Future.delayed(const Duration(seconds: 8), () {
        _startedTyping = false;

        Assist.log('The user now finished typing');

        Assist.updateUserStatus(twysheUser: twysheUser, typing: false);

        Assist.updateOtherConversationStatus(
            typing: '',
            conversation: widget.conversation,
            twysheUser: twysheUser);
      });
    }
  }

  ///Adds the message to the discussion on firestore
  void _removeChatMessage(String id) async {
    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationChatsKey)
        .collection(Assist.firestoreConversationChatsKey)
        .doc(widget.conversation.ref)
        .collection(Assist.firestoreConversationChatsKey)
        .doc(id)
        .update(<String, dynamic>{
      'state': Assist.messageStateDeleted,
    }).then((resPost) {
      Assist.log(
          'The message id \'$id\' has been successfully deleted from the chat \'${widget.conversation.ref}\'');

/*
      Assist.updateOwnConversation(
          message: '(Deleted)',
          conversation: widget.conversation,
          twysheUser: twysheUser);

      Assist.updateOtherConversation(
          message: '(Deleted)',
          conversation: widget.conversation,
          twysheUser: twysheUser);*/
    }).onError((resError, stackTrace) {
      Assist.showSnackBar(
          context, 'Unable to post message to discussion. Please try again');
      Assist.log('Unable to post message to the discussion: $resError');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(
              _presence.name.isEmpty
                  ? widget.conversation.otherName
                  : _presence.name,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(
              _presence.isTyping
                  ? 'Typing...'
                  : Assist.getLastSeen(_presence.timestamp, _presence.never),
              style: const TextStyle(color: Colors.white)),
        ),
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

          if (snapshot.connectionState == ConnectionState.waiting &&
              !_initialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          _initialized = true;

          _messages = snapshot.data!.docs
              .map((DocumentSnapshot document) {
                return Assist.getSnapShotMessage(
                    document: document,
                    chat: true,
                    conversation: widget.conversation,
                    twysheUser: twysheUser);
              })
              .toList()
              .cast();

          return Chat(
            messages: _messages,
            onAttachmentPressed: _handleAttachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed: _handleSendPressed,
            onMessageLongPress: _handleMessageLongPress,
            showUserAvatars: true,
            showUserNames: true,
            user: _user,
            inputOptions: InputOptions(
              onTextChanged: (text) => _startTyping(),
            ),
          );
        },
      ),
    );
  }
}
