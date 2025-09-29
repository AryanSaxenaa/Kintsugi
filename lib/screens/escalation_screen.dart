import 'package:flutter/material.dart';
import '../services/escalation_service.dart';

class EscalationScreen extends StatefulWidget {
  final String? issueDescription;
  
  const EscalationScreen({Key? key, this.issueDescription}) : super(key: key);

  @override
  State<EscalationScreen> createState() => _EscalationScreenState();
}

class _EscalationScreenState extends State<EscalationScreen> {
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _modelNumberController = TextEditingController();
  
  String _selectedPriority = 'Medium';
  String _selectedServiceCenter = 'Samsung Service Center - Downtown';
  bool _requiresParts = false;
  bool _requiresTechnician = false;
  
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _serviceCenters = [
    'Samsung Service Center - Downtown',
    'Samsung Service Center - North Plaza', 
    'Samsung Service Center - Tech Hub',
    'Samsung Service Center - Mall District',
    'Samsung Service Center - West End',
    'Samsung Service Center - East Valley',
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.issueDescription != null) {
      _issueController.text = widget.issueDescription!;
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _modelNumberController.dispose();
    super.dispose();
  }

  void _submitEscalation() async {
    // Validate required fields
    if (_customerNameController.text.trim().isEmpty ||
        _customerPhoneController.text.trim().isEmpty ||
        _modelNumberController.text.trim().isEmpty ||
        _issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Submit escalation to MongoDB
      final result = await EscalationService.createTicket(
        issueDescription: _issueController.text.trim(),
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        modelNumber: _modelNumberController.text.trim(),
        priority: _selectedPriority,
        serviceCenter: _selectedServiceCenter,
        requiresParts: _requiresParts,
        requiresTechnician: _requiresTechnician,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (result.success) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Escalation Submitted',
                    style: TextStyle(
                      color: Color(0xFF1428A0),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your escalation request has been successfully submitted to $_selectedServiceCenter.',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1428A0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket ID: ${result.ticketId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1428A0),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Expected Response: ${result.expectedResponse}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You will receive updates via SMS on the provided phone number.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Go back to chat screen
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1428A0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Submission Failed',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Text(
                result.error ?? 'Failed to submit escalation. Please try again.',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getExpectedResponse() {
    switch (_selectedPriority) {
      case 'Critical':
        return '2-4 hours';
      case 'High':
        return '4-8 hours';
      case 'Medium':
        return '1-2 business days';
      case 'Low':
        return '3-5 business days';
      default:
        return '1-2 business days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1428A0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Escalate to Service Center',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1428A0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1428A0).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: const Color(0xFF1428A0),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Technical Support Escalation',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1428A0),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Submit complex issues to Samsung service centers for advanced diagnosis or part replacement.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Issue Description
            _buildSectionTitle('Issue Description'),
            _buildTextField(
              controller: _issueController,
              labelText: 'Describe the problem in detail',
              icon: Icons.description,
              maxLines: 4,
            ),
            
            const SizedBox(height: 20),
            
            // Customer Information
            _buildSectionTitle('Customer Information'),
            _buildTextField(
              controller: _customerNameController,
              labelText: 'Customer Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _customerPhoneController,
              labelText: 'Customer Phone Number',
              icon: Icons.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _modelNumberController,
              labelText: 'Washing Machine Model Number',
              icon: Icons.local_laundry_service,
            ),
            
            const SizedBox(height: 20),
            
            // Priority Selection
            _buildSectionTitle('Priority Level'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1428A0).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPriority,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF1428A0)),
                  items: _priorities.map((String priority) {
                    Color priorityColor;
                    switch (priority) {
                      case 'Critical':
                        priorityColor = Colors.red;
                        break;
                      case 'High':
                        priorityColor = Colors.orange;
                        break;
                      case 'Medium':
                        priorityColor = Colors.blue;
                        break;
                      case 'Low':
                        priorityColor = Colors.green;
                        break;
                      default:
                        priorityColor = Colors.grey;
                    }
                    
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(priority),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Service Center Selection
            _buildSectionTitle('Service Center'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1428A0).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedServiceCenter,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF1428A0)),
                  items: _serviceCenters.map((String center) {
                    return DropdownMenuItem<String>(
                      value: center,
                      child: Text(
                        center,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedServiceCenter = newValue!;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Requirements Checkboxes
            _buildSectionTitle('Requirements'),
            CheckboxListTile(
              title: const Text('Requires replacement parts'),
              subtitle: const Text('Parts may need to be ordered'),
              value: _requiresParts,
              onChanged: (bool? value) {
                setState(() {
                  _requiresParts = value ?? false;
                });
              },
              activeColor: const Color(0xFF1428A0),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Requires additional technician'),
              subtitle: const Text('Complex repair needs specialist'),
              value: _requiresTechnician,
              onChanged: (bool? value) {
                setState(() {
                  _requiresTechnician = value ?? false;
                });
              },
              activeColor: const Color(0xFF1428A0),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEscalation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1428A0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Submitting...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.escalator_warning, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Submit Escalation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1428A0),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF1428A0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1428A0), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}