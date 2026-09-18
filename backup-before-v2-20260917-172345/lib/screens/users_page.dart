import 'package:flutter/material.dart';
import '../models/models.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Team users',
          subtitle: 'Create staff accounts for the same agency database',
          action: FilledButton.icon(
            onPressed: () => _add(context),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add user'),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ListView.separated(
              itemCount: store.users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final u = store.users[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(u.name.isEmpty ? '?' : u.name[0].toUpperCase()),
                  ),
                  title: Text(
                    u.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${u.email} • ${u.role}'),
                  trailing: u.id == store.currentUserId
                      ? const Chip(label: Text('You'))
                      : IconButton(
                          onPressed: () => _delete(context, u),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, UserAccount user) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete user?'),
            content: Text('Remove ${user.name} from this agency?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await store.deleteUser(user.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _add(BuildContext context) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    String role = 'staff';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Add team user'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Temporary password'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const ['staff', 'admin']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setLocal(() => role = v ?? 'staff'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    email.text.trim().isEmpty ||
                    password.text.length < 6) {
                  return;
                }
                Navigator.pop(context, {
                  'name': name.text.trim(),
                  'email': email.text.trim(),
                  'password': password.text,
                  'role': role,
                });
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;
    try {
      await store.addUser(
        name: result['name']!,
        email: result['email']!,
        password: result['password']!,
        role: result['role']!,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
