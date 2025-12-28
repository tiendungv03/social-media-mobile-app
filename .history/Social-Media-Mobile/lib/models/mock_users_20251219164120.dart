import '../models/user.dart';

final mockUsers = List<AppUser>.generate(
  12,
  (i) => AppUser(
    id: 'u${i + 1}',
    name: 'Friend ${i + 1}',
    username: 'friend${i + 1}',
    email: 'friend${i + 1}@mail.com',
    avatarUrl: '',
    bio: 'Bio friend ${i + 1}',
  ),
);
