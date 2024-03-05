import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:twyshe/classes/discussion.dart';
import 'package:twyshe/classes/upload_file.dart';
import 'package:twyshe/classes/user.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';
import 'package:twyshe/utils/assist.dart';
import 'package:uuid/uuid.dart';

class DiscussionPage extends StatefulWidget {
  ///The reference for this discussion
  final TwysheDiscussion discussion;
  const DiscussionPage({super.key, required this.discussion});

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  // Setting reference to 'tasks' collection
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
        _postDiscussionMessage(null, MessageType.file, uploadFile.uri,
            uploadFile.size, uploadFile.mimeType, uploadFile.name);
      } else {
        if (mounted) {
          Assist.showSnackBar(context, res.message);
        }
      }
    }
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
        _postDiscussionMessage(null, MessageType.image, uploadFile.uri,
            uploadFile.size, uploadFile.mimeType, uploadFile.name);
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
            Assist.log('The message with id ${message.id} was deleted');
            _removeDiscussionMessage(message.id);
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
              'Sent',
            ),
            subtitle: Text(
              message.createdAt.toString(),
            ),
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
    _postDiscussionMessage(
        message.text, MessageType.text, null, null, null, null);
  }

  ///Adds the message to the discussion on firestore
  void _postDiscussionMessage(String? text, MessageType type, String? url,
      int? size, String? mimeType, String? name) async {
    Map<String, dynamic> author = {
      'firstName': twysheUser.nickname,
      'id': twysheUser.phone,
      'lastname': null,
      'color': twysheUser.color,
    };

    Map<String, dynamic> message = {
      'discussion': widget.discussion.ref,
      'author': author,
      'createdAt': Timestamp.now(),
      'id': null,
      'state': 1,
      'status': Status.sent.name,
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
        .doc(Assist.firestoreDiscussionPostsKey)
        .collection(Assist.firestoreDiscussionPostsKey)
        .doc(widget.discussion.ref)
        .collection(Assist.firestoreDiscussionPostsKey)
        .add(message)
        .then((resPost) {
      Assist.log(
          'The message \'$text\' has been successfully posted to the discussion \'${widget.discussion.nickname}\'');

      ///subscribe to topic if the user isnt the owner
      if (widget.discussion.phone != _user.id) {
        Assist.subscribeTopic(widget.discussion.ref);
      }
      //send  notification
      String notice;

      if (type == MessageType.text) {
        notice = text ?? '(no text)';
      } else if (type == MessageType.image) {
        notice = '(image)';
      } else {
        notice = '(file)';
      }

      TwysheAPI.sendTopicMessage(widget.discussion.ref,
          '${twysheUser.nickname} - ${widget.discussion.title}', notice);

      ///update count
      FirebaseFirestore.instance
          .collection(Assist.firestoreAppCode)
          .doc(Assist.firestoreDiscussionPostsKey)
          .collection(Assist.firestoreDiscussionPostsKey)
          .doc(widget.discussion.ref)
          .collection(Assist.firestoreDiscussionPostsKey)
          .where('state', isEqualTo: Assist.messageStateActive)
          .count()
          .get()
          .then((resCount) {
        Map<String, dynamic> newvalues = {
          'posts': resCount.count,
        };

        FirebaseFirestore.instance
            .collection(Assist.firestoreAppCode)
            .doc(Assist.firestoreDiscussionsKey)
            .collection(Assist.firestoreDiscussionsKey)
            .doc(widget.discussion.ref)
            .update(newvalues)
            .then((updateRes) {
          Assist.log(
              'The count for discussion \'${widget.discussion.ref}\' has been successfully updated to {$resCount.count}');
        }).onError((errorUpdate, stackTrace) {
          Assist.log(
              'Error updating the count for discussion \'${widget.discussion.ref}\': $errorUpdate');
        });
      }).onError((errorCount, st) {
        Assist.log(
            'Error counting posts for the discussion \'${widget.discussion.ref}\': $errorCount');
      });
    }).onError((resError, stackTrace) {
      Assist.showSnackBar(
          context, 'Unable to post message to discussion. Please try again');
      Assist.log('Unable to post message to the discussion: $resError');
    });
  }

  ///Adds the message to the discussion on firestore
  void _removeDiscussionMessage(String id) async {
    FirebaseFirestore.instance
        .collection(Assist.firestoreDiscussionPostsKey)
        .doc(id)
        .update(<String, dynamic>{
      'state': Assist.messageStateDeleted,
    }).then((resPost) {
      Assist.log(
          'The message id \'$id\' has been successfully deleted from the discussion \'${widget.discussion.nickname}\'');

      FirebaseFirestore.instance
          .collection(Assist.firestoreDiscussionPostsKey)
          .where('discussion', isEqualTo: widget.discussion.ref)
          .where('state', isEqualTo: Assist.messageStateActive)
          .count()
          .get()
          .then((resCount) {
        Map<String, dynamic> newvalues = {
          'posts': resCount.count,
        };

        FirebaseFirestore.instance
            .collection(Assist.firestoreDiscussionsKey)
            .doc(widget.discussion.ref)
            .update(newvalues)
            .then((updateRes) {
          Assist.log(
              'The count for discussion \'${widget.discussion.ref}\' has been successfully updated to {$resCount.count}');
        }).onError((errorUpdate, stackTrace) {
          Assist.log(
              'Error updating the count for discussion \'${widget.discussion.ref}\': $errorUpdate');
        });
      }).onError((errorCount, st) {
        Assist.log(
            'Error counting posts for the discussion \'${widget.discussion.ref}\': $errorCount');
      });
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
          title: Text(widget.discussion.title,
              style: const TextStyle(
                color: Colors.white,
              ),
              maxLines: 1),
          subtitle: const Text('Posts are anonymous',
              style: TextStyle(color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_active,
              color: Colors.white,
            ),
            onPressed: () async {
              // do something
              ///subscribe to this discussion
              Assist.subscribeTopic(widget.discussion.ref);
              Assist.showSnackBar(
                  context, 'Subscribed to ${widget.discussion.title}');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_off,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
              ///subscribe to this discussion
              Assist.unsubscribeTopic(widget.discussion.ref);
              Assist.showSnackBar(
                  context, 'Unsubscribed from ${widget.discussion.title}');
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Assist.firestoreAppCode)
            .doc(Assist.firestoreDiscussionPostsKey)
            .collection(Assist.firestoreDiscussionPostsKey)
            .doc(widget.discussion.ref)
            .collection(Assist.firestoreDiscussionPostsKey)
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
                    document: document,
                    chat: false,
                    conversation: null,
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
          );
        },
      ),
    );
  }
}
