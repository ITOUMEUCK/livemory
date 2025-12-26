import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide Group;
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/buttons.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/group.dart' as app_group;

/// Écran pour ajouter des membres à un groupe
class AddMembersScreen extends StatefulWidget {
  final String groupId;

  const AddMembersScreen({super.key, required this.groupId});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _phoneContacts = [];
  List<Map<String, dynamic>> _appUsers = [];
  Set<String> _selectedUserIds = {};

  bool _isLoadingContacts = false;
  bool _isLoadingUsers = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Charger les utilisateurs de l'application
  Future<void> _loadAppUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _errorMessage = null;
    });

    try {
      print('=== Début chargement des utilisateurs ===');
      final firestoreService = FirestoreService();
      final currentUserId = context.read<AuthProvider>().currentUser?.id;
      print('CurrentUserId: $currentUserId');

      // Charger les groupes si nécessaire
      final groupProvider = context.read<GroupProvider>();
      if (groupProvider.groups.isEmpty && currentUserId != null) {
        print('Chargement des groupes...');
        await groupProvider.fetchGroups(currentUserId);
      }

      print('Nombre de groupes: ${groupProvider.groups.length}');
      print(
        'IDs des groupes: ${groupProvider.groups.map((g) => g.id).toList()}',
      );
      print('GroupId recherché: ${widget.groupId}');

      // Trouver le groupe
      app_group.Group? group;
      try {
        group = groupProvider.groups.firstWhere((g) => g.id == widget.groupId);
        print(
          'Groupe trouvé: "${group.name}", membres actuels: ${group.memberIds}',
        );
      } catch (e) {
        print('ERREUR: Groupe ${widget.groupId} non trouvé dans la liste !');
        print(
          'Groupes disponibles: ${groupProvider.groups.map((g) => '${g.id}: ${g.name}').join(', ')}',
        );
        throw Exception('Groupe ${widget.groupId} non trouvé');
      }

      print('Lecture de la collection users...');
      final querySnapshot = await firestoreService.readAll('users');
      print('Nombre total d\'utilisateurs: ${querySnapshot.docs.length}');

      if (group == null) {
        throw Exception('Groupe non défini');
      }

      _appUsers = querySnapshot.docs
          .where(
            (doc) =>
                doc.id != currentUserId && !group!.memberIds.contains(doc.id),
          )
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            final user = {
              'id': doc.id,
              'name': data?['firstName'] ?? data?['name'] ?? 'Utilisateur',
              'email': data?['email'] ?? '',
              'photoUrl': data?['photoUrl'],
            };
            print('User ajouté: ${user['name']} (${user['id']})');
            return user;
          })
          .toList();

      print('Nombre d\'utilisateurs à afficher: ${_appUsers.length}');
      print('=== Fin chargement des utilisateurs ===');
      setState(() => _isLoadingUsers = false);
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
        _errorMessage = 'Erreur lors du chargement: $e';
      });
    }
  }

  /// Charger les contacts du téléphone
  Future<void> _loadPhoneContacts() async {
    if (_phoneContacts.isNotEmpty) return;

    setState(() {
      _isLoadingContacts = true;
      _errorMessage = null;
    });

    try {
      final permissionStatus = await Permission.contacts.request();

      if (permissionStatus.isGranted) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        setState(() {
          _phoneContacts = contacts;
          _isLoadingContacts = false;
        });
      } else {
        setState(() {
          _isLoadingContacts = false;
          _errorMessage = 'Permission refusée pour accéder aux contacts';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingContacts = false;
        _errorMessage = 'Erreur lors du chargement: $e';
      });
    }
  }

  /// Ajouter les membres sélectionnés
  Future<void> _addMembers() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins un membre')),
      );
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final groupProvider = context.read<GroupProvider>();
      final currentUserId = context.read<AuthProvider>().currentUser?.id;

      print(
        'Ajout de ${_selectedUserIds.length} membres au groupe ${widget.groupId}',
      );
      print('IDs des membres: $_selectedUserIds');

      final success = await groupProvider.addMembers(
        widget.groupId,
        _selectedUserIds.toList(),
        invitedBy: currentUserId,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialogue de chargement

        if (success) {
          Navigator.of(context).pop(); // Retour à l'écran précédent
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_selectedUserIds.length} membre(s) ajouté(s) avec succès',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                groupProvider.errorMessage ??
                    'Erreur lors de l\'ajout des membres',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialogue de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      print('Erreur lors de l\'ajout des membres: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter des membres'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 1 && _phoneContacts.isEmpty) {
              _loadPhoneContacts();
            }
          },
          tabs: const [
            Tab(text: 'Utilisateurs Livemory'),
            Tab(text: 'Contacts téléphone'),
          ],
        ),
        actions: [
          if (_selectedUserIds.isNotEmpty)
            TextButton(
              onPressed: _addMembers,
              child: Text(
                'Ajouter (${_selectedUserIds.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Contenu des tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAppUsersTab(), _buildPhoneContactsTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedUserIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addMembers,
              icon: const Icon(Icons.person_add),
              label: Text('Ajouter (${_selectedUserIds.length})'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildAppUsersTab() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            PrimaryButton(text: 'Réessayer', onPressed: _loadAppUsers),
          ],
        ),
      );
    }

    final filteredUsers = _appUsers.where((user) {
      final query = _searchController.text.toLowerCase();
      return user['name'].toLowerCase().contains(query) ||
          user['email'].toLowerCase().contains(query);
    }).toList();

    if (filteredUsers.isEmpty) {
      return const Center(child: Text('Aucun utilisateur trouvé'));
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final isSelected = _selectedUserIds.contains(user['id']);

        return CheckboxListTile(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedUserIds.add(user['id']);
              } else {
                _selectedUserIds.remove(user['id']);
              }
            });
          },
          secondary: CircleAvatar(
            backgroundImage: user['photoUrl'] != null
                ? NetworkImage(user['photoUrl'])
                : null,
            child: user['photoUrl'] == null
                ? Text(user['name'][0].toUpperCase())
                : null,
          ),
          title: Text(user['name']),
          subtitle: Text(user['email']),
        );
      },
    );
  }

  Widget _buildPhoneContactsTab() {
    if (_isLoadingContacts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _tabController.index == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.contacts, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Autoriser l\'accès',
              onPressed: _loadPhoneContacts,
            ),
          ],
        ),
      );
    }

    final filteredContacts = _phoneContacts.where((contact) {
      final query = _searchController.text.toLowerCase();
      return contact.displayName?.toLowerCase().contains(query) ?? false;
    }).toList();

    if (filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Aucun contact trouvé'),
            const SizedBox(height: 8),
            Text(
              'Invitez vos amis à rejoindre Livemory !',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        final email = contact.emails.isNotEmpty
            ? contact.emails.first.address
            : null;

        return ListTile(
          leading: CircleAvatar(
            child: Text(
              (contact.displayName.isNotEmpty ? contact.displayName[0] : '?')
                  .toUpperCase(),
            ),
          ),
          title: Text(contact.displayName),
          subtitle: email != null ? Text(email) : null,
          trailing: OutlinedButton(
            onPressed: () {
              _inviteContact(contact, email);
            },
            child: const Text('Inviter'),
          ),
        );
      },
    );
  }

  /// Inviter un contact par SMS/Email
  void _inviteContact(Contact contact, String? email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inviter un contact'),
        content: Text(
          'Voulez-vous inviter ${contact.displayName} à rejoindre Livemory ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter envoi invitation par SMS/Email
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invitation envoyée !')),
              );
            },
            child: const Text('Inviter'),
          ),
        ],
      ),
    );
  }
}
