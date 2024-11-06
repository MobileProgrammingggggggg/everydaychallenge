import 'package:flutter/material.dart';

void main() {
  runApp(CommunityScreen());
}

class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PostListScreen(),
    );
  }
}

class Post {
  String nickname;
  String title;
  String content;
  List<Comment> comments;

  Post({
    required this.nickname,
    required this.title,
    required this.content,
    this.comments = const [],
  });
}

class Comment {
  final String author;
  final String content;

  Comment({required this.author, required this.content});
}

// 게시물 목록 화면
class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Post> posts = [];

  // 게시물 수정 시 호출되는 함수
  void _editPost(Post editedPost) {
    setState(() {
      // 수정된 게시물을 갱신
      posts[posts.indexOf(editedPost)] = editedPost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 목록'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(posts[index].title),
            subtitle: Text('작성자: ${posts[index].nickname}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(
                    post: posts[index],
                    onPostEdited: _editPost,  // 수정된 게시물 처리 함수 전달
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostCreateScreen(onPostCreated: _addPost),
            ),
          );
        },
      ),
    );
  }

  // 게시물 추가 함수
  void _addPost(String nickname, String title, String content) {
    setState(() {
      posts.add(Post(nickname: nickname, title: title, content: content));
    });
  }
}

// 게시물 작성 화면
class PostCreateScreen extends StatefulWidget {
  final Function(String, String, String) onPostCreated;

  PostCreateScreen({required this.onPostCreated});

  @override
  _PostCreateScreenState createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _nicknameController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _validateAndSubmit() {
    if (_nicknameController.text.isEmpty) {
      _showAlert('닉네임을 입력해주세요!');
    } else if (_titleController.text.isEmpty) {
      _showAlert('제목을 입력해주세요!');
    } else if (_contentController.text.isEmpty) {
      _showAlert('내용을 입력해주세요!');
    } else {
      widget.onPostCreated(
        _nicknameController.text,
        _titleController.text,
        _contentController.text,
      );
      Navigator.pop(context);
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('게시물 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(labelText: '닉네임 작성'),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '게시물 제목'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: '게시물 내용'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateAndSubmit,
              child: Text('등록'),
            ),
          ],
        ),
      ),
    );
  }
}

// 게시물 상세 화면
class PostDetailScreen extends StatelessWidget {
  final Post post;
  final Function(Post) onPostEdited;

  PostDetailScreen({required this.post, required this.onPostEdited});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 상세보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('제목: ${post.title}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('작성자: ${post.nickname}', style: TextStyle(color: Colors.grey)),
            Divider(),
            Text(post.content),
            ElevatedButton(
              onPressed: () {
                // 수정 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostEditScreen(
                      post: post,
                      onPostEdited: (editedPost) {
                        onPostEdited(editedPost); // 수정된 게시물 처리
                        Navigator.pop(context); // 수정 후 돌아가기
                      },
                    ),
                  ),
                );
              },
              child: Text('수정하기'),
            ),
            CommentSection(post: post),
          ],
        ),
      ),
    );
  }
}

// 게시물 수정 화면
class PostEditScreen extends StatefulWidget {
  final Post post;
  final Function(Post) onPostEdited;

  PostEditScreen({required this.post, required this.onPostEdited});

  @override
  _PostEditScreenState createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
  }

  void _saveChanges() {
    setState(() {
      widget.post.title = _titleController.text;
      widget.post.content = _contentController.text;
    });

    widget.onPostEdited(widget.post); // 수정된 게시물 반영

    Navigator.pop(context); // 수정 후 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('게시물 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '게시물 제목'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: '게시물 내용'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('저장'),
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}

// 댓글 작성 및 목록 표시
class CommentSection extends StatefulWidget {
  final Post post;

  CommentSection({required this.post});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  final _authorController = TextEditingController();  // 작성자 입력 필드 추가
  List<Comment> comments = [];

  void _addComment() {
    if (_commentController.text.isEmpty || _authorController.text.isEmpty) {
      _showAlert('작성자와 댓글 내용을 모두 입력해주세요!');
    } else {
      setState(() {
        comments.add(Comment(
          author: _authorController.text,  // 작성자 추가
          content: _commentController.text,
        ));
        _commentController.clear(); // 댓글 입력 필드 초기화
        _authorController.clear(); // 작성자 입력 필드 초기화
      });
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _authorController,
          decoration: InputDecoration(labelText: '작성자'),
        ),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(labelText: '댓글 내용'),
        ),
        ElevatedButton(
          onPressed: _addComment,
          child: Text('댓글 추가'),
        ),
        SizedBox(height: 20),
        Text('댓글 목록', style: TextStyle(fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(comments[index].author),
              subtitle: Text(comments[index].content),
            );
          },
        ),
      ],
    );
  }
}