import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CustomBottomNavigationBar.dart';
import 'package:intl/intl.dart';
import 'Error_screen.dart';
import 'Main_test.dart';
import 'dart:math';
import 'package:get/get.dart';
// import 'Ask_again_screen.dart';
// import 'package:test_flutter/themes/colors.dart';

void main() {
  runApp(CommunityScreen());
} // Provider & 파이어베이스 연계

class PostProvider extends ChangeNotifier {
  // 글 문서 ID 생성 함수
  String generatePostId() {
    final now = DateTime.now();
    final formattedTime =
        DateFormat('yyyyMMddHHmm').format(now); // yyyyMMddHHmm 형식
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomString =
        List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    return 'post$formattedTime$randomString';
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _posts = [];

  Future<void> fetchPosts() async {
    final firestore = FirebaseFirestore.instance;

    try {
      print("try 문 접근");
      final snapshot = await firestore.collection('posts').get();
      // 게시물이 없으면, _posts는 빈 리스트로 설정
      if (snapshot.docs.isEmpty) {
        _posts = [];
        print("게시물이 없습니다.");
      } else {
        print("else 문 접근");
        _posts = snapshot.docs.map((doc) {
          return {
            'title': doc['title'] ?? '',
            'author': doc['author'] ?? '',
            'date': doc['date'] ?? '',
            'views': doc['views'] ?? 0,
            'content': doc['content'] ?? '',
            // comments 필드 안전하게 처리
            'comments': (doc['comments'] as List<dynamic>?)?.map(
                  (e) {
                    if (e is Map) {
                      return Map<String, String>.from(e as Map);
                    } else {
                      // 잘못된 데이터가 있을 경우 기본 값을 반환
                      return {
                        'commentAuthor': 'Unknown',
                        'commentContent': e.toString(),
                      };
                    }
                  },
                ).toList() ??
                <Map<String, String>>[],
          };
        }).toList();
        notifyListeners();
        print("게시물 데이터 불러오기 성공");
      }
    } catch (e) {
      print("게시물 데이터 불러오기 실패: $e");
    }
  }

  // 마지막 게시물 제목 변경하고 알림
  // Future<void> updateLastPostTitle(String title, String content) async {
  //   if (_posts.isNotEmpty) {
  //     _posts[_posts.length - 1]['title'] = title;
  //     _posts[_posts.length - 1]['content'] = content;
  //     notifyListeners();
  //   }
  // }

  int _currentPage = 1;
  final int _postsPerPage = 8;

  List<Map<String, dynamic>> get posts => _posts;

  // 외부에서 게시물에 접근할 수 있도록 posts 접근자 추가
  // 현재 페이지에 해당하는 게시물 목록 가져오기

  // List<Map<String, dynamic>> get currentPosts {
  //   int startIndex = (_currentPage - 1) * _postsPerPage;
  //   int endIndex = startIndex + _postsPerPage;
  //   return _posts.sublist(
  //     startIndex,
  //     endIndex > _posts.length ? _posts.length : endIndex,
  //   );
  // }

  List<Map<String, dynamic>> get currentPosts {
    int startIndex = (_currentPage - 1) * _postsPerPage;
    int endIndex = (_currentPage * _postsPerPage).clamp(0, _posts.length);
    return _posts.sublist(startIndex, endIndex);
  }

  int get totalPages =>
      (_posts.isEmpty) ? 1 : (_posts.length / _postsPerPage).ceil();
  int get currentPage => _currentPage;

  // 페이지 변경
  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  // 게시물 작성 추가
  Future<void> addPost(String title, String author, String date, int views,
      String content) async {
    try {
      // 사용자 정의 방식으로 ID 생성
      String postId = generatePostId();

      // Firestore에 게시물 추가
      await _firestore.collection('posts').doc(postId).set({
        'title': title,
        'author': author,
        'date': date,
        'views': views,
        'content': content,
        'comments': [], // 초기 댓글은 빈 리스트로 설정
      });

      // 로컬 리스트에도 게시물 추가
      _posts.add({
        'id': postId, // Firestore 문서 ID를 로컬에 추가
        'title': title,
        'author': author,
        'date': date,
        'views': views,
        'content': content,
        'comments': [],
      });

      notifyListeners();
    } catch (e) {
      print("Error adding post: $e");
    }
  }

  // 게시물 삭제 메서드 추가
  Future<void> deletePost(int postIndex) async {
    if (postIndex >= 0 && postIndex < _posts.length) {
      String postId = _posts[postIndex]['id']; // Firestore 문서 ID 가져오기
      try {
        // Firestore에서 해당 게시물 삭제
        await _firestore.collection('posts').doc(postId).delete();

        // 로컬 리스트에서도 삭제
        _posts.removeAt(postIndex);

        // 페이지 번호 재조정
        int totalPages = (_posts.length / _postsPerPage).ceil();
        if (_currentPage > totalPages) {
          _currentPage = totalPages;
        }

        notifyListeners();
      } catch (e) {
        print("Error deleting post: $e");
      }
    }
  }

  // 게시물 수정 메서드 추가
  Future<void> updatePost(
      int postIndex, String title, String author, String content) async {
    if (postIndex >= 0 && postIndex < _posts.length) {
      String postId = _posts[postIndex]['id']; // Firestore 문서 ID 가져오기
      try {
        // Firestore에서 해당 게시물 업데이트
        await _firestore.collection('posts').doc(postId).update({
          'title': title,
          'author': author,
          'content': content,
        });

        // 로컬 게시물도 업데이트
        _posts[postIndex]['title'] = title;
        _posts[postIndex]['author'] = author;
        _posts[postIndex]['content'] = content;

        notifyListeners();
      } catch (e) {
        print("Error updating post: $e");
      }
    }
  }

  // 새로운 댓글 추가
  Future<void> addComment(int postIndex, Map<String, String> comment) async {
    String postId = _posts[postIndex]['id']; // Firestore 문서 ID 가져오기
    try {
      // Firestore에 댓글 추가
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment]),
      });

      // 로컬 리스트에도 댓글 추가
      _posts[postIndex]['comments'].add(comment);
      notifyListeners();
    } catch (e) {
      print("댓글 추가 오류: $e");
    }
  }

  // 댓글 삭제 메서드 추가
  Future<void> deleteComment(int postIndex, int commentIndex) async {
    if (postIndex >= 0 && postIndex < _posts.length) {
      String postId = _posts[postIndex]['id']; // Firestore 문서 ID 가져오기
      Map<String, String> commentToDelete =
          _posts[postIndex]['comments'][commentIndex];

      try {
        // Firestore에서 댓글 삭제
        await _firestore.collection('posts').doc(postId).update({
          'comments': FieldValue.arrayRemove([commentToDelete]),
        });

        // 로컬 리스트에서도 댓글 삭제
        _posts[postIndex]['comments'].removeAt(commentIndex);
        notifyListeners();
      } catch (e) {
        print("댓글 삭제 오류: $e");
      }
    }
  }

  // 조회 수 증가
  void incrementViews(int postIndex) {
    if (postIndex >= 0 && postIndex < _posts.length) {
      // 조회수를 String에서 int로 변환 후 증가
      _posts[postIndex]['views'] = (_posts[postIndex]['views'] as int) + 1;
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

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 초기화될 때 게시물 데이터를 가져오기
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.fetchPosts(); // 데이터 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: Text(
          '챌린지 커뮤니티 게시판',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChallengeScreen()),
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WritePostScreen(),
                  ),
                );
              },
              child: Text('글쓰기', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: postProvider.currentPosts.length,
                  itemBuilder: (context, index) {
                    final post = postProvider.currentPosts[index];
                    final commentCount = postProvider.getCommentCount(index);

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0),
                          title: Text(
                            post['title'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '날짜: ${post['date']} | 작성자: ${post['author']} | 조회수 ${post['views']}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ),
                          trailing: Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.comment,
                                    color: Colors.pink[300], size: 18),
                                SizedBox(height: 4),
                                Text(
                                  '$commentCount',
                                  style: TextStyle(
                                    color: Colors.pink[300],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
                            postProvider.incrementViews(index);
                            // Firestore에서 조회수 업데이트
                            final postId = post['id']; // 해당 게시물의 ID
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(postId)
                                .update({
                              'views': FieldValue.increment(1),
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(
                                  post: post,
                                  postIndex: (postProvider.currentPage - 1) * 8 + index,
                                ),
                              ),
                            );
                          },
                        ),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                          height: 2.0,
                        ),
                      ],
                    );
                  },
                ),
              ),
              PaginationControls(),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 4),
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

    if (widget.isEditing && widget.postIndex != null) {
      // 게시물 수정 모드라면 Firestore에서 해당 게시물 데이터 로드
      _loadPostData(widget.postIndex!);
    }
  }

  Future<void> _loadPostData(int postIndex) async {
    try {
      var postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postIndex.toString())
          .get();
      if (postDoc.exists) {
        setState(() {
          titleController.text = postDoc['title'];
          authorController.text = postDoc['author'];
          contentController.text = postDoc['content'];
        });
      }
    } catch (e) {
      print("Error loading post data: $e");
    }
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 제목 입력
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                  labelStyle:
                      TextStyle(color: Colors.pink[300]), // 라벨 색상 핑크로 설정
                  filled: true,
                  fillColor: Colors.pink[50], // 배경 색상 연한 핑크
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
                    borderSide: BorderSide(
                        color: Colors.pink[300]!, width: 2), // 테두리 색상 및 두께
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: Colors.pink[300]!, width: 2), // 포커스 시 테두리 색상
                  ),
                ),
              ),
              SizedBox(height: 16), // 여백 추가

              // 작성자 입력
              TextField(
                controller: authorController,
                decoration: InputDecoration(
                  labelText: '작성자',
                  labelStyle: TextStyle(color: Colors.pink[300]),
                  filled: true,
                  fillColor: Colors.pink[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.pink[300]!, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.pink[300]!, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // 내용 입력
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                  labelStyle: TextStyle(color: Colors.pink[300]),
                  filled: true,
                  fillColor: Colors.pink[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.pink[300]!, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.pink[300]!, width: 2),
                  ),
                ),
                maxLines: 10,
              ),
              SizedBox(height: 20),

              // 게시글 작성 버튼
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

                  final date = DateTime.now().toString().substring(5, 10);
                  final views = 0;

                  if (widget.isEditing && widget.postIndex != null) {
                    // 게시물 수정
                    context
                        .read<PostProvider>()
                        .updatePost(widget.postIndex!, title, author, content);
                  } else {
                    // 새 게시물 작성
                    context
                        .read<PostProvider>()
                        .addPost(title, author, date, views, content);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300], // 버튼 색상을 핑크로 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // 둥근 모서리 설정
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0), // 패딩 추가
                  textStyle: TextStyle(
                    fontSize: 16, // 글자 크기
                    fontWeight: FontWeight.bold, // 글자 두께
                  ),
                  foregroundColor: Colors.white, // 글자 색상을 흰색으로 설정
                ),
                child: Text(widget.isEditing ? '게시글 수정' : '게시글 작성'),
              ),
            ],
          ),
        ));
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
          title: Text(widget.post['title']),
          backgroundColor: Colors.pink[100]!),
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
                  '조회수: ${post['views']}',
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
                  // Firestore에서 가져온 데이터 변환
                  final rawComments =
                      postProvider.posts[widget.postIndex]['comments'] ?? [];

                  // List<Map<String, String>>로 변환
                  final comments = rawComments is List
                      ? rawComments.map((e) {
                          if (e is Map) {
                            // Map 형태로 변환 가능하면 Map<String, String>으로 변환
                            return Map<String, String>.from(e);
                          } else {
                            // 잘못된 데이터 형태인 경우 기본 값으로 처리
                            return {
                              'commentAuthor': 'Unknown',
                              'commentContent': e.toString(),
                            };
                          }
                        }).toList()
                      : <Map<String, String>>[]; // 잘못된 데이터는 빈 리스트로 처리

                  // comments가 비어있는지 확인
                  if (comments.isEmpty) {
                    return Center(child: Text('댓글이 없습니다.'));
                  }

                  return ListView.builder(
                    itemCount: comments.length, // comments의 길이에 맞게 설정
                    itemBuilder: (context, index) {
                      // 댓글 데이터가 null인지 체크하고, 기본값으로 처리
                      final commentAuthor =
                          comments[index]['commentAuthor'] ?? 'Unknown';
                      final commentContent =
                          comments[index]['commentContent'] ?? '내용 없음';

                      return ListTile(
                        title: Text(
                          '작성자: $commentAuthor',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal), // 작게 보이게
                        ),
                        subtitle: Text(
                          commentContent,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal), // 크게 보이게
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            postProvider.deleteComment(widget.postIndex, index);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // 댓글 작성 부분
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentAuthorController,
                    decoration: InputDecoration(
                      labelText: '작성자',
                      labelStyle:
                          TextStyle(color: Colors.pink[300]), // 라벨 색상 핑크
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.pink[300]!), // 포커스 시 하단 선 색상 핑크
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.pink[200]!), // 기본 하단 선 색상 핑크
                      ),
                    ),
                    style: TextStyle(color: Colors.black87), // 텍스트 색상
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
                    decoration: InputDecoration(
                      labelText: '댓글 작성',
                      labelStyle:
                          TextStyle(color: Colors.pink[300]), // 라벨 색상 핑크
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.pink[300]!), // 포커스 시 하단 선 색상 핑크
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.pink[200]!), // 기본 하단 선 색상 핑크
                      ),
                    ),
                    style: TextStyle(color: Colors.black87), // 텍스트 색상
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent, // 버튼 배경색을 핑크로 설정
                    foregroundColor: Colors.white, // 버튼 텍스트 색상 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 버튼의 모서리 둥글게 설정
                    ),
                  ),
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
