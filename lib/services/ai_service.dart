import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  String? _apiKey;

  Future<void> _initApiKey() async {
    if (_apiKey != null) return;
    
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key');
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', apiKey);
    _apiKey = apiKey;
  }

  Future<bool> hasApiKey() async {
    await _initApiKey();
    return _apiKey != null && _apiKey!.isNotEmpty;
  }

  GenerativeModel _getModel({bool forSummary = true}) {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not set. Please set your Gemini API key in the settings.');
    }
    
    // CẢNH BÁO TIỀM ẨN: Model 'gemini-2.0-flash' có thể không tồn tại hoặc thay đổi trong tương lai
    // Google có thể cập nhật tên model trong API, nên cần kiểm tra định kỳ
    return GenerativeModel(
      model: 'gemini-2.0-flash',  // Sử dụng mô hình gemini-2.0-flash theo yêu cầu
      apiKey: _apiKey!,
      generationConfig: GenerationConfig(
        temperature: forSummary ? 0.5 : 0.2,  // Nhiệt độ thấp hơn cho summary để kết quả nhất quán
        topK: 40,
        topP: forSummary ? 0.95 : 0.9,
        maxOutputTokens: forSummary ? 8192 : 1000,
      ),
    );
  }

  Future<String> generateSummary(String content) async {
    await _initApiKey();
    
    try {
      final model = _getModel(forSummary: true);
      
      // Tạo chat để gửi tin nhắn
      final chat = model.startChat();
      
      // Tạo prompt yêu cầu tóm tắt
      final prompt = 'Generate a concise summary of the provided text, concentrating only on the essential points. Use the same language as the original text for the summary. Do not add any extra explanations or information outside of the summary itself. Format the summary using basic Markdown for clarity and readability. Include LaTeX where necessary for any mathematical or scientific notation. Here is the text to be summarized:\n\n$content';
      final promptContent = Content.text(prompt);
      
      // Gửi yêu cầu và nhận phản hồi
      final response = await chat.sendMessage(promptContent);
      
      if (response.text == null) {
        throw Exception('No response generated from AI model');
      }
      
      return response.text!;
    } catch (e) {
      debugPrint('Error generating summary: $e');
      throw Exception('Error generating summary: $e');
    }
  }

  Future<List<String>> extractKeywords(String content) async {
    await _initApiKey();
    
    try {
      final model = _getModel(forSummary: false);
      
      // Tạo chat để gửi tin nhắn
      final chat = model.startChat();
      
      // Tạo prompt yêu cầu từ khóa
      final prompt = 'Extract 5-7 keywords from the following text. Return only the keywords separated by commas:\n\n$content';
      final promptContent = Content.text(prompt);
      
      // Gửi yêu cầu và nhận phản hồi
      final response = await chat.sendMessage(promptContent);
      
      if (response.text == null) {
        throw Exception('No response generated from AI model');
      }
      
      // Xử lý phản hồi và trích xuất danh sách từ khóa
      return response.text!.split(',').map((e) => e.trim()).toList();
    } catch (e) {
      debugPrint('Error extracting keywords: $e');
      throw Exception('Error extracting keywords: $e');
    }
  }
}
