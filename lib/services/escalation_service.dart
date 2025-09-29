import 'dart:convert';
import 'dart:io';

class EscalationService {
  // Static escalation service - no database operations
  // Just provides success responses for demo purposes
  
  static final List<Map<String, dynamic>> _staticTickets = [];
  
  // Generate expected response time based on priority
  static String _getExpectedResponseTime(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return '2-4 hours';
      case 'high':
        return '4-8 hours';
      case 'medium':
        return '1-2 business days';
      case 'low':
        return '3-5 business days';
      default:
        return '1-2 business days';
    }
  }

  // Create a new escalation ticket (Static - no database)
  static Future<EscalationResult> createTicket({
    required String issueDescription,
    required String customerName,
    required String customerPhone,
    required String modelNumber,
    required String priority,
    required String serviceCenter,
    required bool requiresParts,
    required bool requiresTechnician,
  }) async {
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));

      final ticketId = 'ESC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      final timestamp = DateTime.now().toIso8601String();

      // Store ticket data locally (for demo purposes)
      final ticketData = {
        'ticketId': ticketId,
        'issueDescription': issueDescription,
        'customerInfo': {
          'name': customerName,
          'phone': customerPhone,
          'modelNumber': modelNumber,
        },
        'priority': priority,
        'serviceCenter': serviceCenter,
        'requirements': {
          'parts': requiresParts,
          'technician': requiresTechnician,
        },
        'status': 'submitted',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      _staticTickets.add(ticketData);

      print('✅ Static Escalation Ticket Created: $ticketId');
      print('� Priority: $priority | Service Center: $serviceCenter');
      print('📋 Requirements: Parts: $requiresParts, Technician: $requiresTechnician');

      return EscalationResult(
        success: true,
        ticketId: ticketId,
        message: 'Your escalation has been submitted successfully! Our service team will contact you within ${_getExpectedResponseTime(priority)}.',
        expectedResponse: _getExpectedResponseTime(priority),
      );
    } catch (e) {
      print('❌ Escalation Service Error: $e');
      return EscalationResult(
        success: false,
        error: e.toString(),
        message: 'Failed to submit escalation ticket. Please try again.',
      );
    }
  }

  // Retrieve escalation ticket by ID (Static - from local storage)
  static Future<EscalationTicket?> getTicket(String ticketId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Find ticket in static list
      final ticketData = _staticTickets.firstWhere(
        (ticket) => ticket['ticketId'] == ticketId,
        orElse: () => {},
      );

      if (ticketData.isNotEmpty) {
        return EscalationTicket.fromJson(ticketData);
      }
      
      return null;
    } catch (e) {
      print('❌ Get Ticket Error: $e');
      return null;
    }
  }

  // Update ticket status (Static - updates local data)
  static Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Find and update ticket in static list
      for (var ticket in _staticTickets) {
        if (ticket['ticketId'] == ticketId) {
          ticket['status'] = newStatus;
          ticket['updatedAt'] = DateTime.now().toIso8601String();
          print('✅ Ticket $ticketId status updated to: $newStatus');
          return true;
        }
      }
      
      print('❌ Ticket $ticketId not found');
      return false;
    } catch (e) {
      print('❌ Update Ticket Error: $e');
      return false;
    }
  }

  // Get all tickets for a customer (Static - from local data)
  static Future<List<EscalationTicket>> getCustomerTickets(String customerPhone) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Filter tickets by customer phone
      final customerTickets = _staticTickets
          .where((ticket) => ticket['customerInfo']?['phone'] == customerPhone)
          .map((ticketData) => EscalationTicket.fromJson(ticketData))
          .toList();

      // Sort by creation date (latest first)
      customerTickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('📋 Found ${customerTickets.length} tickets for customer: $customerPhone');
      return customerTickets;
    } catch (e) {
      print('❌ Get Customer Tickets Error: $e');
      return [];
    }
  }
}

// Data models
class EscalationResult {
  final bool success;
  final String? ticketId;
  final String message;
  final String? error;
  final String? expectedResponse;

  EscalationResult({
    required this.success,
    this.ticketId,
    required this.message,
    this.error,
    this.expectedResponse,
  });
}

class EscalationTicket {
  final String ticketId;
  final String issueDescription;
  final CustomerInfo customerInfo;
  final String priority;
  final String serviceCenter;
  final Requirements requirements;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String expectedResponse;

  EscalationTicket({
    required this.ticketId,
    required this.issueDescription,
    required this.customerInfo,
    required this.priority,
    required this.serviceCenter,
    required this.requirements,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expectedResponse,
  });

  factory EscalationTicket.fromJson(Map<String, dynamic> json) {
    return EscalationTicket(
      ticketId: json['ticketId'] ?? '',
      issueDescription: json['issueDescription'] ?? '',
      customerInfo: CustomerInfo.fromJson(json['customerInfo'] ?? {}),
      priority: json['priority'] ?? '',
      serviceCenter: json['serviceCenter'] ?? '',
      requirements: Requirements.fromJson(json['requirements'] ?? {}),
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      expectedResponse: json['expectedResponse'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'issueDescription': issueDescription,
      'customerInfo': customerInfo.toJson(),
      'priority': priority,
      'serviceCenter': serviceCenter,
      'requirements': requirements.toJson(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expectedResponse': expectedResponse,
    };
  }
}

class CustomerInfo {
  final String name;
  final String phone;
  final String modelNumber;

  CustomerInfo({
    required this.name,
    required this.phone,
    required this.modelNumber,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      modelNumber: json['modelNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'modelNumber': modelNumber,
    };
  }
}

class Requirements {
  final bool parts;
  final bool technician;

  Requirements({
    required this.parts,
    required this.technician,
  });

  factory Requirements.fromJson(Map<String, dynamic> json) {
    return Requirements(
      parts: json['parts'] ?? false,
      technician: json['technician'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parts': parts,
      'technician': technician,
    };
  }
}
