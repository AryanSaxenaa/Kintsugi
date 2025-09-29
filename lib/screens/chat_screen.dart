import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'escalation_screen.dart';
import '../services/kintsugi_api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  List<File> _attachedFiles = [];
  bool _hasText = false;
  
  // Audio recording variables
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;
  final List<Map<String, dynamic>> _messages = [
    {'role': 'assistant', 'text': 'Welcome to Kintsugi! I\'m your Samsung washing machine diagnostic assistant. How can I help you today?', 'files': <File>[]},
  ];

  void _sendMessage() async {
    print('💬 Send message called');
    print('📝 Query text: "${_queryController.text.trim()}"');
    print('📎 Attached files count: ${_attachedFiles.length}');
    
    if (_queryController.text.trim().isEmpty && _attachedFiles.isEmpty) {
      print('❌ Nothing to send - empty message and no files');
      return;
    }
    
    final userMessage = _queryController.text.trim();
    final attachedFiles = List<File>.from(_attachedFiles);
    
    print('📤 Preparing to send:');
    print('   Message: "$userMessage"');
    print('   Files: ${attachedFiles.length}');
    print('   File paths: ${attachedFiles.map((f) => f.path).toList()}');
    
    setState(() {
      _messages.add({
        'role': 'user', 
        'text': userMessage.isEmpty ? 'Sent ${attachedFiles.length} file(s)' : userMessage,
        'files': attachedFiles
      });
      _queryController.clear();
      _attachedFiles.clear();
      _isTyping = true;
    });
    
    _scrollToBottom();

    try {
      // Call the actual API with PNG-converted images
      print('🔍 Sending to API - Files: ${attachedFiles.length}');
      print('🎨 Images will be automatically converted to PNG format for API compatibility');
      
      final apiResponse = await KintsugiApiService.sendMessage(
        message: userMessage,
        attachedFiles: attachedFiles.isNotEmpty ? attachedFiles : null,
      );

      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'assistant', 
          'text': apiResponse.message,
          'files': <File>[]
        });
      });
      
      // Show error indicator if API failed
      if (!apiResponse.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Error: ${apiResponse.error ?? 'Connection failed'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'assistant', 
          'text': 'Connection failed. Please check your internet connection and try again.',
          'files': <File>[]
        });
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _attachCamera() async {
    try {
      print('📷 Starting camera capture...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        print('📷 Camera image captured: ${image.path}');
        print('📄 File exists: ${await File(image.path).exists()}');
        setState(() {
          _attachedFiles.add(File(image.path));
        });
        print('📎 Total attachments after adding: ${_attachedFiles.length}');
        print('📎 Attachment list: ${_attachedFiles.map((f) => f.path).toList()}');
      } else {
        print('❌ No image captured from camera');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image captured')),
        );
      }
    } catch (e) {
      print('❌ Camera error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to access camera: ${e.toString()}')),
      );
    }
  }

  Future<void> _attachGallery() async {
    try {
      print('🖼️ Starting gallery selection...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        print('🖼️ Gallery image selected: ${image.path}');
        print('📄 File exists: ${await File(image.path).exists()}');
        setState(() {
          _attachedFiles.add(File(image.path));
        });
        print('📎 Total attachments after adding: ${_attachedFiles.length}');
        print('📎 Attachment list: ${_attachedFiles.map((f) => f.path).toList()}');
      } else {
        print('❌ No image selected from gallery');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      print('❌ Gallery error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to access gallery: ${e.toString()}')),
      );
    }
  }

  Future<void> _attachFile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File attachment coming soon! Use camera or gallery for now.')),
    );
  }



  void _removeAttachment(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1428A0)),
                title: const Text('Take Photo'),
                subtitle: const Text('Capture washing machine issue'),
                onTap: () {
                  Navigator.pop(context);
                  _attachCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1428A0)),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select existing photo'),
                onTap: () {
                  Navigator.pop(context);
                  _attachGallery();
                },
              ),
              ListTile(
                leading: Icon(
                  _isRecording ? Icons.stop : Icons.record_voice_over,
                  color: _isRecording ? Colors.red : const Color(0xFF1428A0),
                ),
                title: Text(_isRecording ? 'Stop Recording' : 'Record Machine Audio'),
                subtitle: Text(_isRecording ? 'Recording washing machine sounds...' : 'Record machine sounds for diagnosis'),
                onTap: () {
                  Navigator.pop(context);
                  if (_isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1428A0), // Samsung blue background to match login
      appBar: AppBar(
        backgroundColor: const Color(0xFF1428A0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_laundry_service,
                color: Color(0xFF1428A0),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'KINTSUGI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        actions: [
          // Add escalation button to app bar
          IconButton(
            icon: const Icon(Icons.escalator_warning, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EscalationScreen(),
                ),
              );
            },
            tooltip: 'Escalate to Service Center',
          ),
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Welcome message container
              if (_messages.isEmpty || (_messages.length == 1 && _messages.first['role'] == 'assistant'))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1428A0),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Hi there!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How can I help you today? Pick one of the options below or ask me directly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Feature buttons
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildFeatureButton(Icons.search, 'Diagnose Issue', () {
                            setState(() {
                              _messages.add({'role': 'user', 'text': 'I need help diagnosing an issue with my washing machine'});
                            });
                          }),
                          _buildFeatureButton(Icons.help_outline, 'Get Help', () {
                            setState(() {
                              _messages.add({'role': 'user', 'text': 'I need general help with my washing machine'});
                            });
                          }),
                          _buildFeatureButton(Icons.escalator_warning, 'Escalate Issue', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EscalationScreen(),
                              ),
                            );
                          }),
                          _buildFeatureButton(Icons.lightbulb_outline, 'Tips', () {
                            setState(() {
                              _messages.add({'role': 'user', 'text': 'Can you give me some maintenance tips?'});
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              
              // Chat messages area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: _messages.length > 1 || (_messages.length == 1 && _messages.first['role'] == 'user')
                      ? ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            if (index == 0 && message['role'] == 'assistant') {
                              return const SizedBox.shrink(); // Hide initial welcome message in chat
                            }
                            return _buildMessage(message);
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              
              // Input area with flexible layout to prevent overflow
              SafeArea(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 0.2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Attachment preview area - more compact
                        if (_attachedFiles.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            constraints: const BoxConstraints(maxHeight: 120), // Limit height
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Attachments (${_attachedFiles.length})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _attachedFiles.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final file = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: _buildAttachmentChip(file, index),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Input row - more compact padding
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                icon: const Icon(
                                  Icons.attach_file,
                                  color: Color(0xFF1428A0),
                                  size: 20,
                                ),
                                onPressed: _showAttachmentOptions,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 36,
                                    maxHeight: 80, // Reduced max height
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(18), // Slightly smaller border radius
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  child: TextField(
                                    controller: _queryController,
                                    minLines: 1,
                                    maxLines: 3, // Limit to 3 lines instead of null
                                    style: const TextStyle(fontSize: 14),
                                    decoration: const InputDecoration(
                                      hintText: 'Type your message...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Send/Stop button - changes based on recording state
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                icon: Icon(
                                  _isRecording ? Icons.stop : Icons.send,
                                  color: _isRecording 
                                      ? Colors.red 
                                      : ((_hasText || _attachedFiles.isNotEmpty)
                                          ? const Color(0xFF1428A0) 
                                          : Colors.grey),
                                  size: 20,
                                ),
                                onPressed: _isRecording ? _stopRecording : _sendMessage,
                              ),
                              // Microphone button - placeholder for future speech-to-text
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                icon: const Icon(
                                  Icons.mic,
                                  color: Color(0xFF1428A0),
                                  size: 20,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Speech-to-text feature coming in future updates!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Buffering overlay covering entire chat area
          if (_isTyping)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/app-images/washing-machine.gif',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Kintsugi is thinking...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1428A0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Analyzing your request...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final String text = message['text'] ?? '';
    final bool isUser = message['role'] == 'user';
    final List<File> files = message['files'] ?? <File>[];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1428A0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.local_laundry_service, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Show attached files
                if (files.isNotEmpty) ...[
                  ...files.map((file) => _buildFilePreview(file, isUser)),
                  const SizedBox(height: 4),
                ],
                // Show text message
                if (text.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1428A0) : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1428A0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person, color: Color(0xFF1428A0), size: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilePreview(File file, bool isUser) {
    final String fileName = file.path.split('/').last;
    final String extension = fileName.toLowerCase().split('.').last;
    
    // Check if it's an image
    bool isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
      ),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF1428A0).withOpacity(0.8) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUser ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: isImage 
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              width: MediaQuery.of(context).size.width * 0.5,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                _buildFileIcon(fileName, isUser),
            ),
          )
        : _buildFileIcon(fileName, isUser),
    );
  }

  Widget _buildFileIcon(String fileName, bool isUser) {
    final String extension = fileName.toLowerCase().split('.').last;
    IconData icon;
    
    switch (extension) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        break;
      case 'mp4':
      case 'mov':
        icon = Icons.video_file;
        break;
      case 'mp3':
      case 'wav':
        icon = Icons.audio_file;
        break;
      default:
        icon = Icons.attach_file;
    }
    
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isUser ? Colors.white : const Color(0xFF1428A0),
            size: 20,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              fileName,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentChip(File file, int index) {
    final String fileName = file.path.split('/').last;
    final String extension = fileName.toLowerCase().split('.').last;
    
    IconData icon;
    Color chipColor;
    
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      icon = Icons.image;
      chipColor = Colors.blue.withOpacity(0.1);
    } else if (['pdf'].contains(extension)) {
      icon = Icons.picture_as_pdf;
      chipColor = Colors.red.withOpacity(0.1);
    } else if (['mp4', 'mov'].contains(extension)) {
      icon = Icons.video_file;
      chipColor = Colors.purple.withOpacity(0.1);
    } else if (['mp3', 'wav'].contains(extension)) {
      icon = Icons.audio_file;
      chipColor = Colors.orange.withOpacity(0.1);
    } else {
      icon = Icons.attach_file;
      chipColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // More compact padding
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12), // Smaller border radius
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1428A0)), // Smaller icon
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              fileName.length > 12 ? '${fileName.substring(0, 9)}...' : fileName, // Shorter filename
              style: const TextStyle(
                fontSize: 10, // Smaller font
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: () => _removeAttachment(index),
            child: const Icon(
              Icons.close,
              size: 12, // Smaller close icon
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
    
    // Listen to text changes for send button color
    _queryController.addListener(() {
      setState(() {
        _hasText = _queryController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _initAudioRecorder() async {
    try {
      _audioRecorder = FlutterSoundRecorder();
      
      // Request microphone permission upfront
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        print('❌ Microphone permission not granted');
        return;
      }
      
      // Open the audio session
      await _audioRecorder!.openRecorder();
      
      // Check if recorder is properly initialized
      if (_audioRecorder!.isStopped) {
        print('✅ Audio recorder initialized successfully');
      } else {
        print('⚠️ Audio recorder initialization issue');
      }
    } catch (e) {
      print('❌ Failed to initialize audio recorder: $e');
    }
  }

  // Audio recording methods
  Future<void> _startRecording() async {
    try {
      // Double-check microphone permission
      final permission = await Permission.microphone.status;
      if (permission != PermissionStatus.granted) {
        final newPermission = await Permission.microphone.request();
        if (newPermission != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required to record audio')),
          );
          return;
        }
      }

      // Ensure recorder is ready
      if (_audioRecorder == null || !_audioRecorder!.isStopped) {
        print('⚠️ Audio recorder not ready, reinitializing...');
        await _initAudioRecorder();
        
        // Wait a moment for initialization
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Check if already recording
      if (_audioRecorder!.isRecording) {
        print('⚠️ Already recording');
        return;
      }

      // Get temporary directory for audio file
      final directory = await getTemporaryDirectory();
      final fileName = 'washing_machine_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      _audioPath = '${directory.path}/$fileName';

      print('🎙️ Starting recording to: $_audioPath');
      print('📊 Recorder state before start: ${_audioRecorder!.recorderState}');

      // Start recording in WAV format for orchestrator compatibility
      await _audioRecorder!.startRecorder(
        toFile: _audioPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1, // Mono recording
      );

      // Verify recording started
      await Future.delayed(const Duration(milliseconds: 100));
      print('📊 Recorder state after start: ${_audioRecorder!.recorderState}');
      print('🎙️ Is recording: ${_audioRecorder!.isRecording}');

      setState(() {
        _isRecording = true;
      });

      print('🎙️ Started recording audio to: $_audioPath');
    } catch (e) {
      print('❌ Failed to start recording: $e');
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: ${e.toString()}')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      print('🛑 Stopping recording...');
      print('📊 Recorder state before stop: ${_audioRecorder!.recorderState}');
      print('🎙️ Is recording: ${_audioRecorder!.isRecording}');

      if (!_audioRecorder!.isRecording) {
        print('⚠️ Not currently recording');
        setState(() {
          _isRecording = false;
        });
        return;
      }

      // Stop recording
      final String? recordedFilePath = await _audioRecorder!.stopRecorder();
      print('🛑 Stop recorder returned path: $recordedFilePath');
      
      setState(() {
        _isRecording = false;
      });

      // Wait a moment for file system to finish writing
      await Future.delayed(const Duration(milliseconds: 500));

      if (_audioPath != null) {
        final audioFile = File(_audioPath!);
        final fileExists = await audioFile.exists();
        print('📁 File exists: $fileExists at $_audioPath');
        
        if (fileExists) {
          final fileSize = await audioFile.length();
          print('📊 Audio file size: $fileSize bytes');
          
          if (fileSize > 44) { // More than just WAV header
            setState(() {
              _attachedFiles.add(audioFile);
            });

            print('✅ Audio recording completed successfully');
          } else {
            print('❌ Audio file is too small (${fileSize} bytes) - likely empty');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recording failed - audio file is empty. Please try again.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          throw Exception('Recording failed - no audio file created');
        }
      } else {
        throw Exception('Recording failed - no audio path specified');
      }
    } catch (e) {
      print('❌ Failed to stop recording: $e');
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() async {
    // Clean up audio recorder properly
    try {
      if (_audioRecorder != null) {
        if (_audioRecorder!.isRecording) {
          await _audioRecorder!.stopRecorder();
        }
        await _audioRecorder!.closeRecorder();
      }
    } catch (e) {
      print('❌ Error disposing audio recorder: $e');
    }
    
    // Clean up text controller and scroll controller
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}