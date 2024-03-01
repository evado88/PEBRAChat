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
  late final List<types.Message> _messages = [];

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

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
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
    _postMessage(message.text);
  }

  ///update the conversation
  void _updateConversations(bool current, String message, int count) async {
    String user = current ? twysheUser.phone : widget.conversation.pn;
    String recipient = current ? widget.conversation.pn : twysheUser.phone;
    String name = current ? twysheUser.nickname : 'Peer Navigator';

    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationsKey)
        .collection(Assist.firestoreConversationsKey)
        .doc(user)
        .collection(Assist.firestoreConversationsKey)
        .doc(recipient)
        .set(<String, dynamic>{
      'id': widget.conversation.ref,
      'owner': user,
      'recipient': recipient,
      'name': name,
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
          'Unable to update the conversation for user $user and recipient $recipient: $error');
    });
  }

  ///Adds the message to the conversation on firestore
  void _postMessage(String text) async {
    Map<String, dynamic> author = {
      'firstName': twysheUser.nickname,
      'id': twysheUser.phone,
      'lastname': null,
      'color': twysheUser.color,
    };

    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationChatsKey)
        .collection(Assist.firestoreConversationChatsKey)
        .doc(widget.conversation.ref)
        .collection(Assist.firestoreConversationChatsKey)
        .add(<String, dynamic>{
      'conversation': widget.conversation.ref,
      'author': author,
      'createdAt': Timestamp.now(),
      'id': null,
      'status': Status.sent.name,
      'text': text,
      'type': MessageType.text.name,
    }).then((resPost) {
      Assist.log(
          'The message \'$text\' has been successfully posted to the conversation \'${widget.conversation.nickname}\'');

      FirebaseFirestore.instance
          .collection(Assist.firestoreConversationChatsKey)
          .where('conversation', isEqualTo: widget.conversation.ref)
          .count()
          .get()
          .then((resCount) {
        _updateConversations(true, text, resCount.count);
        _updateConversations(false, text, resCount.count);
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
          title: Text(widget.conversation.nickname,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text('${widget.conversation.pn} - Last seen Today ',
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
          return Chat(
            messages: snapshot.data!.docs
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
                  String messageText = data['text'];
                  String messageType = data['type'];

                  var textMessage = types.TextMessage(
                      author: messageUser,
                      createdAt: messageCreatedAt.millisecondsSinceEpoch,
                      id: ref,
                      text: messageText,
                      status: Status.seen,
                      type: MessageType.text);
                  return textMessage;
                })
                .toList()
                .cast(),
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
