import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music_api/utilities/info.dart';

import '../utilities/color_scheme.dart';
import '../utilities/text_theme.dart';

class HomeBottomsheet extends StatefulWidget {
  final String markerId;
  const HomeBottomsheet({super.key, required this.markerId});

  @override
  State<HomeBottomsheet> createState() => _HomeBottomsheetState();
}

class _HomeBottomsheetState extends State<HomeBottomsheet> {
  String loggedInUid = FirebaseAuth.instance.currentUser!.uid;
  late String nickName;

  Future<String> fetchNickname(String userId) async {
    final user = await FirebaseFirestore.instance
        .collection('user')
        .doc(loggedInUid)
        .get();

    return user['nickName'];
  }

  Future<void> setNickname() async {
    nickName = await fetchNickname(loggedInUid);
  }

  Future<StarInfo> fetchStarInfo(String markerId) async {
    final doc =
        await FirebaseFirestore.instance.collection('Star').doc(markerId).get();

    // 가져온 문서를 StarInfo 객체로 변환하여 반환함
    return StarInfo.fromMap(doc.data()!);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setNickname();
    return ClipRRect(
      child: Container(
        height: 289,
        margin: const EdgeInsets.only(left: 25, right: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          color: const Color.fromRGBO(45, 45, 45, 0),
        ),
        child: FutureBuilder(
          future: fetchStarInfo(widget.markerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(); // 로딩 중일 때 표시할 위젯
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // 에러 발생 시 표시할 위젯
            } else {
              StarInfo starInfo = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      width: 124,
                      height: 6,
                      decoration: BoxDecoration(
                          color: AppColor.text,
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                        text: '$nickName님', style: semibold17),
                                    const TextSpan(
                                        text: '이 추천하는', style: regular16),
                                  ],
                                ),
                              ),
                              const Text(
                                '이곳에 어울리는 음악',
                                style: semibold17,
                              )
                            ],
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              const Icon(Icons.favorite, color: AppColor.error),
                              Text('${starInfo.like?.length}',
                                  textAlign: TextAlign.left,
                                  style:
                                      regular13.copyWith(color: AppColor.sub1)),
                            ],
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                      const SizedBox(height: 19),
                      Row(
                        children: <Widget>[
                          Stack(
                            children: [
                              SizedBox(
                                height: 70,
                                width: 70,
                                child: Image.network(
                                  'https://i1.ytimg.com/vi/${starInfo.videoId}/maxresdefault.jpg',
                                  fit: BoxFit.fitHeight,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return Image.network(
                                      'https://i1.ytimg.com/vi/${starInfo.videoId}/sddefault.jpg',
                                      fit: BoxFit.fitHeight,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Container(
                                          color: Colors.yellow,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 20, left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${starInfo.title}',
                                    textAlign: TextAlign.left,
                                    style: bold17,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text('${starInfo.singer}',
                                      textAlign: TextAlign.left,
                                      style: regular13.copyWith(
                                          color: AppColor.sub1)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => VideoSearchPage(
                      //               video: '_fd_hwSm9zI',
                      //             )));
                    },
                    child: Container(
                      width: 340,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12), // 테두리 반경 값을 12로 설정
                        border:
                            Border.all(color: Colors.white), // 테두리 색상을 흰색으로 설정
                        color: Colors.transparent, // 배경색을 투명하게 설정
                      ),
                      child: Center(
                        child: Text(
                          '${starInfo.comment}',
                          style: semibold12.copyWith(color: AppColor.sub1),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 15),
            width: 124,
            height: 6,
            decoration: BoxDecoration(
                color: AppColor.text, borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ],
    );
  }
}
