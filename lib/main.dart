import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var results = "results...";
  late OpenAI openAI;
  TextEditingController textEditingController = TextEditingController();

  List<ChatMessage> messages = [];
  ChatUser user = ChatUser(id: "1", firstName: "Geremias", lastName: "Pettywisker");
  ChatUser openGPT = ChatUser(id: "2", firstName: "OpenIA", lastName: "chatGPT");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    const token = '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';
    openAI = OpenAI.instance.build(token: token,baseOption: HttpSetup(receiveTimeout: 16000),isLogger: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child:DashChat(
                currentUser: user,
                onSend: (ChatMessage m) {
                  setState(() {
                    messages.insert(0, m);
                  });
                },
                messages: messages, readOnly: true,
              )),
            // SingleChildScrollView(child: Text(results)),
            Row(children: [
              Expanded(
                child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type anything here ..."),
                  ),
                ),
              )),
              ElevatedButton(onPressed: () {

                ChatMessage msg = ChatMessage(user: user, createdAt: DateTime.now(), text: textEditingController.text);
                setState(() {
                  messages.insert(0,msg);
                });

                final request = CompleteText(prompt: textEditingController.text,
                model: kTranslateModelV3, maxTokens: 200);

                openAI.onCompleteStream(request:request).first.then((response) {

                  ChatMessage msg = ChatMessage(user: openGPT, createdAt: DateTime.now(),
                   text: response!.choices.first.text.trim());
                  setState(() {
                    messages.insert(0,msg);
                  });

                  // results = response!.choices.first.text;
                  // setState(() {
                  //   results;
                  // });
                });
                textEditingController.clear();
              }, child:Icon(Icons.send),style: ElevatedButton.styleFrom(
                 shape: CircleBorder(), padding: EdgeInsets.all(12), backgroundColor: Colors.green,
              ),)
            ],)
          ],
        ),
      ),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
