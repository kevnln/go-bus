import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');

  static const int _maxTokens = 150; // Reduced to ensure 200-word limit
  static const double _temperature = 0.7;
  static const double _topP = 0.9;

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception(
          'OPENAI_API_KEY is not configured. Please check your env.json file.');
    }
  }

  Future<String> sendMessage(String message,
      {List<Map<String, String>>? conversationHistory}) async {
    _validateApiKey();

    try {
      final systemPrompt = _getHelpfulSystemPrompt(message);

      final List<Map<String, String>> messages = [
        {'role': 'system', 'content': systemPrompt},
      ];

      if (conversationHistory != null) {
        messages.addAll(conversationHistory.take(8));
      }

      messages.add({
        'role': 'user',
        'content': message,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': _maxTokens,
          'temperature': _temperature,
          'top_p': _topP,
          'presence_penalty': 0.4,
          'frequency_penalty': 0.3,
          'seed': _generateRandomSeed(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String aiResponse =
            data['choices'][0]['message']['content'].trim();

        return _limitTo200Words(aiResponse);
      } else {
        if (kDebugMode) {
          print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        }
        return _getContextualFallback(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('OpenAI Service Error: $e');
      }
      return _getContextualFallback(message);
    }
  }

  int _generateRandomSeed() {
    return Random().nextInt(1000000) +
        DateTime.now().millisecondsSinceEpoch % 1000;
  }

  String _getHelpfulSystemPrompt(String userMessage) {
    final messageType = _categorizeMessage(userMessage);

    final helpfulPrompts = {
      'payment':
          'You are a GO BUS payment specialist. Provide complete payment information under 200 words. List all accepted payment methods: credit cards (Visa, MasterCard, American Express), debit cards, digital wallets (Apple Pay, Google Pay), bank transfers, and cash at stations. Include payment security, processing times, and refund policies. Be comprehensive and practical.',
      'planning':
          'You are a GO BUS trip planning expert. Give step-by-step travel planning guidance under 200 words. Include: 1) Route selection, 2) Schedule checking, 3) Seat selection, 4) Payment options, 5) Confirmation process, 6) Departure preparation. Provide complete planning workflow with specific actionable steps.',
      'booking':
          'You are a GO BUS booking specialist. Provide complete booking process under 200 words. Include: online booking steps, required information, seat selection, payment confirmation, ticket retrieval, and backup options. Give full booking guidance from start to finish.',
      'general':
          'You are a comprehensive GO BUS customer service expert. Answer directly under 200 words. Provide complete information, specific steps, and practical solutions. Never redirect - give full helpful responses immediately. Include relevant details like processes, options, requirements, and next steps.'
    };

    return helpfulPrompts[messageType] ?? helpfulPrompts['general']!;
  }

  String _categorizeMessage(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage
        .contains(RegExp(r'payment|pay|card|money|cost|price|fee|charge'))) {
      return 'payment';
    }
    if (lowerMessage
        .contains(RegExp(r'plan|step|how to|guide|process|planning'))) {
      return 'planning';
    }
    if (lowerMessage.contains(RegExp(r'book|booking|reserve|ticket|seat'))) {
      return 'booking';
    }

    return 'general';
  }

  String _limitTo200Words(String text) {
    final words = text.split(' ');
    if (words.length <= 200) return text;

    return '${words.take(200).join(' ')}...';
  }

  String _getContextualFallback(String message) {
    final messageType = _categorizeMessage(message);

    final contextualFallbacks = {
      'payment':
          "GO BUS accepts multiple payment methods: Credit/Debit cards (Visa, MasterCard, Amex), Digital wallets (Apple Pay, Google Pay, PayPal), Bank transfers, and Cash at select stations. Online payments are secure with instant confirmation. Refunds typically process within 5-7 business days. Group bookings may qualify for wire transfer options.",
      'planning':
          "Plan your GO BUS trip in these steps: 1) Visit our website or app, 2) Enter origin and destination, 3) Select travel dates and preferred times, 4) Choose seat type (standard, premium, or sleeper), 5) Review schedules and prices, 6) Complete booking with payment, 7) Receive confirmation email/SMS, 8) Arrive 30 minutes early at departure station.",
      'booking':
          "To book with GO BUS: 1) Go to gobus.com or mobile app, 2) Enter travel details (from, to, date), 3) Browse available trips and prices, 4) Select seats and add-ons, 5) Enter passenger information, 6) Choose payment method, 7) Review and confirm booking, 8) Save your e-ticket. Customer service available 24/7 for assistance.",
      'general':
          "I'm your GO BUS assistant ready to provide complete information about bookings, schedules, routes, pricing, policies, and travel services. I'll give you direct, comprehensive answers to help with your bus travel needs. What specific information can I provide about GO BUS services?"
    };

    return contextualFallbacks[messageType] ?? contextualFallbacks['general']!;
  }

  List<String> getCannedQuestions() {
    return [
      "How do I book a bus ticket?",
      "What payment methods do you accept?",
      "What are the available routes?",
      "How can I check my booking status?",
      "What is your cancellation policy?",
      "How do I contact customer support?",
      "Are there any discounts available?",
      "How early should I arrive at the bus station?",
      "Can I change my booking date?",
      "How do I get a refund?",
      "What amenities are available on the bus?",
      "Is Wi-Fi available during the journey?"
    ];
  }

  Map<String, List<String>> getCategorizedQuestions() {
    return {
      'Quick Start': [
        "How do I book a bus ticket?",
        "What routes are available today?",
        "Show me ticket prices",
        "Help me plan my journey step by step",
        "What's the fastest way to book?",
        "Guide me through the booking process",
      ],
      'Booking & Payment': [
        "What payment methods do you accept?",
        "Can I book tickets online?",
        "How can I check my booking status?",
        "Can I book for family members?",
        "Is advance booking required?",
        "How do I get my receipt?",
      ],
      'Travel Information': [
        "What are popular routes?",
        "How early should I arrive?",
        "What amenities are available?",
        "Is Wi-Fi available?",
        "Are meals provided?",
        "What's the baggage allowance?",
      ],
      'Changes & Cancellations': [
        "How do I cancel my booking?",
        "Can I change my travel date?",
        "What is your cancellation policy?",
        "How do I get a refund?",
        "Is there a change fee?",
        "What if I miss my bus?",
      ],
      'Discounts & Offers': [
        "Are there current discounts?",
        "Do you offer student discounts?",
        "Is there a senior discount?",
        "Are group bookings discounted?",
        "Any holiday offers?",
        "How do I apply promo codes?",
      ],
      'Support & Safety': [
        "How do I contact support?",
        "What safety measures are in place?",
        "How can I report lost items?",
        "What's the emergency contact?",
        "What COVID protocols do you follow?",
        "What accessibility features are available?",
      ],
    };
  }
}
