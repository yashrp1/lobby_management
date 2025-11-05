import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/event_detail_model.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/animations.dart';
import 'host_profile_preview.dart';
import '../../services/booking_queue_service.dart';
import '../../core/di/injector.dart';
import '../../data/repository/event_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/connectivity_service.dart';

class EventDetailContent extends StatelessWidget {
  final EventDetailModel event;
  final int viewingCount;

  const EventDetailContent({
    super.key,
    required this.event,
    required this.viewingCount,
  });

  @override
  Widget build(BuildContext context) {
    final lobby = event.lobby;
    final location = lobby.filter?.otherFilterInfo?.locationInfo?.firstLocation;
    final locationPoint = location?.exactLocation ?? location?.approxLocation;
    final DateTime? startDateTime = lobby.dateRange?.startDateTime;
    
    return RepaintBoundary(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Event Title Section
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.getScreenPadding(context),
              Spacing.lg,
              Responsive.getScreenPadding(context),
              Spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lobby.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 12),
                if ((event.category.name.isNotEmpty) || (event.subCategory.name.isNotEmpty))
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (event.category.name.isNotEmpty)
                        _CategoryBadge(label: event.category.name),
                      if (event.subCategory.name.isNotEmpty)
                        _CategoryBadge(label: event.subCategory.name),
                    ],
                  ),
                const SizedBox(height: 16),
                if (lobby.totalMembers > 0 || lobby.currentMembers > 0 || lobby.statusFlag.isNotEmpty)
                  Row(
                    children: [
                      if (lobby.totalMembers > 0 || lobby.currentMembers > 0) ...[
                        Icon(Icons.people, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          '${lobby.currentMembers}/${lobby.totalMembers} joined',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                      if (lobby.statusFlag.isNotEmpty) ...[
                        if (lobby.totalMembers > 0 || lobby.currentMembers > 0)
                          const SizedBox(width: 16),
                        _StatusBadge(status: lobby.statusFlag),
                      ],
                    ],
                  ),
                if (lobby.views > 0 || viewingCount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (lobby.views > 0) ...[
                        Icon(Icons.visibility, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${lobby.views} views',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      if (viewingCount > 0) ...[
                        if (lobby.views > 0) const SizedBox(width: 16),
                        Icon(Icons.remove_red_eye, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '$viewingCount viewing now',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (lobby.dateRange != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getScreenPadding(context),
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lobby.dateRange!.formattedDate ?? 
                      DateFormat('EEE, d MMM yyyy \'at\' HH:mm').format(lobby.dateRange!.startDateTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          if (startDateTime != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getScreenPadding(context),
              ),
              child: _CountdownTimer(target: startDateTime),
            ),
          if (location != null && location.displayAddress != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getScreenPadding(context),
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      location.displayAddress!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          if ((location != null && location.displayAddress != null) || (lobby.description != null && lobby.description!.isNotEmpty))
            SizedBox(height: Responsive.isTablet(context) ? Spacing.xl : Spacing.lg),
          if (lobby.description != null && lobby.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.getScreenPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    QuillDeltaParser.parseDeltaToPlainText(lobby.description),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Read more',
                        style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (lobby.description != null && lobby.description!.isNotEmpty)
            SizedBox(height: Responsive.isTablet(context) ? Spacing.xl : Spacing.lg),
          if (locationPoint != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.getScreenPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: Responsive.isTablet(context) ? 250 : 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Spacing.md - Spacing.xs),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Spacing.md - Spacing.xs),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(locationPoint.lat, locationPoint.lon),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.lobby_management',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(locationPoint.lat, locationPoint.lon),
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      onPressed: () async {
                        MicroInteractions.buttonPress(context);
                        final lat = locationPoint.lat;
                        final lon = locationPoint.lon;
                        
                        // Platform-specific app URLs
                        List<Uri> appUrls = [];
                        if (Platform.isAndroid) {
                          appUrls.add(Uri.parse('google.navigation:q=$lat,$lon'));
                        } else if (Platform.isIOS) {
                          appUrls.add(Uri.parse('comgooglemaps://?daddr=$lat,$lon&directionsmode=driving'));
                          appUrls.add(Uri.parse('maps://?daddr=$lat,$lon&dirflg=d'));
                        }
                        
                        final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
                        bool launched = false;
                        for (final appUrl in appUrls) {
                          try {
                            if (await canLaunchUrl(appUrl)) {
                              launched = await launchUrl(appUrl, mode: LaunchMode.externalApplication);
                              if (launched) break;
                            }
                          } catch (_) {}
                        }
                        if (!launched) {
                          try {
                            if (await canLaunchUrl(webUrl)) {
                              final ext = await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                              if (!ext) {
                                await launchUrl(webUrl, mode: LaunchMode.inAppWebView);
                              }
                            } else {
                              throw Exception('Cannot launch URL');
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Unable to open maps'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Spacing.sm),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (locationPoint != null) SizedBox(height: Responsive.isTablet(context) ? Spacing.xxxl : Spacing.xl),
          if (lobby.ticketOptions.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.getScreenPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pricing & Tickets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...lobby.ticketOptions.map((ticket) => Padding(
                        key: ValueKey(ticket.id),
                        padding: EdgeInsets.only(bottom: Responsive.isTablet(context) ? Spacing.md : Spacing.sm + Spacing.xs),
                        child: FadeInAnimation(
                          child: _TicketCard(ticket: ticket),
                        ),
                      )),
                ],
              ),
            ),
          if (lobby.ticketOptions.isNotEmpty) SizedBox(height: Responsive.isTablet(context) ? Spacing.xxxl : Spacing.xl),
          if (lobby.lobbyInsight != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.getScreenPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Community Insights',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (lobby.lobbyInsight!.summary != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lobby.lobbyInsight!.summary!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (lobby.lobbyInsight!.deeperInsight != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      lobby.lobbyInsight!.deeperInsight!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                  if (lobby.lobbyInsight!.topInterests != null && lobby.lobbyInsight!.topInterests!.isNotEmpty) ...[
                    SizedBox(height: Responsive.isTablet(context) ? Spacing.lg : Spacing.md),
                    Text(
                      'Top Interests',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Wrap(
                      spacing: Spacing.sm,
                      runSpacing: Spacing.sm,
                      children: lobby.lobbyInsight!.topInterests!
                          .map((interest) => Chip(
                                label: Text(
                                  interest,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.sm + Spacing.xs,
                                  vertical: Spacing.xs + 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(Spacing.md - Spacing.xs),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  if (lobby.lobbyInsight!.avgAge != null || lobby.lobbyInsight!.femaleRatio != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (lobby.lobbyInsight!.avgAge != null)
                          Expanded(
                            child: _StatCard(
                              icon: Icons.cake,
                              label: 'Avg Age',
                              value: lobby.lobbyInsight!.avgAge!.toStringAsFixed(0),
                            ),
                          ),
                        if (lobby.lobbyInsight!.avgAge != null && lobby.lobbyInsight!.femaleRatio != null)
                          const SizedBox(width: 8),
                        if (lobby.lobbyInsight!.femaleRatio != null)
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people,
                              label: 'Gender Ratio',
                              value: '${((1 - lobby.lobbyInsight!.femaleRatio!) * 100).toStringAsFixed(0)}% M / ${(lobby.lobbyInsight!.femaleRatio! * 100).toStringAsFixed(0)}% F',
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          if (lobby.lobbyInsight != null) SizedBox(height: Responsive.isTablet(context) ? Spacing.xxxl : Spacing.xl),
          if (event.lobby.userSummaries.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.getScreenPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_alt, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Users you might know',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestedUsers(event).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final user = _suggestedUsers(event)[index];
                        final initials = (user.name ?? user.email ?? user.userId).trim();
                        final display = initials.isNotEmpty ? initials[0].toUpperCase() : '?';
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Text(display, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 80,
                              child: Text(
                                user.name ?? user.email ?? 'User',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (event.lobby.userSummaries.isNotEmpty) SizedBox(height: Responsive.isTablet(context) ? Spacing.xxxl : Spacing.xl),
          if (lobby.houseDetail != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.getScreenPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                    'Host Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: Spacing.md),
                  GestureDetector(
                    onLongPress: () {
                      MicroInteractions.heavyInteraction(context);
                      HostProfilePreview.show(
                        context,
                        lobby.houseDetail!,
                        lobby.adminSummary,
                      );
                    },
                    child: Row(
                      children: [
                        Hero(
                          tag: 'host_profile_${lobby.houseDetail!.houseId}',
                          child:                       CircleAvatar(
                        radius: 30,
                        backgroundImage: lobby.houseDetail!.profilePhoto != null
                            ? CachedNetworkImageProvider(lobby.houseDetail!.profilePhoto!) as ImageProvider
                            : null,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: lobby.houseDetail!.profilePhoto == null
                                ? Icon(
                                    Icons.home,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm + Spacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lobby.houseDetail!.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (lobby.houseDetail!.description != null) ...[
                                const SizedBox(height: Spacing.xs),
                                Text(
                                  QuillDeltaParser.parseDeltaToPlainText(lobby.houseDetail!.description),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  if (lobby.adminSummary != null && 
                      (lobby.adminSummary!.name != null && lobby.adminSummary!.name!.isNotEmpty ||
                       lobby.adminSummary!.userName != null && lobby.adminSummary!.userName!.isNotEmpty)) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Admin',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: lobby.adminSummary!.profilePictureUrl != null
                              ? CachedNetworkImageProvider(lobby.adminSummary!.profilePictureUrl!) as ImageProvider
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: lobby.adminSummary!.profilePictureUrl == null
                              ? Icon(Icons.person, color: Colors.grey[600])
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lobby.adminSummary!.name ?? lobby.adminSummary!.userName ?? '',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        MicroInteractions.buttonPress(context);
                      },
                      child: const Text('View More Events'),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: Responsive.isTablet(context) ? Spacing.xxxl + Spacing.sm : Spacing.xxl),
          ],
        ),
      ),
    );
  }

  List<UserSummary> _suggestedUsers(EventDetailModel event) {
    final users = event.lobby.userSummaries;
    if (users.isEmpty) return users;
    // Heuristic: prefer users sharing the most common email domain among attendees
    final Map<String, int> domainCount = {};
    for (final u in users) {
      final email = u.email;
      if (email != null && email.contains('@')) {
        final domain = email.split('@').last.toLowerCase();
        domainCount[domain] = (domainCount[domain] ?? 0) + 1;
      }
    }
    String? topDomain;
    int best = 0;
    domainCount.forEach((d, c) {
      if (c > best) {
        best = c;
        topDomain = d;
      }
    });
    final filtered = topDomain == null
        ? users
        : users.where((u) => (u.email ?? '').toLowerCase().endsWith('@$topDomain')).toList();
    return (filtered.isNotEmpty ? filtered : users).take(12).toList();
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm + Spacing.xs, vertical: Spacing.xs + 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Spacing.md),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    if (status.toLowerCase().contains('filling')) color = Colors.orange;
    if (status.toLowerCase().contains('sold')) color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm + Spacing.xs, vertical: Spacing.xs + 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Spacing.md + Spacing.xs),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketOption ticket;
  const _TicketCard({required this.ticket});
  @override
  Widget build(BuildContext context) {
    final currencySymbol = ticket.currency == 'INR' ? '₹' : '\$';
    final currencyFormat = NumberFormat.currency(symbol: currencySymbol);
    final percentage = ticket.totalSlots > 0 ? ticket.availableSlots / ticket.totalSlots : 0.0;
    Color activityColor = Colors.orange;
    if (ticket.activity == 'LOW') activityColor = Colors.green;
    if (ticket.activity == 'HIGH') activityColor = Colors.red;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(Spacing.md - Spacing.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    if (ticket.description != null) ...[
                      const SizedBox(height: 4),
                      Text(ticket.description!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: activityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: activityColor, width: 1),
                ),
                child: Text(ticket.activity, style: TextStyle(color: activityColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(currencyFormat.format(ticket.price), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              if (ticket.strikePrice != null && ticket.strikePrice! > ticket.price) ...[
                const SizedBox(width: 8),
                Text(currencyFormat.format(ticket.strikePrice!), style: Theme.of(context).textTheme.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough, color: Colors.grey)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${ticket.availableSlots}/${ticket.totalSlots} remaining', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(percentage > 0.5 ? Colors.green : percentage > 0.2 ? Colors.orange : Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ScaleOnTap(
              onTap: ticket.availableSlots > 0 ? () {
                MicroInteractions.buttonPress(context);
              } : null,
              child: ElevatedButton(
                onPressed: ticket.availableSlots > 0 ? () async {
                  final repo = getIt.get<EventRepository>();
                  final queue = getIt.get<BookingQueueService>();
                  final connectivity = getIt.get<ConnectivityService>();
                  final status = await connectivity.check();
                  final payload = {
                    'eventId': (context.findAncestorWidgetOfExactType<EventDetailContent>() as EventDetailContent).event.lobby.id,
                    'ticketId': ticket.id,
                    'quantity': 1,
                    'token': null,
                  };
                  if (status == ConnectivityResult.none) {
                    await queue.enqueue(payload);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You\'re offline. Booking queued.'), duration: Duration(seconds: 2)),
                      );
                    }
                  } else {
                    try {
                      await repo.bookTicket(
                        eventId: payload['eventId'] as String,
                        ticketId: payload['ticketId'] as String,
                        quantity: payload['quantity'] as int,
                        token: payload['token'] as String?,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking successful'), duration: Duration(seconds: 2)),
                        );
                      }
                    } catch (_) {
                      await queue.enqueue(payload);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Network error. Booking queued.')), 
                        );
                      }
                    }
                  }
                } : null,
                child: Text(ticket.availableSlots > 0 ? 'Book Ticket' : 'Sold Out'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm + Spacing.xs),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Spacing.md - Spacing.xs),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  final DateTime target;
  const _CountdownTimer({required this.target});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Duration _remaining;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration _) {
    final newRemaining = _calcRemaining();
    if (mounted) {
      setState(() {
        _remaining = newRemaining;
      });
    }
    if (newRemaining.inSeconds <= 0) {
      _ticker.stop();
    }
  }

  Duration _calcRemaining() {
    final now = DateTime.now();
    final diff = widget.target.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    final label = _remaining == Duration.zero
        ? 'Event started'
        : 'Starts in ${days > 0 ? '$days d ' : ''}${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Icon(Icons.hourglass_bottom, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
