import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/animations.dart';
import '../../data/models/event_detail_model.dart';

class HostProfilePreview extends StatelessWidget {
  final HouseDetail houseDetail;
  final AdminSummary? adminSummary;

  const HostProfilePreview({
    super.key,
    required this.houseDetail,
    this.adminSummary,
  });

  static void show(BuildContext context, HouseDetail houseDetail, AdminSummary? adminSummary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HostProfilePreview(
        houseDetail: houseDetail,
        adminSummary: adminSummary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: Spacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(Responsive.getScreenPadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Spacing.md),
                      
                      // Profile Header
                      Row(
                        children: [
                          // Profile Image
                          Hero(
                            tag: 'host_profile_${houseDetail.houseId}',
                            child: CircleAvatar(
                              radius: Responsive.isTablet(context) ? 50 : 40,
                              backgroundImage: houseDetail.profilePhoto != null
                                  ? CachedNetworkImageProvider(houseDetail.profilePhoto!) as ImageProvider
                                  : null,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: houseDetail.profilePhoto == null
                                  ? Icon(
                                      Icons.home,
                                      size: Responsive.isTablet(context) ? 40 : 32,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          
                          // Name and Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  houseDetail.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (adminSummary != null) ...[
                                  const SizedBox(height: Spacing.xs),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: Spacing.xs),
                                      Text(
                                        adminSummary!.name ?? adminSummary!.userName ?? 'Admin',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: Spacing.lg),
                      
                      // Description Section
                      if (houseDetail.description != null && houseDetail.description!.isNotEmpty) ...[
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          QuillDeltaParser.parseDeltaToPlainText(houseDetail.description),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: Spacing.lg),
                      ],
                      
                      // Admin Details
                      if (adminSummary != null) ...[
                        Container(
                          padding: const EdgeInsets.all(Spacing.md),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(Spacing.md - Spacing.xs),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: adminSummary!.profilePictureUrl != null
                                    ? CachedNetworkImageProvider(adminSummary!.profilePictureUrl!) as ImageProvider
                                    : null,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: adminSummary!.profilePictureUrl == null
                                    ? Icon(
                                        Icons.person,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: Spacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      adminSummary!.name ?? adminSummary!.userName ?? 'Admin',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (adminSummary!.email != null) ...[
                                      const SizedBox(height: Spacing.xs),
                                      Text(
                                        adminSummary!.email!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                      ],
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ScaleOnTap(
                              onTap: () {
                                MicroInteractions.buttonPress(context);
                                Navigator.pop(context);
                                // Navigate to host profile page
                              },
                              child: OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.person_outline),
                                label: const Text('View Profile'),
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: ScaleOnTap(
                              onTap: () {
                                MicroInteractions.buttonPress(context);
                                Navigator.pop(context);
                                // Navigate to more events
                              },
                              child: ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.event),
                                label: const Text('More Events'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: MediaQuery.of(context).padding.bottom + Spacing.md),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

