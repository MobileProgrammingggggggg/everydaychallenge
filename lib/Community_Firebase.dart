import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';
import 'package:intl/intl.dart';
import 'Error_screen.dart';
import 'Main_test.dart';
import 'dart:math';
import 'Ask_again_screen.dart';

void main() {
  runApp(CommunityScreen());
} // 파이어베이스만 활용

// posts 컬렉션에 글 문서 번호를 생성하는 함수
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

Future<String?> getUserId() async {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) {
    return null; // 로그인하지 않은 경우
  }

  try {
    // Firestore에서 현재 사용자 문서 가져오기
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (userDoc.exists) {
      // 'id' 필드 값 리턴
      return userDoc['id']; // 해당 필드가 없을 경우 null을 리턴
    } else {
      return null; // 문서가 존재하지 않으면 null 리턴
    }
  } catch (e) {
    // 예외 처리
    print("Error fetching user id: $e");
    return null;
  }
}

// post에 문서당 들어가는 항목들
// 댓글은 배열의 형태로 들어감
// 'title': doc['title'] ?? '',
// 'author': doc['author'] ?? '',
// 'date': doc['date'] ?? '',
// 'views': doc['views'] ?? 0,
// 'content': doc['content'] ?? '',
// // comments 필드 안전하게 처리
// 'comments': (doc['comments'] as List<dynamic>?)?.map(

// 커뮤니티 구현에 필요한 함수들
// CommunityScreen
// PaginationControls
// WritePostScreen
// _WritePostScreenState
// PostDetailScreen
// _PostDetailScreenState

class CommunityScreen extends StatelessWidget {
  // Firestore에서 조회수를 1씩 증가시키는 함수
  Future<void> _incrementViews(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final postSnapshot = await postRef.get();

    if (postSnapshot.exists) {
      int currentViews = postSnapshot['views'] ?? 0;
      await postRef.update({'views': currentViews + 1});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('챌린지 커뮤니티 게시판'),
        centerTitle: true,
        backgroundColor: Colors.pink[100]!, // AppBar 색상 설정
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('date', descending: true) // 날짜 기준 내림차순 정렬
            .limit(10) // 한 페이지에 표시할 게시물 수
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!.docs;
          int totalPages = (snapshot.data!.size / 10).ceil(); // 전체 페이지 수 계산

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(4), // ListView 여백 설정
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    // 글 목록 리스트 보여주기
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 2), // 카드 사이 여백
                      padding: EdgeInsets.all(2), // 안쪽 여백
                      decoration: BoxDecoration(
                        color: Colors.white, // 배경색 설정
                        borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                        border: Border.all(
                          color: Colors.grey[300]!, // 경계선 색상
                          width: 1, // 경계선 두께
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // 그림자 색상
                            spreadRadius: 1, // 그림자 퍼짐 범위
                            blurRadius: 4, // 그림자 흐림 정도
                            offset: Offset(0, 2), // 그림자 위치
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8), // ListTile 내 여백
                        title: Text(
                          post['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '작성자 ${post['id']} | ${DateFormat('HH:mm').format(post['date'].toDate())} | 조회수 ${post['views']} | 댓글수 ${post['comments']?.length ?? 0}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(postId: post.id),
                            ),
                          );
                          // 조회수 증가
                          await _incrementViews(post.id);
                        },
                      ),
                    );
                  },
                ),
              ),
              PaginationControls(
                currentPage: currentPage,
                totalPages: totalPages,
                onNextPage: _goToNextPage,
                onPreviousPage: _goToPreviousPage,
                onPageSelected: _selectPage,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WritePostScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink[100], // 버튼 색상
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 4),
    );
  }

// 페이지네이션 관련 함수들
  int currentPage = 1;

  void _goToNextPage() {
  }

  void _goToPreviousPage() {
  }

  void _selectPage(int page) {
  }
}

class WritePostScreen extends StatefulWidget {
  @override
  _WritePostScreenState createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _createPost() async {
    final postId = generatePostId();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // 유저가 로그인되지 않은 경우
      print('User is not logged in');
      return;
    }

    try {
      // 사용자의 문서에서 id 필드 값을 가져옵니다
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userIdField = userDoc['id']; // 'id' 필드를 가져옵니다

      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'title': _titleController.text,
        'author': userId, // 실제 사용자의 'id' 필드 값 넣기
        'id': userIdField,
        'date': DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          DateTime.now().hour,
          DateTime.now().minute,
        ),
        // 초와 밀리초 제거
        'views': 0,
        'content': _contentController.text,
        'comments': [],
      });

      Navigator.pop(context); // 게시물 작성 후 이전 화면으로 돌아가기
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 작성'),
        backgroundColor: Colors.pink[100], // AppBar 색상 변경
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 제목 텍스트 필드
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(color: Colors.pink[300]), // 레이블 색상
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink[300]!, width: 2),
                ),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.pink[800]), // 입력 텍스트 색상
            ),
            SizedBox(height: 16), // 제목과 본문 사이 간격

            // 본문 텍스트 필드
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                labelStyle: TextStyle(color: Colors.pink[300]),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink[300]!, width: 2),
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              style: TextStyle(color: Colors.pink[800]),
            ),
            SizedBox(height: 20),

            // Post 버튼
            ElevatedButton(
              onPressed: _createPost,
              child: Text('작성하기'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.pink[400], // 버튼 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final String postId;

  PostDetailScreen({required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  // 댓글을 Firestore에 추가하는 함수
  Future<void> _addComment(String content) async {
    final userId = FirebaseAuth.instance.currentUser?.uid; // 현재 유저의 ID를 가져옵니다.

    if (userId == null) {
      // 만약 유저가 로그인되지 않은 경우
      print('User is not logged in');
      return;
    }

    try {
      // 해당 사용자의 문서에서 id 필드를 가져옵니다.
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userIdField = userDoc['id']; // 'id' 필드를 가져옵니다.

      final comment = {
        'id': FirebaseFirestore.instance.collection('posts').doc().id,
        // 고유 댓글 id값
        'userid': userIdField,
        // 유저 id 필드값
        'author': userId,
        // 유저 UID 문서값
        'content': content,
        'date': Timestamp.now(), // 댓글 작성 시간
      };

      // 'comments' 배열에 새로운 댓글을 추가
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'comments': FieldValue.arrayUnion([comment]), // 댓글 추가
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

// 글 삭제 함수
  Future<void> _deletePost(String postId) async {
    // 다이얼로그를 띄워서 확인
    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Ask_again(message: '정말로 이 글을 삭제하시겠습니까?'); // 삭제 확인 메시지
      },
    );

    // 사용자가 확인 버튼을 클릭했을 경우에만 삭제 진행
    if (result == 1) {
      try {
        await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
        Navigator.pop(context); // 글 삭제 후 이전 화면으로 돌아가기
      } catch (e) {
        print('Error deleting post: $e');
      }
    }
  }


  // 글 수정 함수
  Future<void> _editPost(String postId, String newContent) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'content': newContent, // Firestore에서 content를 업데이트
      });
      setState(() {
        // 필요한 경우 상태 업데이트 (예: 위젯을 새로 고침)
      });
    } catch (e) {
      print('Error editing post: $e');
    }
  }

  // 댓글 삭제 함수
  Future<void> _deleteComment(String postId, String commentId) async {
    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        List<dynamic> comments = postSnapshot['comments'] ?? [];

        // 댓글 배열에서 특정 id를 가진 댓글 삭제
        comments.removeWhere((comment) => comment['id'] == commentId);

        await postRef.update({
          'comments': comments,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('댓글을 삭제했습니다'),
          backgroundColor: Colors.pink[100],
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('댓글 삭제에 실패했습니다'),
        backgroundColor: Colors.pink[100],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 정보'),
        backgroundColor: Colors.pink[100], // 원하는 색상으로 설정 (예: 파란색)
      ),
      body: Container(
        color: Colors.white, // 배경색을 흰색으로 설정
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.postId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('게시물을 찾을 수 없습니다'));
            }

            final post = snapshot.data!;
            final String postAuthor = post['author'];
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;

            // Timestamp -> DateTime 변환 안전 처리
            DateTime postDate;
            try {
              postDate =
                  post['date'] != null ? post['date'].toDate() : DateTime.now();
            } catch (e) {
              postDate = DateTime.now();
            }

            // 글 작성자가 현재 로그인한 유저인지 확인
            final isAuthor = postAuthor == currentUserId;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 스타일링
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Text(
                      post['title'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  // 작성자와 작성일
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Align(
                      alignment: Alignment.centerRight, // 텍스트를 우측 정렬
                      child: Text(
                        '작성자 : ${post['id']} 작성일 : ${DateFormat('yyyy-MM-dd HH:mm').format(postDate)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  // 내용 부분
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        width: MediaQuery.of(context).size.width *
                            0.92, // 가로 크기를 화면의 88%로 설정
                        height: 200, // 세로 크기 설정
                        decoration: BoxDecoration(
                          color: Colors.white, // 배경색을 흰색으로 설정
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            post['content'],
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5, // 줄 간격 설정
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 구분선 추가
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  SizedBox(height: 8),
                  // 댓글 제목
                  Text(
                    '댓글 : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  // 댓글 목록 StreamBuilder로 실시간 처리
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .snapshots(),
                    builder: (context, commentSnapshot) {
                      if (commentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!commentSnapshot.hasData ||
                          !commentSnapshot.data!.exists) {
                        return Center(child: Text('아직 댓글이 없어요'));
                      }

                      final updatedPost = commentSnapshot.data!;
                      List<Map<String, dynamic>> comments = [];
                      if (updatedPost['comments'] != null) {
                        comments = List<Map<String, dynamic>>.from(
                            updatedPost['comments']);
                      }

                      // 댓글 목록 표시
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (comments.isNotEmpty)
                            ...comments.map((comment) {
                              bool isCommentAuthor = comment['author'] ==
                                  currentUserId; // 현재 로그인한 사용자 확인

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${comment['userid']} 님의 댓글 : ${comment['content']}'),
                                    if (isCommentAuthor)
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.pinkAccent,
                                        ),
                                        iconSize: 20, // 아이콘 크기 설정
                                        onPressed: () {
                                          _deleteComment(widget.postId,
                                              comment['id']); // 댓글 삭제
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }).toList()
                          else
                            Text('아직 댓글이 없습니다'),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  // 댓글 작성 입력창
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: '댓글',
                      labelStyle: TextStyle(color: Colors.pink),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink[100]!),
                      ),
                    ),
                    maxLines: 2,
                    onSubmitted: (content) {
                      final trimmedContent = content.trim();
                      if (trimmedContent.isNotEmpty) {
                        _addComment(trimmedContent); // 댓글 추가
                        _commentController.clear(); // 입력창 비우기
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('댓글 내용을 작성해주세요'),
                          backgroundColor: Colors.pink[100],
                        ));
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight, // 댓글 버튼을 우측 정렬
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[100], // 버튼 배경색
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // 동그란 버튼
                          )),
                      onPressed: () {
                        final content = _commentController.text.trim();
                        if (content.isNotEmpty) {
                          _addComment(content); // 댓글 추가
                          _commentController.clear(); // 입력창 비우기
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('댓글 내용을 작성해주세요'),
                            backgroundColor: Colors.pink[100],
                          ));
                        }
                      },
                      child: Text(
                        '댓글 작성',
                        style: TextStyle(
                          color: Colors.white, // 글자 색상 흰색
                          fontSize: 16, // 글자 크기 (단위는 dp)
                          // fontWeight: FontWeight.bold, // (선택) 글자 굵기
                        ),
                      ),
                    ),
                  ),

                  // 수정 및 삭제 버튼 (작성자만 가능)
                  if (isAuthor) ...[
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                      children: [
                        // 게시물 수정
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[100], // 버튼 배경색
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30), // 동그란 버튼
                              )),
                          onPressed: () {
                            // 다이얼로그가 열리기 전에 TextEditingController 초기화
                            TextEditingController _editController =
                                TextEditingController();
                            _editController.text =
                                post['content'] ?? ''; // 기존 글 내용을 설정

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('게시물 수정하기'),
                                  backgroundColor:
                                      Colors.white, // 다이얼로그 배경색을 흰색으로 설정
                                  content: TextField(
                                    controller: _editController,
                                    decoration: InputDecoration(
                                      hintText: '새로운 내용을 입력하세요',
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.pink), // 기본 상태에서 밑줄을 핑크로 설정
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.pink), // 포커스 상태에서 밑줄을 핑크로 설정
                                      ),
                                    ),
                                    maxLines: 5,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context), // 다이얼로그 닫기
                                      child: Text('취소'),
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            Colors.pink[100], // 버튼 배경색을 핑크로 설정
                                        foregroundColor:
                                            Colors.white, // 글자 색상을 흰색으로 설정
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final newContent =
                                            _editController.text.trim();
                                        if (newContent.isNotEmpty) {
                                          // Firestore에서 content를 업데이트
                                          await _editPost(
                                              widget.postId, newContent);
                                          Navigator.pop(context); // 다이얼로그 닫기
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('내용은 비울 수 없습니다'),
                                              backgroundColor: Colors.pink[
                                                  100], // 배경색을 pink[100]으로 설정
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('저장하기'),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.pink[100],
                                        foregroundColor: Colors
                                            .white, // 글자 색상을 흰색으로 설정// 저장하기 버튼 텍스트 색상 핑크로 설정
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            '게시물 수정',
                            style: TextStyle(
                              color: Colors.white, // 글자 색상 흰색
                              fontSize: 16, // 글자 크기 (단위는 dp)
                              // fontWeight: FontWeight.bold, // (선택) 글자 굵기
                            ),
                          ),
                        ),
                        SizedBox(width: 10),

                        // 게시물 삭제
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[100], // 버튼 배경색
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30), // 동그란 버튼
                              )),
                          onPressed: () {
                            // 글 삭제하기
                            _deletePost(widget.postId);
                          },
                          child: Text(
                            '게시물 삭제',
                            style: TextStyle(
                              color: Colors.white, // 글자 색상 흰색
                              fontSize: 16, // 글자 크기 (단위는 dp)
                              // fontWeight: FontWeight.bold, // (선택) 글자 굵기
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function onNextPage;
  final Function onPreviousPage;
  final Function(int) onPageSelected; // 페이지 번호 선택 함수

  PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> pageButtons = [];

    // 이전 버튼
    pageButtons.add(
      TextButton(
        onPressed: currentPage > 1 ? () => onPreviousPage() : null,
        style: TextButton.styleFrom(
          foregroundColor: Colors.pink[100], // 텍스트 색상 설정
        ),
        child: Text('이전'),
      ),
    );

    // 페이지 번호 버튼
    for (int i = 1; i <= totalPages; i++) {
      pageButtons.add(
        ElevatedButton(
          onPressed: () => onPageSelected(i), // 해당 페이지로 이동
          style: ElevatedButton.styleFrom(
            foregroundColor: i == currentPage ? Colors.pink : null, // 현재 페이지는 핑크색으로 강조
          ),
          child: Text('$i'),
        ),
      );
    }

    // 다음 버튼
    pageButtons.add(
      TextButton(
        onPressed: currentPage < totalPages ? () => onNextPage() : null,
        style: TextButton.styleFrom(
          foregroundColor: Colors.pink[100], // 텍스트 색상 설정
        ),
        child: Text('다음'),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pageButtons,
    );
  }
}
