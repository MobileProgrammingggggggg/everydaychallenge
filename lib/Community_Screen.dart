import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CustomBottomNavigationBar.dart';
import 'Error_screen.dart';
import 'Main_test.dart';
// import 'Ask_again_screen.dart';
// import 'package:test_flutter/themes/colors.dart';

void main() {
  runApp(CommunityScreen());
}

// Provider 패키지로 메모리에 내용 저장
// 추후 파이어베이스 연동으로 교체
class PostProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [
    for (int i = 1; i <= 50; i++)
      {
        'title': '$i번 게시물',
        'author': '익명$i',
        'date': '11-01',
        'view': 0,
        'content': '게시글 $i 내용',
        'comments': <Map<String, String>>[]
      }
  ];

  // 마지막 게시물 제목 변경하고 알림
  PostProvider() {
    _posts[_posts.length - 1]['title'] = '뭘봐';
    _posts[_posts.length - 1]['content'] = '메롱 어쩔티비 ㅋ';
    notifyListeners();
  }

  int _currentPage = 1;
  final int _postsPerPage = 8;

  List<Map<String, dynamic>> get posts => _posts;

  // 외부에서 게시물에 접근할 수 있도록 posts 접근자 추가
  // 현재 페이지에 해당하는 게시물 목록 가져오기
  List<Map<String, dynamic>> get currentPosts {
    int startIndex = (_currentPage - 1) * _postsPerPage;
    int endIndex = startIndex + _postsPerPage;
    return _posts.sublist(
      startIndex,
      endIndex > _posts.length ? _posts.length : endIndex,
    );
  }

  int get totalPages => (_posts.length / _postsPerPage).ceil();
  int get currentPage => _currentPage;

  // 페이지 변경
  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  // 게시물 작성 추가
  void addPost(
      String title, String author, String date, int view, String content) {
    _posts.insert(0, {
      'title': title,
      'author': author,
      'date': date,
      'view': view,
      'content': content,
      'comments': <Map<String, String>>[]
    });

    // 페이지를 1번으로 이동
    _currentPage = 1;
    notifyListeners();
  }

  // 게시물 삭제 메서드 추가
  void deletePost(int postIndex) {
    if (postIndex >= 0 && postIndex < _posts.length) {
      _posts.removeAt(postIndex);

      // 삭제 후 페이지 번호가 올바른지 확인
      // 삭제로 인해 현재 페이지가 변경될 수 있으므로 currentPage를 다시 조정
      int totalPages = (_posts.length / _postsPerPage).ceil();
      if (_currentPage > totalPages) {
        _currentPage = totalPages; // 페이지가 범위를 벗어나지 않게 설정
      }

      notifyListeners();
      // 화면 갱신을 한 텀 늦추어 실행
      // Future.delayed(Duration(milliseconds: 100), () {
      //   notifyListeners();
      // });
    }
  }

  // 게시물 수정 메서드 추가
  void updatePost(int postIndex, String title, String author, String content) {
    if (postIndex >= 0 && postIndex < _posts.length) {
      _posts[postIndex]['title'] = title;
      _posts[postIndex]['author'] = author; // 작성자 업데이트 추가
      _posts[postIndex]['content'] = content;
      notifyListeners();
    }
  }

  // 새로운 댓글 추가
  void addComment(int postIndex, Map<String, String> comment) {
    _posts[postIndex]['comments'].add(comment);
    notifyListeners();
  }

  // 댓글 삭제 메서드 추가
  void deleteComment(int postIndex, int commentIndex) {
    _posts[postIndex]['comments'].removeAt(commentIndex);
    notifyListeners();
  }

  // 조회 수 증가
  void incrementViews(int postIndex) {
    if (postIndex >= 0 && postIndex < _posts.length) {
      // 조회수를 String에서 int로 변환 후 증가
      _posts[postIndex]['view'] = (_posts[postIndex]['view'] as int) + 1;
      notifyListeners();
    }
  }

  // 댓글 수 반환 메서드 추가
  int getCommentCount(int postIndex) {
    if (postIndex >= 0 && postIndex < _posts.length) {
      return _posts[postIndex]['comments'].length;
    }
    return 0;
  }

  // 수제 에러 메시지
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message); // ErrorDialog 호출
      },
    );
  }
}

class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/CommunityScreen': (context) => CommunityScreen(),
          '/WritePostScreen': (context) => WritePostScreen(),
        },
        title: '매일매일 챌린지',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
            appBar: AppBar(
              title: Text('커뮤니티 게시판'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back), // 뒤로가기 직접 추가
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
              ),
              actions: [
                Builder(
                  builder: (context) => TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WritePostScreen()),
                      );
                    },
                    child: Text('글쓰기', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
            body: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                //final posts = postProvider.currentPosts; // posts를 실제로 사용
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            postProvider.currentPosts.length, // 삭제 후 정확한 길이로 변경
                        itemBuilder: (context, index) {
                          if (index >= postProvider.currentPosts.length) {
                            return SizedBox.shrink(); // 인덱스가 범위를 벗어난 경우 빈 위젯 반환
                          }
                          final post = postProvider.currentPosts[index];
                          final commentCount =
                              postProvider.getCommentCount(index); // 댓글 수
                          return Card(
                            margin: EdgeInsets.all(2.0),
                            child: ListTile(
                              title: Text(
                                post['title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '날짜: ${post['date']} | 작성자: ${post['author']} | 조회수: ${post['view']} | 댓글 수: $commentCount',
                              ),
                              onTap: () {
                                // 조회수 증가
                                postProvider.incrementViews(index);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailScreen(
                                      post: post,
                                      postIndex:
                                          (postProvider.currentPage - 1) * 8 +
                                              index,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // 페이지 네이션 컨트롤 추가
                    PaginationControls(),
                  ],
                );
              },
            ),
            bottomNavigationBar: CustomBottomNavigationBar()),
      ),
    );
  }
}

class PaginationControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final currentPage = postProvider.currentPage;
    final totalPages = postProvider.totalPages;

    // 5개씩 그룹으로 나누기 위한 계산
    int currentGroup = ((currentPage - 1) / 5).floor(); // 현재 그룹 계산 (0부터 시작)
    int startPage = currentGroup * 5 + 1;
    int endPage = (startPage + 4) < totalPages ? (startPage + 4) : totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 이전 그룹으로 이동
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: currentGroup > 0
              ? () => postProvider.setPage(startPage - 5)
              : null,
        ),

        // 현재 그룹의 페이지 번호 표시
        for (int i = startPage; i <= endPage; i++)
          TextButton(
            onPressed: () => postProvider.setPage(i),
            child: Text(
              '$i',
              style: TextStyle(
                fontWeight:
                    currentPage == i ? FontWeight.bold : FontWeight.normal,
                color: currentPage == i ? Colors.blue : Colors.black,
              ),
            ),
          ),
        // 다음 그룹으로 이동
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: endPage < totalPages
              ? () => postProvider.setPage(startPage + 5)
              : null,
        ),
      ],
    );
  }
}

class WritePostScreen extends StatefulWidget {
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
  _WritePostScreenState createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    authorController = TextEditingController(text: widget.initialAuthor);
    contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '게시글 수정' : '게시글 작성'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 포커스 해제인데 오류나서 미룬이
            // FocusScope.of(context).unfocus();
            // 뒤로 가기
            Navigator.pop(context);
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
                  PostProvider.showErrorDialog(context, '제목을 입력해주세요.');
                  return;
                }
                if (author.isEmpty) {
                  PostProvider.showErrorDialog(context, '작성자를 입력해주세요.');
                  return;
                }
                if (content.isEmpty) {
                  PostProvider.showErrorDialog(context, '내용을 입력해주세요.');
                  return;
                }
                {
                  final date = DateTime.now().toString().substring(5, 10);
                  final view = 100;

                  if (widget.isEditing && widget.postIndex != null) {
                    // 게시물 수정
                    context
                        .read<PostProvider>()
                        .updatePost(widget.postIndex!, title, author, content);
                  } else {
                    // 새 게시물 작성
                    context
                        .read<PostProvider>()
                        .addPost(title, author, date, view, content);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(widget.isEditing ? '게시글 수정' : '게시글 작성'),
            ),
          ],
        ),
      ),
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final int postIndex;

  PostDetailScreen({required this.post, required this.postIndex});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController commentAuthorController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  // 수정할 제목과 내용 작성자용 컨트롤러
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController authorController;

  bool isEditing = false; // 수정 모드 상태를 저장하는 변수

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post['title']);
    contentController = TextEditingController(text: widget.post['content']);
    authorController = TextEditingController(text: widget.post['author']);
    commentAuthorController.text = "익명";
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.read<PostProvider>();
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.post['title']), backgroundColor: Colors.lightBlue),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 위에 날짜, 조회수, 댓글 수 추가
            Row(
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
            ),
            SizedBox(height: 16),
            // 제목 필드 (수정 가능)
            TextField(
              controller: titleController,
              readOnly: !isEditing,
              decoration: InputDecoration(
                labelText: '제목',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey, width: 1.0), // 포커스 시에도 빨간 테두리 유지
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isEditing ? Colors.red : Colors.grey,
                      width: 2.0), // 수정 가능 시 빨간 테두리
                ),
              ),
            ),
            SizedBox(height: 16), // 제목과 내용 사이 간격 추가
            // 내용 필드 (수정 가능)
            TextField(
              controller: contentController,
              readOnly: !isEditing,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: '내용',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey, width: 1.0), // 포커스 시에도 빨간 테두리 유지
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isEditing ? Colors.red : Colors.grey,
                      width: 2.0), // 수정 가능 시 빨간 테두리
                ),
              ),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (isEditing) {
                      // 수정 모드에서 저장 시, 업데이트
                      postProvider.updatePost(
                        widget.postIndex,
                        titleController.text,
                        authorController.text,
                        contentController.text,
                      );
                    }
                    // 수정 모드 토글
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      isEditing
                          ? Colors.red
                          : Colors.blue, // 수정 중일 때 빨간색, 저장 상태일 때 파란색
                    ),
                  ),
                  child: Text(isEditing ? '저장' : '수정',
                      style: TextStyle(color: Colors.white)),
                ),
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
                                // 삭제 처리 후
                                postProvider.deletePost(widget.postIndex);

                                // 다이얼로그 닫기
                                Navigator.pop(context); // 다이얼로그 닫기

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CommunityScreen()),
                                );
                              },
                              child: Text('삭제'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
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
                      backgroundColor: Colors.pinkAccent),
                  child: Text('삭제'),
                ),
              ],
            ),
            Divider(height: 40),

            // 댓글 목록 표시
            Expanded(
              child: Consumer<PostProvider>(
                builder: (context, postProvider, child) {
                  final comments = postProvider.posts[widget.postIndex]
                      ['comments'] as List<Map<String, String>>;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      // 범위를 벗어난 index는 처리하지 않음
                      if (index < postProvider.posts.length) {
                        return ListTile(
                          title: Text(
                            '작성자: ${comments[index]['author']}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal), // 작게 보이게
                          ),
                          subtitle: Text(
                            comments[index]['content']!,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal), // 크게 보이게
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              postProvider.deleteComment(
                                  widget.postIndex, index);
                            },
                          ),
                        );
                      } else {
                        return Container(); // 인덱스가 잘못된 경우 빈 공간 반환
                      }
                    },
                  );
                },
              ),
            ),
            // 댓글 작성
            // 댓글 작성 부분
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentAuthorController,
                    decoration: InputDecoration(labelText: '작성자'),
                    onTap: () {
                      if (commentAuthorController.text == "익명") {
                        setState(() {
                          commentAuthorController.clear(); // 기본값 제거
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 10), // 텍스트 필드와 버튼 사이 간격
                Expanded(
                  flex: 4, // 댓글 작성 버튼에 더 많은 공간을 할당
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(labelText: '댓글 작성'),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<PostProvider>().addComment(
                          widget.postIndex,
                          {'author': '익명', 'content': value},
                        );
                        commentController.clear();
                        setState(() {});
                      }
                    },
                  ),
                ),
                SizedBox(width: 10), // 텍스트 필드와 버튼 사이 간격
                ElevatedButton(
                  onPressed: () {
                    final author = commentAuthorController.text;
                    final content = commentController.text;
                    // author와 content 빈칸 검사
                    if (author.isEmpty) {
                      PostProvider.showErrorDialog(context, '작성자를 입력해 주세요.');
                    } else if (content.isEmpty) {
                      PostProvider.showErrorDialog(context, '댓글 내용을 입력해 주세요.');
                    } else {
                      context.read<PostProvider>().addComment(
                        widget.postIndex,
                        {'author': author, 'content': content},
                      );
                      commentAuthorController.clear();
                      commentController.clear();
                      commentAuthorController.text = "익명";
                      setState(() {});
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
