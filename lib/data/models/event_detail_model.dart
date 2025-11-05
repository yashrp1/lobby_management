import 'package:equatable/equatable.dart';
import 'dart:convert';

class EventDetailModel extends Equatable {
  final Lobby lobby;
  final Category category;
  final SubCategory subCategory;

  const EventDetailModel({
    required this.lobby,
    required this.category,
    required this.subCategory,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    return EventDetailModel(
      lobby: Lobby.fromJson(json['lobby'] ?? {}),
      category: Category.fromJson(json['category'] ?? {}),
      subCategory: SubCategory.fromJson(json['subCategory'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [lobby, category, subCategory];

  EventDetailModel copyWith({
    Lobby? lobby,
    Category? category,
    SubCategory? subCategory,
  }) {
    return EventDetailModel(
      lobby: lobby ?? this.lobby,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
    );
  }
}

class Lobby extends Equatable {
  final String id;
  final String title;
  final String? description; // Quill Delta JSON string
  final List<String> mediaUrls;
  final String lobbyStatus;
  final Filter? filter;
  final int totalMembers;
  final int currentMembers;
  final int membersRequired;
  final bool isPaid;
  final List<LocationPoint> locations;
  final AdminSummary? adminSummary;
  final DateRange? dateRange;
  final String activity; // "LOW", "MEDIUM", "HIGH"
  final String statusFlag; // "Open spots", etc.
  final String? houseId;
  final HouseDetail? houseDetail;
  final Form? form;
  final bool hasForm;
  final PriceDetails? priceDetails;
  final List<String> admins;
  final List<TicketOption> ticketOptions;
  final int views;
  final LobbyInsight? lobbyInsight;
  final List<UserSummary> userSummaries;

  const Lobby({
    required this.id,
    required this.title,
    this.description,
    required this.mediaUrls,
    required this.lobbyStatus,
    this.filter,
    required this.totalMembers,
    required this.currentMembers,
    required this.membersRequired,
    required this.isPaid,
    required this.locations,
    this.adminSummary,
    this.dateRange,
    required this.activity,
    required this.statusFlag,
    this.houseId,
    this.houseDetail,
    this.form,
    required this.hasForm,
    this.priceDetails,
    required this.admins,
    required this.ticketOptions,
    required this.views,
    this.lobbyInsight,
    required this.userSummaries,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    return Lobby(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      mediaUrls: json['mediaUrls'] != null
          ? List<String>.from(json['mediaUrls'])
          : [],
      lobbyStatus: json['lobbyStatus'] ?? '',
      filter: json['filter'] != null ? Filter.fromJson(json['filter']) : null,
      totalMembers: json['totalMembers'] ?? 0,
      currentMembers: json['currentMembers'] ?? 0,
      membersRequired: json['membersRequired'] ?? 0,
      isPaid: json['isPaid'] ?? false,
      locations: json['locations'] != null
          ? (json['locations'] as List).map((e) => LocationPoint.fromJson(e)).toList()
          : [],
      adminSummary: json['adminSummary'] != null
          ? AdminSummary.fromJson(json['adminSummary'])
          : null,
      dateRange: json['dateRange'] != null
          ? DateRange.fromJson(json['dateRange'])
          : null,
      activity: json['activity'] ?? 'LOW',
      statusFlag: json['statusFlag'] ?? 'Open spots',
      houseId: json['houseId'],
      houseDetail: json['houseDetail'] != null
          ? HouseDetail.fromJson(json['houseDetail'])
          : null,
      form: json['form'] != null ? Form.fromJson(json['form']) : null,
      hasForm: json['hasForm'] ?? false,
      priceDetails: json['priceDetails'] != null
          ? PriceDetails.fromJson(json['priceDetails'])
          : null,
      admins: json['admins'] != null
          ? List<String>.from(json['admins'])
          : [],
      ticketOptions: json['ticketOptions'] != null
          ? (json['ticketOptions'] as List)
              .map((e) => TicketOption.fromJson(e))
              .toList()
          : [],
      views: json['views'] ?? 0,
      lobbyInsight: json['lobbyInsight'] != null
          ? LobbyInsight.fromJson(json['lobbyInsight'])
          : null,
      userSummaries: json['userSummaries'] != null
          ? (json['userSummaries'] as List)
              .map((e) => UserSummary.fromJson(e))
              .toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        mediaUrls,
        lobbyStatus,
        filter,
        totalMembers,
        currentMembers,
        membersRequired,
        isPaid,
        locations,
        adminSummary,
        dateRange,
        activity,
        statusFlag,
        houseId,
        houseDetail,
        form,
        hasForm,
        priceDetails,
        admins,
        ticketOptions,
        views,
        lobbyInsight,
        userSummaries,
      ];

  Lobby copyWith({
    int? currentMembers,
    int? totalMembers,
    int? views,
    String? statusFlag,
  }) {
    return Lobby(
      id: id,
      title: title,
      description: description,
      mediaUrls: mediaUrls,
      lobbyStatus: lobbyStatus,
      filter: filter,
      totalMembers: totalMembers ?? this.totalMembers,
      currentMembers: currentMembers ?? this.currentMembers,
      membersRequired: membersRequired,
      isPaid: isPaid,
      locations: locations,
      adminSummary: adminSummary,
      dateRange: dateRange,
      activity: activity,
      statusFlag: statusFlag ?? this.statusFlag,
      houseId: houseId,
      houseDetail: houseDetail,
      form: form,
      hasForm: hasForm,
      priceDetails: priceDetails,
      admins: admins,
      ticketOptions: ticketOptions,
      views: views ?? this.views,
      lobbyInsight: lobbyInsight,
      userSummaries: userSummaries,
    );
  }
}

class Filter extends Equatable {
  final String? categoryId;
  final String? categoryName;
  final String? subCategoryId;
  final String? subCategoryName;
  final OtherFilterInfo? otherFilterInfo;

  const Filter({
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.otherFilterInfo,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      subCategoryId: json['subCategoryId'],
      subCategoryName: json['subCategoryName'],
      otherFilterInfo: json['otherFilterInfo'] != null
          ? OtherFilterInfo.fromJson(json['otherFilterInfo'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        subCategoryId,
        subCategoryName,
        otherFilterInfo,
      ];
}

class OtherFilterInfo extends Equatable {
  final DateRangeFilter? dateRange;
  final MemberCountFilter? memberCount;
  final LocationInfo? locationInfo;

  const OtherFilterInfo({
    this.dateRange,
    this.memberCount,
    this.locationInfo,
  });

  factory OtherFilterInfo.fromJson(Map<String, dynamic> json) {
    return OtherFilterInfo(
      dateRange: json['dateRange'] != null
          ? DateRangeFilter.fromJson(json['dateRange'])
          : null,
      memberCount: json['memberCount'] != null
          ? MemberCountFilter.fromJson(json['memberCount'])
          : null,
      locationInfo: json['locationInfo'] != null
          ? LocationInfo.fromJson(json['locationInfo'])
          : null,
    );
  }

  @override
  List<Object?> get props => [dateRange, memberCount, locationInfo];
}

class DateRangeFilter extends Equatable {
  final int startDate;
  final int endDate;
  final String? formattedDate;

  const DateRangeFilter({
    required this.startDate,
    required this.endDate,
    this.formattedDate,
  });

  factory DateRangeFilter.fromJson(Map<String, dynamic> json) {
    return DateRangeFilter(
      startDate: json['startDate'] ?? 0,
      endDate: json['endDate'] ?? 0,
      formattedDate: json['formattedDate'],
    );
  }

  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(startDate);
  DateTime get endDateTime => DateTime.fromMillisecondsSinceEpoch(endDate);

  @override
  List<Object?> get props => [startDate, endDate, formattedDate];
}

class MemberCountFilter extends Equatable {
  final int value;
  final String? title;

  const MemberCountFilter({
    required this.value,
    this.title,
  });

  factory MemberCountFilter.fromJson(Map<String, dynamic> json) {
    return MemberCountFilter(
      value: json['value'] ?? 0,
      title: json['title'],
    );
  }

  @override
  List<Object?> get props => [value, title];
}

class LocationInfo extends Equatable {
  final List<LocationResponse> locationResponses;

  const LocationInfo({
    required this.locationResponses,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      locationResponses: json['locationResponses'] != null
          ? (json['locationResponses'] as List)
              .map((e) => LocationResponse.fromJson(e))
              .toList()
          : [],
    );
  }

  LocationResponse? get firstLocation =>
      locationResponses.isNotEmpty ? locationResponses.first : null;

  @override
  List<Object?> get props => [locationResponses];
}

class LocationResponse extends Equatable {
  final LocationPoint? exactLocation;
  final LocationPoint? approxLocation;
  final String? areaName;
  final String? fuzzyAddress;
  final String? formattedAddress;

  const LocationResponse({
    this.exactLocation,
    this.approxLocation,
    this.areaName,
    this.fuzzyAddress,
    this.formattedAddress,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      exactLocation: json['exactLocation'] != null
          ? LocationPoint.fromJson(json['exactLocation'])
          : null,
      approxLocation: json['approxLocation'] != null
          ? LocationPoint.fromJson(json['approxLocation'])
          : null,
      areaName: json['areaName'],
      fuzzyAddress: json['fuzzyAddress'],
      formattedAddress: json['formattedAddress'],
    );
  }

  String? get displayAddress {
    if (formattedAddress != null && formattedAddress!.isNotEmpty) {
      return formattedAddress;
    }
    if (fuzzyAddress != null && fuzzyAddress!.isNotEmpty) {
      return fuzzyAddress;
    }
    if (areaName != null && areaName!.isNotEmpty) {
      return areaName;
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [exactLocation, approxLocation, areaName, fuzzyAddress, formattedAddress];
}

class LocationPoint extends Equatable {
  final double lat;
  final double lon;

  const LocationPoint({
    required this.lat,
    required this.lon,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [lat, lon];
}

class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['iconUrl'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, iconUrl];
}

class SubCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;

  const SubCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['iconUrl'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, iconUrl];
}

class DateRange extends Equatable {
  final int startDate;
  final int endDate;
  final String? formattedDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
    this.formattedDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate: json['startDate'] ?? 0,
      endDate: json['endDate'] ?? 0,
      formattedDate: json['formattedDate'],
    );
  }

  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(startDate);
  DateTime get endDateTime => DateTime.fromMillisecondsSinceEpoch(endDate);

  @override
  List<Object?> get props => [startDate, endDate, formattedDate];
}

class AdminSummary extends Equatable {
  final String userId;
  final String? userName;
  final String? name;
  final String? profilePictureUrl;
  final String? email;

  const AdminSummary({
    required this.userId,
    this.userName,
    this.name,
    this.profilePictureUrl,
    this.email,
  });

  factory AdminSummary.fromJson(Map<String, dynamic> json) {
    return AdminSummary(
      userId: json['userId'] ?? '',
      userName: json['userName'],
      name: json['name'],
      profilePictureUrl: json['profilePictureUrl'],
      email: json['email'],
    );
  }

  @override
  List<Object?> get props => [userId, userName, name, profilePictureUrl, email];
}

class HouseDetail extends Equatable {
  final String houseId;
  final String name;
  final String? description; // Quill Delta JSON string
  final String? profilePhoto;
  final List<String> admins;

  const HouseDetail({
    required this.houseId,
    required this.name,
    this.description,
    this.profilePhoto,
    required this.admins,
  });

  factory HouseDetail.fromJson(Map<String, dynamic> json) {
    return HouseDetail(
      houseId: json['houseId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      profilePhoto: json['profilePhoto'],
      admins: json['admins'] != null ? List<String>.from(json['admins']) : [],
    );
  }

  @override
  List<Object?> get props => [houseId, name, description, profilePhoto, admins];
}

class Form extends Equatable {
  final List<FormMapping> formMappings;

  const Form({
    required this.formMappings,
  });

  factory Form.fromJson(Map<String, dynamic> json) {
    return Form(
      formMappings: json['formMappings'] != null
          ? (json['formMappings'] as List)
              .map((e) => FormMapping.fromJson(e))
              .toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [formMappings];
}

class FormMapping extends Equatable {
  final String questionId;
  final List<String> ticketIds;

  const FormMapping({
    required this.questionId,
    required this.ticketIds,
  });

  factory FormMapping.fromJson(Map<String, dynamic> json) {
    return FormMapping(
      questionId: json['questionId'] ?? '',
      ticketIds: json['ticketIds'] != null
          ? List<String>.from(json['ticketIds'])
          : [],
    );
  }

  @override
  List<Object?> get props => [questionId, ticketIds];
}

class PriceDetails extends Equatable {
  final double price;
  final double? originalPrice;
  final double? strikePrice;
  final String? currency;

  const PriceDetails({
    required this.price,
    this.originalPrice,
    this.strikePrice,
    this.currency,
  });

  factory PriceDetails.fromJson(Map<String, dynamic> json) {
    return PriceDetails(
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      strikePrice: json['strikePrice']?.toDouble(),
      currency: json['currency'],
    );
  }

  @override
  List<Object?> get props => [price, originalPrice, strikePrice, currency];
}

class TicketOption extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? strikePrice;
  final int totalSlots;
  final int bookedSlots;
  final String? currency;
  final int minQuantity;
  final int maxQuantity;
  final String activity; // "LOW", "MEDIUM", "HIGH"

  const TicketOption({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.strikePrice,
    required this.totalSlots,
    required this.bookedSlots,
    required this.currency,
    required this.minQuantity,
    required this.maxQuantity,
    required this.activity,
  });

  factory TicketOption.fromJson(Map<String, dynamic> json) {
    return TicketOption(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      strikePrice: json['strikePrice']?.toDouble(),
      totalSlots: json['totalSlots'] ?? 0,
      bookedSlots: json['bookedSlots'] ?? 0,
      currency: json['currency'] ?? 'INR',
      minQuantity: json['minQuantity'] ?? 1,
      maxQuantity: json['maxQuantity'] ?? 1,
      activity: json['activity'] ?? 'LOW',
    );
  }

  int get availableSlots => totalSlots - bookedSlots;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        strikePrice,
        totalSlots,
        bookedSlots,
        currency,
        minQuantity,
        maxQuantity,
        activity,
      ];
}

class LobbyInsight extends Equatable {
  final String? summary;
  final String? deeperInsight;
  final double? avgAge;
  final List<String>? topInterests;
  final double? femaleRatio;
  final double? maleCount;
  final double? femaleCount;

  const LobbyInsight({
    this.summary,
    this.deeperInsight,
    this.avgAge,
    this.topInterests,
    this.femaleRatio,
    this.maleCount,
    this.femaleCount,
  });

  factory LobbyInsight.fromJson(Map<String, dynamic> json) {
    return LobbyInsight(
      summary: json['summary'],
      deeperInsight: json['deeperInsight'],
      avgAge: json['avgAge']?.toDouble(),
      topInterests: json['topInterests'] != null
          ? List<String>.from(json['topInterests'])
          : null,
      femaleRatio: json['femaleRatio']?.toDouble(),
      maleCount: json['maleCount']?.toDouble(),
      femaleCount: json['femaleCount']?.toDouble(),
    );
  }

  @override
  List<Object?> get props =>
      [summary, deeperInsight, avgAge, topInterests, femaleRatio, maleCount, femaleCount];
}

class UserSummary extends Equatable {
  final String userId;
  final String? name;
  final String? email;
  final String? mobile;

  const UserSummary({
    required this.userId,
    this.name,
    this.email,
    this.mobile,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      userId: json['userId'] ?? '',
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }

  @override
  List<Object?> get props => [userId, name, email, mobile];
}

// Helper class to parse Quill Delta description
class QuillDeltaParser {
  /// Parse Quill Delta JSON format to plain text
  /// Handles complex nested structures, embedded objects, and formatting
  static String parseDeltaToPlainText(String? deltaJson) {
    if (deltaJson == null || deltaJson.isEmpty) return '';

    try {
      // Sanitize input first
      final sanitized = deltaJson.trim();
      
      // Validate JSON format
      if (!sanitized.startsWith('[') || !sanitized.endsWith(']')) {
        // If not valid JSON array, return sanitized plain text
        return sanitized;
      }

      final List<dynamic> delta = jsonDecode(sanitized);
      final buffer = StringBuffer();
      bool needsNewline = false;

      for (var op in delta) {
        if (op is Map) {
          // Handle 'insert' operations
          if (op.containsKey('insert')) {
            final insert = op['insert'];
            
            if (insert is String) {
              // Add newline if needed (from previous operation)
              if (needsNewline) {
                buffer.write('\n');
                needsNewline = false;
              }
              buffer.write(insert);
            } else if (insert is Map) {
              // Handle embedded objects (images, mentions, etc.)
              if (insert.containsKey('image')) {
                buffer.write('[Image]');
              } else if (insert.containsKey('video')) {
                buffer.write('[Video]');
              } else if (insert.containsKey('mention')) {
                final mention = insert['mention'];
                if (mention is Map && mention.containsKey('id')) {
                  buffer.write('@${mention['id'] ?? 'user'}');
                }
              }
            }
          }
          
          // Handle 'retain' operations (formatting)
          if (op.containsKey('retain') && op['retain'] is num) {
            // Skip formatting, just maintain position
          }
          
          // Handle 'delete' operations
          if (op.containsKey('delete') && op['delete'] is num) {
            // Remove characters (not needed for plain text)
          }
          
          // Check for newline in attributes
          final attrs = op['attributes'];
          if (attrs is Map && attrs.containsKey('align')) {
            needsNewline = true;
          }
        }
      }

      final result = buffer.toString().trim();
      // Return empty string if result is empty, otherwise return parsed text
      return result.isEmpty ? '' : result;
    } catch (e) {
      // If parsing fails, return sanitized input (graceful degradation)
      return deltaJson.trim();
    }
  }
  
  /// Validate Quill Delta JSON format
  static bool isValidDelta(String? deltaJson) {
    if (deltaJson == null || deltaJson.isEmpty) return false;
    
    try {
      final sanitized = deltaJson.trim();
      if (!sanitized.startsWith('[') || !sanitized.endsWith(']')) {
        return false;
      }
      
      final delta = jsonDecode(sanitized);
      return delta is List;
    } catch (e) {
      return false;
    }
  }
}
