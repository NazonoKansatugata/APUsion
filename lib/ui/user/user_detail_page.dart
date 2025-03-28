import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apusion/model/user_model.dart';
import 'package:apusion/ui/auth/view_model/auth_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apusion/ui/user/user_profile_edit_page.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({Key? key}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final UserModel? user = authViewModel.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー詳細(User Details)'),
        // 自動で戻るボタンを表示(Automatically display back button)
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: user != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    // ユーザーのアバター
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            (user.photoURL != null && user.photoURL!.isNotEmpty)
                                ? NetworkImage(user.photoURL!)
                                : null,
                        child: (user.photoURL == null || user.photoURL!.isEmpty)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ユーザー名とキャラ愛Lv.
                    Center(
                      child: Column(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid!)
                                .collection('createdProfiles')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Text('エラーが発生しました(Error occurred)');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('読み込み中...(Loading...)');
                              }
                              final docs = snapshot.data?.docs ?? [];
                              final playerLevel = docs.length;
                              return Text(
                                'ユーザーLv.$playerLevel(User Lv.$playerLevel)',
                                style: const TextStyle(fontSize: 16),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 内側の ListView を shrinkWrap と NeverScrollableScrollPhysics で修正
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ListTile(
                          title: const Text('Email(メールアドレス)'),
                          subtitle: Text(user.email ?? 'No email provided(メールアドレス未提供)'),
                        ),
                        ListTile(
                          title: const Text('UID(ユーザーID)'),
                          subtitle: Text(user.uid ?? 'No uid(ユーザーID未提供)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserProfileEditPage()),
                        );
                      },
                      child: const Text('プロフィール編集(Edit Profile)'),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('ユーザーがログインしていません(User not logged in)'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('ログイン画面へ(To Login Screen)'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
