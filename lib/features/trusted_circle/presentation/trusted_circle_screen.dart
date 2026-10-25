import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';
import 'package:kavach/features/trusted_circle/application/trusted_contact_providers.dart';
import 'package:kavach/features/trusted_circle/domain/trusted_contact.dart';

class TrustedCircleScreen extends ConsumerWidget {
  const TrustedCircleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(trustedContactsProvider);
    final contactCount = contacts.asData?.value.length;
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 52),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => context.go('/home'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(44, 44),
                              foregroundColor: AppColors.brandCrimson,
                            ),
                            child: const Icon(Icons.chevron_left, size: 24),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.go('/welcome'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(44, 44),
                              foregroundColor: AppColors.brandCrimson,
                            ),
                            child: const Text(
                              'Account',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.brandCrimson,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Text(
                        'Trusted Circle',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        'Up to 5 people. Changes are saved to your account.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: contacts.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stackTrace) => const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Sign in and connect to Firebase to load your contacts. '
                            'No contact was changed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.charcoal),
                          ),
                        ),
                        data: (items) => _contactContent(context, ref, items),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: contactCount == null || contactCount >= 5
                              ? null
                              : () => _editContact(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Add contact'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandCrimson,
                            foregroundColor: AppColors.surfaceWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Text(
                        'Adding someone here saves their details. It does not send '
                        'them an alert or share your location.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.phaseSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const KavachBottomNavigation(selected: 'Home'),
          ],
        ),
      ),
    );
  }

  Widget _contactContent(
    BuildContext context,
    WidgetRef ref,
    List<TrustedContact> contacts,
  ) {
    if (contacts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Your circle is empty. Add someone you trust.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.charcoal),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var index = 0; index < contacts.length; index++) ...[
            ListTile(
              onTap: () => _editContact(context, ref, contacts[index]),
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.coolGray,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const KavachReferenceIcon(
                  icon: KavachIcon.person,
                  size: 22,
                  strokeWidth: 1.6,
                ),
              ),
              title: Text(
                contacts[index].name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              subtitle: Text(contacts[index].phoneNumber),
              trailing: IconButton(
                tooltip: 'Remove ${contacts[index].name}',
                onPressed: () => _removeContact(context, ref, contacts[index]),
                icon: const Icon(Icons.delete_outline),
                color: AppColors.brandCrimson,
              ),
            ),
            if (index != contacts.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 68),
                child: Divider(height: 1, color: AppColors.coolGray),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _editContact(
    BuildContext context,
    WidgetRef ref, [
    TrustedContact? contact,
  ]) async {
    final name = TextEditingController(text: contact?.name ?? '');
    final phone = TextEditingController(text: contact?.phoneNumber ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(contact == null ? 'Add contact' : 'Edit contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Indian mobile number',
                hintText: '+91 98765 43210',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true && context.mounted) {
      try {
        final actions = ref.read(trustedContactActionsProvider);
        if (contact == null) {
          await actions.add(name: name.text, phoneNumber: phone.text);
        } else {
          await actions.update(
            contactId: contact.id,
            name: name.text,
            phoneNumber: phone.text,
          );
        }
        if (!context.mounted) return;
      } on TrustedContactException catch (error) {
        if (!context.mounted) return;
        _showError(context, trustedContactFailureMessage(error.reason));
      } on Object {
        if (!context.mounted) return;
        _showError(
          context,
          'Could not save the contact. Sign in and check your connection.',
        );
      }
    }
    name.dispose();
    phone.dispose();
  }

  Future<void> _removeContact(
    BuildContext context,
    WidgetRef ref,
    TrustedContact contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove trusted contact?'),
        content: Text('${contact.name} will be removed from your circle.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(trustedContactActionsProvider).remove(contact.id);
      if (!context.mounted) return;
    } on Object {
      if (!context.mounted) return;
      _showError(
        context,
        'Could not remove this contact. Check your connection.',
      );
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
