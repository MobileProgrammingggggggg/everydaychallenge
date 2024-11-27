import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CustomBottomNavigationBar.dart';
import 'Error_screen.dart';
import 'Main_test.dart';
import 'package:get/get.dart';
// import 'Ask_again_screen.dart';
// import 'package:test_flutter/themes/colors.dart';

void main() {
  runApp(CommunityScreen());
}

class PostController extends GetxController {
  // 게시물 목록을 Observable로 선언
  RxList<Map<String, dynamic>> posts = List.generate(
    50,
    (i) => {
      'title': '${i + 1}번 게시물',
      'author': '익명${i + 1}',
      'date': '11-01',
      'view': 0,
      'content': '게시글 ${i + 1} 내용',
      'comments': <Map<String, String>>[].obs,
    },
  ).obs;

  // 생성자에서 마지막 게시물 제목 변경
  PostController() {
    posts.last['title'] = '뭘봐';
    posts.last['content'] = '메롱 어쩔티비 ㅋ';
  }

  // 현재 페이지, 페이지당 게시물 수, 전체 페이지 수 반환를 상태 변수로 관리
  RxInt currentPage = 1.obs;
  RxInt postsPerPage = 8.obs;
  RxInt totalPages = 1.obs;

  // 현재 페이지의 게시물 목록 가져오기
  List<Map<String, dynamic>> get currentPosts {
    if (posts.isEmpty) {
      return []; // 게시물이 없을 경우 빈 리스트 반환
    }

    int startIndex =
        (currentPage.value - 1) * postsPerPage.value; // 수정: currentPage 계산 방식
    int endIndex = startIndex + postsPerPage.value;

    // 인덱스 범위가 posts의 범위를 벗어나지 않도록 처리
    if (startIndex < 0) {
      startIndex = 0; // 0 미만으로는 가지 않도록 처리
    }

    if (endIndex > posts.length) {
      endIndex = posts.length; // posts 길이를 넘지 않도록 처리
    }

    return posts.sublist(startIndex, endIndex);
  }

  // 게시물 수에 따라 totalPages를 갱신하는 메소드
  void updateTotalPages() {
    if (posts.isEmpty) {
      currentPage.value = 1; // 게시물이 없으면 첫 페이지로 강제 설정
      totalPages.value = 0; // 게시물이 없으면 페이지 수는 0
    } else {
      totalPages.value = (posts.length / postsPerPage.value).ceil(); // 페이지 수 계산
    }
  }

  // 페이지 변경 메서드
  void setPage(int page) {
    // 페이지가 1보다 작거나 totalPages보다 크면 첫 페이지로 설정
    if (page < 1) {
      currentPage.value = 1;
    } else if (page > totalPages.value) {
      currentPage.value = totalPages.value;
    } else {
      currentPage.value = page;
    }
  }

  //RxString current1PostTitle = ''.obs; // 제목을 관리할 Rx 변수

  // 게시물 추가 메서드
  void addPost(
      String title, String author, String date, int view, String content) {
    posts.insert(0, {
      'title': title,
      'author': author,
      'date': date,
      'view': view,
      'content': content,
      'comments': <Map<String, dynamic>>[],
    });
    currentPage.value = 1; // 새 게시물이 추가되면 첫 페이지로 이동
  }

  // 게시물 삭제 메서드
  void deletePost(int postIndex) {
    if (postIndex >= 0 && postIndex < posts.length) {
      posts.removeAt(postIndex);
      updateTotalPages();
      if (currentPage.value > totalPages.value) {
        currentPage.value = totalPages.value; // 범위 밖의 값일 경우 마지막 페이지로 설정
      }
    }
  }

  // 게시물 수정 메서드
  void updatePost(int postIndex, String title, String author, String content) {
    if (postIndex >= 0 && postIndex < posts.length) {
      posts[postIndex]['title'] = title;
      posts[postIndex]['author'] = author;
      posts[postIndex]['content'] = content;
      posts.refresh(); // 상태 갱신
    }
  }

  // 댓글 추가 메서드
  void addComment(int postIndex, Map<String, String> comment) {
    posts[postIndex]['comments'].add(comment);
    posts[postIndex]['comments'].refresh(); // 댓글 리스트 갱신
    posts.refresh(); // RxList 상태 변경 후 refresh 호출
  }

  // 댓글 삭제 메서드
  void deleteComment(int postIndex, int commentIndex) {
    posts[postIndex]['comments'].removeAt(commentIndex);
    posts[postIndex]['comments'].refresh(); // 댓글 리스트 갱신
    posts.refresh(); // RxList 상태 변경 후 refresh 호출
  }

  // 조회수 증가 메서드
  void incrementViews(int postIndex) {
    if (postIndex >= 0 && postIndex < posts.length) {
      posts[postIndex]['view'] = (posts[postIndex]['view'] as int) + 1;
      posts.refresh(); // RxList 상태 변경 후 refresh 호출
    }
  }

  // 댓글 수 반환 메서드
  int getCommentCount(int postIndex) {
    return posts[postIndex]['comments'].length;
  }

  // 수제 에러 메시지
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message); // ErrorDialog 호출
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    updateTotalPages(); // 앱 시작 시 페이지 수 초기화
  }
}

class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(
      init: PostController(),
      builder: (controller) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          routes: {
            '/CommunityScreen': (context) => CommunityScreen(),
            '/WritePostScreen': (context) => WritePostScreen(),
          },
          title: '매일매일 챌린지',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.pink[100],
              title: Text(
                '커뮤니티 게시판',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Get.back(); // 뒤로가기
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.to(WritePostScreen()); // 글쓰기 화면으로 이동
                  },
                  child: Text('글쓰기', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    // currentPosts가 변경될 때마다 UI가 자동으로 갱신됩니다.
                    return ListView.builder(
                      itemCount: controller.currentPosts.length,
                      itemBuilder: (context, index) {
                        final post = controller.currentPosts[index];
                        final commentCount = controller.getCommentCount(index);
                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1), // 경계선 추가
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: Offset(0, 2), // 그림자 위치
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            title: Text(
                              post['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                '날짜: ${post['date']}   작성자: ${post['author']}   조회수: ${post['view']}   댓글 수: $commentCount',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 18, color: Colors.grey),
                            onTap: () {
                              controller.incrementViews(index); // 조회수 증가
                              int globalIndex =
                                  (controller.currentPage.value - 1) *
                                          controller.postsPerPage.value +
                                      index;
                              Get.to(() => PostDetailScreen(
                                  post: post, postIndex: globalIndex));
                            },
                          ),
                        );
                      },
                    );
                  }),
                ),
                PaginationControls(),
              ],
            ),
            bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 4),
          ),
        );
      },
    );
  }
}

class PaginationControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>(); // GetX로 controller 접근
    final currentPage = controller.currentPage; // currentPage는 RxInt 타입임
    final totalPages = controller.totalPages;

    return Obx(() {
      // 현재 페이지가 포함된 그룹의 첫 페이지와 끝 페이지를 자동으로 계산
      int currentGroup = (currentPage.value - 1) ~/ 5; // 현재 그룹 계산 (0부터 시작)
      int startPage = currentGroup * 5 + 1;
      int endPage = (startPage + 4) < totalPages.value ? (startPage + 4) : totalPages.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이전 그룹으로 이동
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: startPage > 1
                ? () => controller.setPage(startPage - 5) // 이전 그룹으로 이동
                : null,
          ),

          // 현재 그룹의 페이지 번호 표시
          ...List.generate(endPage - startPage + 1, (index) {
            int pageNumber = startPage + index;
            return TextButton(
              onPressed: () => controller.setPage(pageNumber),
              child: Text(
                '$pageNumber',
                style: TextStyle(
                  fontWeight: currentPage.value == pageNumber
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: currentPage.value == pageNumber ? Colors.blue : Colors.black,
                ),
              ),
            );
          }),

          // 다음 그룹으로 이동
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: endPage < totalPages.value
                ? () => controller.setPage(endPage + 1) // 다음 그룹으로 이동
                : null,
          ),
        ],
      );
    });
  }
}

class WritePostScreen extends StatelessWidget {
  final bool isEditing;
  final int? postIndex;
  final String? initialTitle;
  final String? initialAuthor;
  final String? initialContent;

  WritePostScreen({
    Key? key,
    this.isEditing = false,
    this.postIndex,
    this.initialTitle,
    this.initialAuthor,
    this.initialContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>(); // GetX Controller를 사용

    // TextEditingController 사용
    TextEditingController titleController =
        TextEditingController(text: initialTitle);
    TextEditingController authorController =
        TextEditingController(text: initialAuthor);
    TextEditingController contentController =
        TextEditingController(text: initialContent);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(isEditing ? '게시글 수정' : '게시글 작성');
        }),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 상태 변경 후 네비게이션 처리
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context);
            });
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            TextField(
              controller: authorController,
              decoration: InputDecoration(labelText: '작성자'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: '내용'),
              maxLines: 10,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final author = authorController.text;
                final content = contentController.text;

                if (title.isEmpty) {
                  controller.showErrorDialog(context, '제목을 입력해주세요.');
                  return;
                }
                if (author.isEmpty) {
                  controller.showErrorDialog(context, '작성자를 입력해주세요.');
                  return;
                }
                if (content.isEmpty) {
                  controller.showErrorDialog(context, '내용을 입력해주세요.');
                  return;
                }

                final date = DateTime.now().toString().substring(5, 10);
                final view = 100;

                if (isEditing && postIndex != null) {
                  // 게시물 수정
                  controller.updatePost(postIndex!, title, author, content);
                } else {
                  // 새 게시물 작성
                  controller.addPost(title, author, date, view, content);
                }
                // 상태 변경 후 네비게이션 처리
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context);
                });
              },
              child: Text(isEditing ? '게시글 수정' : '게시글 작성'),
            ),
          ],
        ),
      ),
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  final int postIndex;

  PostDetailScreen({required this.post, required this.postIndex});

  @override
  Widget build(BuildContext context) {
    final postController = Get.find<PostController>();

    // 기존 내용에서 사용했던 TextEditingController는 GetX 상태로 관리
    final titleController = TextEditingController(text: post['title']);
    final contentController = TextEditingController(text: post['content']);
    final authorController = TextEditingController(text: post['author']);
    final commentAuthorController = TextEditingController(text: "익명");
    final commentController = TextEditingController();

    // Rx 값으로 제목, 내용, 작성자 상태 관리
    // RxString currentPostTitle = post['title'].obs;
    // RxString currentPostContent = post['content'].obs;
    // RxString currentPostAuthor = post['author'].obs;

    RxBool isEditing = false.obs; // 수정 모드 상태를 RxBool로 관리

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "제목 에러 뭐임", // currentPostTitle.value, // 상태값을 직접 사용
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.pink[50],
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              // 제목 위에 날짜, 조회수, 댓글 수 추가
              return Row(
                mainAxisAlignment: MainAxisAlignment.end, // 우측 정렬
                children: [
                  Text(
                    '작성일: ${post['date']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '조회수: ${post['view']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '댓글: ${post['comments'].length}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              );
            }),
            SizedBox(height: 16),
            // 제목 필드 (수정 가능)
            Obx(() => TextField(
                  controller: titleController,
                  readOnly: !isEditing.value,
                  decoration: InputDecoration(
                    labelText: '제목',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(
                    //     color: isEditing.value ? Colors.red : Colors.grey,
                    //     width: 2.0,
                    //   ),
                    // ),
                  ),
                )),
            SizedBox(height: 16),
            // 내용 필드 (수정 가능)
            Obx(() => TextField(
                  controller: contentController,
                  readOnly: !isEditing.value,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: '내용',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(
                    //     color: isEditing.value ? Colors.red : Colors.grey,
                    //     width: 2.0,
                    //   ),
                    // ),
                  ),
                )),
            SizedBox(height: 20),
            //수정 저장 기능
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() {
                  return ElevatedButton(
                    onPressed: () {
                      if (isEditing.value) {
                        // 수정 모드에서 저장 시, 업데이트
                        postController.updatePost(
                          postIndex,
                          titleController.text,
                          authorController.text,
                          contentController.text,
                        );
                      }
                      // 수정 모드 토글
                      isEditing.value = !isEditing.value;
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        isEditing.value ? Colors.red : Colors.blue,
                      ),
                    ),
                    child: Text(isEditing.value ? '저장' : '수정',
                        style: TextStyle(color: Colors.white)),
                  );
                }),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('삭제 확인'),
                          content: Text('정말로 이 게시물을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                postController.deletePost(postIndex);
                                // 상태 변경 후 이전 화면으로 돌아가기
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Get.back(); // GetX에서 이전 화면으로 돌아가기
                                  Get.back();
                                });
                              },
                              child: Text('삭제'),
                            ),
                            TextButton(
                              onPressed: () {
                                // 상태 변경 후 네비게이션 처리
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Get.back(); // GetX에서 이전 화면으로 돌아가기
                                });
                              },
                              child: Text('취소'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.pinkAccent,
                  ),
                  child: Text('삭제'),
                ),
              ],
            ),
            Divider(height: 40),
            // 댓글 목록 표시
            Expanded(
              child: Obx(() {
                final comments = postController.posts[postIndex]['comments']
                    as List<Map<String, String>>;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    if (index < postController.posts.length) {
                      return ListTile(
                        title: Text('작성자: ${comments[index]['author']}',
                            style: TextStyle(fontSize: 12)),
                        subtitle: Text(comments[index]['content']!,
                            style: TextStyle(fontSize: 16)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            postController.deleteComment(postIndex, index);
                          },
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }),
            ),
            // 댓글 작성
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentAuthorController,
                    decoration: InputDecoration(labelText: '작성자'),
                    onTap: () {
                      if (commentAuthorController.text == "익명") {
                        commentAuthorController.clear(); // 기본값 제거
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(labelText: '댓글 작성'),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        postController.addComment(
                          postIndex,
                          {'author': '익명', 'content': value},
                        );
                        commentController.clear();
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final author = commentAuthorController.text;
                    final content = commentController.text;
                    if (author.isEmpty) {
                      postController.showErrorDialog(context, '작성자를 입력해 주세요.');
                    } else if (content.isEmpty) {
                      postController.showErrorDialog(
                          context, '댓글 내용을 입력해 주세요.');
                    } else {
                      postController.addComment(
                        postIndex,
                        {'author': author, 'content': content},
                      );
                      commentAuthorController.clear();
                      commentController.clear();
                      commentAuthorController.text = "익명";
                    }
                  },
                  child: Text('댓글 작성'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
