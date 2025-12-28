// // lib/widgets/friends_tab.dart


// import '../models/user.dart';


// import 'package:flutter/material.dart';

// class FriendsTab extends StatelessWidget {
//   const FriendsTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final items = List.generate(10, (i) => 'Friend ${i + 1}');

//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: items.length,
//       separatorBuilder: (_, __) => const Divider(height: 1),
//       itemBuilder: (context, index) {
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundColor: Colors.blue.shade100,
//             child: Text(
//               items[index][0],
//               style: const TextStyle(color: Colors.black),
//             ),
//           ),
//           title: Text(items[index]),
//           subtitle: const Text('Tap to view profile'),
//           trailing: OutlinedButton(
//             onPressed: () {},
//             style: OutlinedButton.styleFrom(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//               side: BorderSide(color: Colors.blue.shade300),
//             ),
//             child: const Text(
//               'Follow',
//               style: TextStyle(fontSize: 12),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
