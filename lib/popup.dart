import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ShowLastPopup extends StatelessWidget {
  const ShowLastPopup({Key? key, required this.route }) : super(key:key);

  final String route;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        title: const Text("운동 완료 피드백",
            style: TextStyle(color: Colors.blue, fontSize: 14),
            textAlign: TextAlign.center
        ),
        content: SizedBox(
          height: 100,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: 200,
                    child: const Text("오늘도 수고하셨습니다",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.pushNamed(context, route);
                  },
                  child: Container(
                      width: 210,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple),
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      child: const Text("완료")
                  ),
                ),
              ]
          ),
        )
    );
  }
  }


class ShowFeedBackBody extends StatelessWidget {
  const ShowFeedBackBody({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    List<String> bodyList = ["부위1", "부위2", "부위3", "부위4", "부위5"];
        return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            title: const Text("운동 완료 피드백",
                style: TextStyle(color: Colors.blue, fontSize: 14),
                textAlign: TextAlign.center
            ),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: 200,
                      child: const Text("오늘 운동을 하면서 어느 부위가 가장 편해졌나요?",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    width: 240,
                    height: 270,
                    child: ListView.builder(
                        itemCount: bodyList.length,
                        itemBuilder: (context, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                // api 쏘고, 다음 모달로 넘어가기
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const ShowLastPopup(route: "/");
                                    }
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                    width: 210,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.purple),
                                        borderRadius: BorderRadius.circular(10.0)
                                    ),
                                    child: Text(bodyList[index])),
                              ),
                            )
                            ,
                          ],
                        );
                        }
                    ),
                  )
                ]
            )
        );
      }

}

class ShowFeedBackScore extends StatelessWidget {

  const ShowFeedBackScore({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    final List<int> scoreList = [1,2,3,4,5,6,7,8,9,10];
      return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          title: const Text("운동 완료 피드백",
              style: TextStyle(color: Colors.blue, fontSize: 14),
              textAlign: TextAlign.center
          ),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: 200,
                    child: const Text("오늘 운동에 점수를 준다면 몇점을 주고 싶으세요?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Divider(),
                SizedBox(
                  width: 240,
                  height: 130,
                  child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, //1 개의 행에 보여줄 item 개수
                        mainAxisSpacing: 10, //수평 Padding
                      ),
                      itemCount: scoreList.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: (){
                                // api 쏘고, 다음 모달로 넘어가기
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const ShowFeedBackBody();
                                    }
                                );
                              },
                              child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      shape: BoxShape.circle
                                  ),
                                  child: Text(scoreList[index].toString())),
                            )
                            ,
                          ],
                        );
                      }
                  ),
                )
              ]
          )
      );
    }
}



