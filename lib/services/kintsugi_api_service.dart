import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class KintsugiApiService {
  static const String baseUrl = 'https://anvit25-orchestrator-final.hf.space';
  static const String apiEndpoint = '/gradio_api/call/chat_interface';
  
  // Chat history for maintaining conversation context
  static List<List<dynamic>> chatHistory = [];

  /// Send a message to the Kintsugi API
  static Future<ApiResponse> sendMessage({
    required String message,
    List<File>? attachedFiles,
  }) async {
    try {
      // Clean up any corrupted chat history before sending
      _cleanHistory();
      // Prepare multimodal input exactly like cURL docs:
      // {"text":"Describe this image","files":[handle_file('url')]}
      Map<String, dynamic> multimodalInput = {
        'text': message,
        'files': attachedFiles?.map((file) => _encodeFileToBase64(file)).toList() ?? []
      };

      // Prepare request payload exactly matching cURL structure:
      // "data": [multimodal_input, history_array]
      // History should be: [["Hello!", null]] format
      Map<String, dynamic> requestData = {
        'data': [
          multimodalInput,
          chatHistory, // List of [user_message, bot_response] pairs
        ]
      };

      print('🚀 Sending request to Kintsugi API...');
      print('📝 Message: $message');
      print('📁 Files: ${attachedFiles?.length ?? 0}');
      if (attachedFiles != null && attachedFiles.isNotEmpty) {
        for (int i = 0; i < attachedFiles.length; i++) {
          print('� File $i: ${attachedFiles[i].path}');
        }
      }
      print('�📋 Request Data: ${json.encode(requestData).length > 1000 ? json.encode(requestData).substring(0, 1000) + "..." : json.encode(requestData)}');

      // Step 1: Make POST request to initiate processing
      final postResponse = await http.post(
        Uri.parse('$baseUrl$apiEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 15));

      print('📤 POST Response Status: ${postResponse.statusCode}');
      print('📤 POST Response Body: ${postResponse.body}');

      if (postResponse.statusCode != 200) {
        throw ApiException('Failed to initiate request: ${postResponse.statusCode} - ${postResponse.body}');
      }

      // Parse response to get event ID (following cURL awk pattern)
      // The cURL uses: awk -F'"' '{ print $4}' to extract event_id
      // This means split by " and get 4th field
      String? eventId;
      
      final responseBody = postResponse.body.trim();
      
      // Split by quotes and get the 4th element (index 3) like awk does
      final quoteSplit = responseBody.split('"');
      if (quoteSplit.length >= 4) {
        eventId = quoteSplit[3]; // awk $4 = index 3 in 0-based array
      }
      
      // Fallback: try JSON parsing
      if (eventId == null || eventId.isEmpty) {
        try {
          final postResponseData = json.decode(responseBody);
          eventId = postResponseData['event_id'];
        } catch (e) {
          // Last resort: regex for UUID pattern
          final regex = RegExp(r'"([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})"');
          final match = regex.firstMatch(responseBody);
          if (match != null) {
            eventId = match.group(1);
          }
        }
      }
      
      if (eventId == null || eventId.isEmpty) {
        throw ApiException('No event ID received from server. Response: ${postResponse.body}');
      }

      print('🎯 Event ID: $eventId');

      // Step 2: Poll for results using GET request
      final getResponse = await _pollForResults(eventId);
      
      if (getResponse.statusCode != 200) {
        throw ApiException('Failed to get results: ${getResponse.statusCode}');
      }

      // Parse the streaming response (Server-Sent Events format)
      print('📜 Processing streaming response...');
      final getResponseBody = getResponse.body;
      print('📄 Raw response: ${getResponseBody.substring(0, getResponseBody.length.clamp(0, 500))}...');
      
      final responseLines = getResponseBody.split('\n');
      String? aiResponse;
      List<dynamic>? chatbotOutput;

      // Look for "event: complete" or "event: error" followed by the data
      for (int i = 0; i < responseLines.length; i++) {
        final line = responseLines[i].trim();
        
        // Check for error events first
        if (line == 'event: error') {
          if (i + 1 < responseLines.length) {
            final dataLine = responseLines[i + 1].trim();
            if (dataLine.startsWith('data: ')) {
              final errorData = dataLine.substring(6);
              print('❌ API returned error event: $errorData');
              
              // Provide more specific error messages based on common issues
              String errorMessage = 'The AI service encountered an error processing your request.';
              
              if (errorData.contains('null') || errorData.trim().isEmpty) {
                errorMessage = 'The image format or size may not be supported. Please try with a smaller image (under 2MB) or a different format (JPG/PNG).';
              } else if (errorData.toLowerCase().contains('timeout')) {
                errorMessage = 'The request timed out. Please try again with a smaller image.';
              } else if (errorData.toLowerCase().contains('memory')) {
                errorMessage = 'The server is experiencing high load. Please try again in a moment.';
              }
              
              throw ApiException(errorMessage);
            }
          }
          throw ApiException('The AI service returned an error. Please try again with a different image or question.');
        }
        
        // Look for the complete event
        if (line == 'event: complete') {
          // The next line should be the data
          if (i + 1 < responseLines.length) {
            final dataLine = responseLines[i + 1].trim();
            
            if (dataLine.startsWith('data: ')) {
              final dataJson = dataLine.substring(6); // Remove 'data: ' prefix
              try {
                if (dataJson.trim().isEmpty || dataJson == 'null') continue;
                
                // Parse the response array [chatbot_data, multimodal_data]
                final responseArray = json.decode(dataJson) as List;
                print('📊 Parsed complete event with ${responseArray.length} elements');
                
                if (responseArray.isNotEmpty && responseArray[0] != null) {
                  chatbotOutput = responseArray[0] as List;
                  print('✅ Found chatbot output with ${chatbotOutput.length} exchanges');
                  
                  // Extract the latest AI response
                  if (chatbotOutput.isNotEmpty) {
                    final lastExchange = chatbotOutput.last;
                    if (lastExchange is List && lastExchange.length > 1 && lastExchange[1] != null) {
                      aiResponse = lastExchange[1].toString();
                      print('🤖 AI Response extracted: ${aiResponse.substring(0, aiResponse.length.clamp(0, 100))}...');
                    }
                  }
                  break;
                }
              } catch (e) {
                print('⚠️ Failed to parse complete event data: ${dataJson.substring(0, dataJson.length.clamp(0, 100))}..., Error: $e');
                continue;
              }
            }
          }
        }
      }

      // Update chat history with the complete conversation
      if (chatbotOutput != null && chatbotOutput.isNotEmpty) {
        try {
          chatHistory = List<List<dynamic>>.from(
            chatbotOutput.map((item) {
              if (item is List && item.length >= 2) {
                return [item[0]?.toString() ?? '', item[1]?.toString() ?? ''];
              } else if (item is List && item.length == 1) {
                return [item[0]?.toString() ?? '', null];
              } else {
                return [item?.toString() ?? '', null];
              }
            })
          );
          print('📚 Updated chat history with ${chatHistory.length} exchanges');
        } catch (e) {
          print('⚠️ Error updating chat history: $e');
          // Fallback: add current exchange
          if (chatHistory.isEmpty || chatHistory.last[1] != null) {
            chatHistory.add([message, aiResponse]);
          } else {
            chatHistory.last[1] = aiResponse;
          }
        }
      } else {
        // If no chat history, add this exchange
        if (chatHistory.isEmpty || chatHistory.last[1] != null) {
          chatHistory.add([message, aiResponse]);
        } else {
          chatHistory.last[1] = aiResponse;
        }
      }

      // Check if we got a valid response
      if (aiResponse == null || aiResponse.trim().isEmpty) {
        throw ApiException('No valid response received from the API');
      }

      _printHistory(); // Debug output
      print('✅ API Response received: ${aiResponse.substring(0, aiResponse.length.clamp(0, 100))}...');

      return ApiResponse(
        success: true,
        message: aiResponse,
        chatHistory: chatHistory,
      );

    } catch (e) {
      print('❌ API Error: $e');
      
      String errorMessage;
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'The AI took too long to process your image (over 5 minutes). This may be due to:\n• Server overload - try again later\n• Complex image analysis\n• Network issues\n\nTry using a smaller or simpler image, or text-only questions.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network connection error. Please check your internet connection and try again.';
      } else {
        errorMessage = 'Failed to get response from AI. Please try again. Error: ${e.toString()}';
      }
      
      return ApiResponse(
        success: false,
        message: errorMessage,
        error: e.toString(),
        chatHistory: chatHistory,
      );
    }
  }

  /// Poll for results from the API (following cURL -N pattern)
  static Future<http.Response> _pollForResults(String eventId) async {
    try {
      print('🔄 Polling for results with Event ID: $eventId');
      
      // The cURL command uses -N flag for no buffering of streaming response
      final response = await http.get(
        Uri.parse('$baseUrl$apiEndpoint/$eventId'),
        headers: {
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        },
      ).timeout(const Duration(seconds: 300)); // 5 minutes timeout for AI image processing

      print('📥 GET Response Status: ${response.statusCode}');
      print('📥 GET Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('✅ Received streaming response');
        return response;
      } else {
        print('❌ GET request failed: ${response.statusCode} - ${response.body}');
        throw ApiException('Failed to get results: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      print('❌ Polling error: $e');
      rethrow;
    }
  }

  /// Encode file to base64 for API transmission with image compression
  static String _encodeFileToBase64(File file) {
    try {
      print('🔄 Encoding file: ${file.path}');
      final originalBytes = file.readAsBytesSync();
      print('📊 Original file size: ${originalBytes.length} bytes (${(originalBytes.length / 1024 / 1024).toStringAsFixed(2)} MB)');
      
      final fileName = file.path.split('/').last;
      String mimeType = _getMimeType(fileName);
      print('🎯 Original MIME type: $mimeType');
      
      Uint8List processedBytes = originalBytes;
      
      // Process all images to ensure PNG format for API compatibility
      if (mimeType.startsWith('image/')) {
        print('�️ Processing image (${originalBytes.length} bytes) to PNG format...');
        
        try {
          final image = img.decodeImage(originalBytes);
          if (image != null) {
            img.Image processedImage = image;
            
            // Aggressive image compression to ensure file stays under 2MB
            int targetWidth = 400;
            int targetHeight = 400;
            
            // Calculate resize based on aspect ratio
            if (image.width > image.height) {
              targetHeight = (targetWidth * image.height / image.width).round();
            } else {
              targetWidth = (targetHeight * image.width / image.height).round();
            }
            
            // Resize the image
            processedImage = img.copyResize(image, width: targetWidth, height: targetHeight);
            print('📐 Resized image from ${image.width}x${image.height} to ${processedImage.width}x${processedImage.height}');
            
            // Try PNG first with maximum compression
            processedBytes = Uint8List.fromList(img.encodePng(processedImage, level: 9));
            mimeType = 'image/png';
            
            // If too large, progressively reduce size
            int attempts = 0;
            while (processedBytes.length > 1000000 && attempts < 5) { // Keep under 1MB
              attempts++;
              targetWidth = (targetWidth * 0.75).round();
              targetHeight = (targetHeight * 0.75).round();
              
              if (targetWidth < 100 || targetHeight < 100) break;
              
              processedImage = img.copyResize(image, width: targetWidth, height: targetHeight);
              processedBytes = Uint8List.fromList(img.encodePng(processedImage, level: 9));
              
              print('🔄 Attempt $attempts: Resized to ${processedImage.width}x${processedImage.height}, size: ${(processedBytes.length / 1024).toStringAsFixed(1)} KB');
            }
            
            // If PNG still too large, switch to JPEG
            if (processedBytes.length > 1000000) {
              print('🎨 Switching to JPEG compression...');
              int quality = 70;
              processedBytes = Uint8List.fromList(img.encodeJpg(processedImage, quality: quality));
              mimeType = 'image/jpeg';
              
              // Reduce quality until under 1MB
              while (processedBytes.length > 1000000 && quality > 20) {
                quality -= 10;
                processedBytes = Uint8List.fromList(img.encodeJpg(processedImage, quality: quality));
                print('🎨 JPEG quality: $quality%, size: ${(processedBytes.length / 1024).toStringAsFixed(1)} KB');
              }
            }
            
            print('✅ Final image: ${processedImage.width}x${processedImage.height}');
            print('💾 Final size: ${processedBytes.length} bytes (${(processedBytes.length / 1024).toStringAsFixed(1)} KB)');
            print('📉 Reduction: ${((1 - processedBytes.length / originalBytes.length) * 100).toStringAsFixed(1)}%');
            
            // Verify size is acceptable
            if (processedBytes.length > 1500000) {
              throw Exception('Image too large after compression. Please use a smaller image.');
            }
          }
        } catch (processingError) {
          print('❌ Image processing failed: $processingError');
          throw Exception('Failed to process image for API: $processingError. Please try with a different image.');
        }
      } 
      // Process audio files - keep WAV format as required by orchestrator
      else if (mimeType.startsWith('audio/')) {
        print('🎵 Processing audio file (${originalBytes.length} bytes) for orchestrator...');
        
        // For WAV files, keep original format as orchestrator specifically requires WAV
        if (mimeType == 'audio/wav') {
          print('🎶 WAV file detected - keeping original format for orchestrator compatibility');
          processedBytes = originalBytes;
        } else {
          print('⚠️ Non-WAV audio file detected. Orchestrator requires WAV format.');
          // Keep original but warn user
          processedBytes = originalBytes;
        }
        
        print('💾 Audio file size: ${processedBytes.length} bytes');
      }
      
      final base64String = base64Encode(processedBytes);
      final result = 'data:$mimeType;base64,$base64String';
      print('✅ File encoded successfully, data URL length: ${result.length}');
      
      // Warn if still too large
      if (result.length > 2000000) {
        print('⚠️ Warning: Encoded file is very large (${result.length} chars). This might cause API issues.');
      }
      
      return result;
    } catch (e) {
      print('❌ Error encoding file: $e');
      return '';
    }
  }

  /// Get MIME type based on file extension
  static String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'wav':
        return 'audio/wav';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }



  /// Clear chat history
  static void clearHistory() {
    chatHistory.clear();
  }

  /// Get current chat history
  static List<List<dynamic>> getCurrentHistory() {
    return List<List<dynamic>>.from(chatHistory);
  }

  /// Add message to history in correct format: [user_message, bot_response]
  static void _addToHistory(String userMessage, String? botResponse) {
    // Clean up any incomplete or corrupted exchanges
    chatHistory.removeWhere((exchange) {
      return exchange.length < 2 || 
             exchange[1] == null || 
             exchange[1].toString().trim().isEmpty ||
             exchange[0] == null ||
             exchange[0].toString().trim().isEmpty;
    });
    
    // Add new exchange in format expected by API: ["user_msg", "bot_response"]
    if (userMessage.trim().isNotEmpty && botResponse != null && botResponse.trim().isNotEmpty) {
      chatHistory.add([userMessage, botResponse]);
    }
  }

  /// Clean corrupted chat history
  static void _cleanHistory() {
    chatHistory.removeWhere((exchange) {
      return exchange.length < 2 || 
             exchange[1] == null || 
             exchange[1].toString().trim().isEmpty ||
             exchange[0] == null ||
             exchange[0].toString().trim().isEmpty;
    });
    print('🧹 Cleaned chat history, ${chatHistory.length} valid exchanges remaining');
  }

  /// Print current chat history for debugging
  static void _printHistory() {
    print('📚 Current chat history (${chatHistory.length} exchanges):');
    for (int i = 0; i < chatHistory.length; i++) {
      final exchange = chatHistory[i];
      print('  $i: User: "${exchange[0]}" | Bot: "${exchange[1]}"');
    }
  }

  /// Test API connection with a simple message
  static Future<bool> testConnection() async {
    try {
      print('🧪 Testing API connection...');
      
      final response = await sendMessage(message: 'Hello, can you help me?');
      
      if (response.success && response.message.isNotEmpty) {
        print('✅ API connection test successful');
        return true;
      } else {
        print('❌ API test failed: ${response.error}');
        return false;
      }
    } catch (e) {
      print('❌ API test error: $e');
      return false;
    }
  }
}

/// API Response model
class ApiResponse {
  final bool success;
  final String message;
  final String? error;
  final List<List<dynamic>> chatHistory;

  ApiResponse({
    required this.success,
    required this.message,
    this.error,
    required this.chatHistory,
  });

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: ${message.substring(0, message.length.clamp(0, 50))}..., error: $error}';
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}
