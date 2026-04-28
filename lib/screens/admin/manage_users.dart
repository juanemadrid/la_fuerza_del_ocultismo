import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';

class ManageUsers extends StatelessWidget {
  const ManageUsers({super.key});

  static const List<String> _signs = [
    '',
    'Aries',
    'Tauro',
    'Géminis',
    'Cáncer',
    'Leo',
    'Virgo',
    'Libra',
    'Escorpio',
    'Sagitario',
    'Capricornio',
    'Acuario',
    'Piscis',
  ];

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('GESTIONAR CLIENTES')),
      body: StreamBuilder<List<UserModel>>(
        stream: db.streamUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.where((u) => u.role != 'admin').toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    const SizedBox(height: 6),
                    Text(
                      user.zodiacSign.isEmpty
                          ? 'Signo: no configurado'
                          : 'Signo: ${user.zodiacSign}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 170,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: user.isSubscribed,
                        activeThumbColor: const Color(0xFFB71C1C),
                        onChanged: (val) {
                          db.updateUserSubscription(user.uid, val);
                        },
                      ),
                      DropdownButton<String>(
                        value: _signs.contains(user.zodiacSign)
                            ? user.zodiacSign
                            : '',
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: const Color(0xFF1A1A1A),
                        items: _signs
                            .map(
                              (sign) => DropdownMenuItem(
                                value: sign,
                                child: Text(
                                  sign.isEmpty ? 'Sin signo' : sign,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          db.updateUserZodiacSign(user.uid, value);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
