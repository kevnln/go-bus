import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../models/chat_message.dart';
import '../../services/openai_service.dart';
import '../../widgets/canned_questions_widget.dart';
import '../../widgets/custom_chat_app_bar.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_message_input.dart';
import '../../widgets/support_feedback_widget.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({Key? key}) : super(key: key);

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAIService _openAIService = OpenAIService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showCannedQuestions = false;
  int _characterCount = 0;
  static const int _maxCharacters = 200;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateCharacterCount);
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateCharacterCount);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _messageController.text.length;
    });
  }

  void _initializeChat() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message:
          'Hi! I\'m your AI assistant for GO BUS. I can help you with booking tickets, checking schedules, routes, and answering travel-related questions.\n\n💡 Tip: Tap the help icon (?) below to see suggested questions!',
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.ai,
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String messageText,
      {MessageType type = MessageType.text}) async {
    if (messageText.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: messageText.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      type: type,
      avatar: ImageConstant.imgAvatar,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _showCannedQuestions = false;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Prepare conversation history for context
      final conversationHistory = _messages
          .where((msg) =>
              msg.type == MessageType.text || msg.type == MessageType.ai)
          .take(6)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.message,
              })
          .toList();

      final aiResponse = await _openAIService.sendMessage(
        messageText,
        conversationHistory: conversationHistory,
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.ai,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg:
            "Sorry, I'm having trouble responding right now. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _handleCannedQuestionTap(String question) {
    setState(() {
      _showCannedQuestions = false;
    });
    _sendMessage(question, type: MessageType.canned);
  }

  void _handleFeedback(String messageId, bool isHelpful) {
    final feedbackText = isHelpful
        ? 'Thank you for your feedback!'
        : 'Thanks for the feedback. We\'ll work on improving our responses.';

    Fluttertoast.showToast(
      msg: feedbackText,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Here you could also log the feedback to analytics or a database
    print(
        'Feedback for message $messageId: ${isHelpful ? 'Helpful' : 'Not helpful'}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(96.h),
        child: CustomChatAppBar(
          title: 'AI CHATBOT',
          subtitle: 'Online now',
          profileImage: ImageConstant.imgProfileImage,
          backIcon: ImageConstant.imgIconChevronLeft,
          onBackPressed: () => Navigator.pop(context),
          showSubtitle: true,
          titleColor: appTheme.black_900,
          subtitleColor: appTheme.gray_600,
          backgroundColor: appTheme.whiteCustom,
          borderColor: appTheme.gray_300,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChatMessagesSection(context),
          ),
          if (_showCannedQuestions) _buildCannedQuestionsSection(context),
          _buildMessageInputSection(context),
        ],
      ),
    );
  }

  Widget _buildChatMessagesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 20.h),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isLoading) {
            return _buildLoadingIndicator(context);
          }

          final message = _messages[index];
          return Column(
            children: [
              if (index == 0 || _shouldShowTimestamp(index))
                _buildTimestamp(context, message.timestamp),
              SizedBox(height: index == 0 ? 20.h : 16.h),
              message.isUser
                  ? _buildUserMessage(context, message)
                  : _buildAiMessage(context, message),
              SizedBox(height: 16.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(right: 60.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
        decoration: BoxDecoration(
          color: appTheme.black_900,
          borderRadius: BorderRadius.circular(18.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20.h,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.white_A700),
              ),
            ),
            SizedBox(width: 8.h),
            Text(
              'AI is typing...',
              style: TextStyleHelper.instance.body12RegularInter
                  .copyWith(color: appTheme.white_A700),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;

    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];
    final timeDiff =
        currentMessage.timestamp.difference(previousMessage.timestamp);

    return timeDiff.inMinutes > 5;
  }

  Widget _buildTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    String displayText;
    if (messageDate == today) {
      displayText =
          'Today ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      displayText =
          '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 4.h),
        decoration: BoxDecoration(
          color: appTheme.grey100,
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Text(
          displayText,
          style: TextStyleHelper.instance.body12RegularInter
              .copyWith(color: appTheme.gray_600),
        ),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context, ChatMessage message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (message.avatar != null) ...[
          CustomImageView(
            imagePath: message.avatar!,
            height: 24.h,
            width: 24.h,
            radius: BorderRadius.circular(12.h),
          ),
          SizedBox(width: 8.h),
        ],
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
            decoration: BoxDecoration(
              color: message.type == MessageType.canned
                  ? appTheme.grey100
                  : appTheme.gray_200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.h),
                topRight: Radius.circular(18.h),
                bottomLeft: Radius.circular(4.h),
                bottomRight: Radius.circular(18.h),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.canned)
                  Container(
                    margin: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 14.h,
                          color: appTheme.gray_600,
                        ),
                        SizedBox(width: 4.h),
                        Text(
                          'Suggested Question',
                          style: TextStyleHelper.instance.body12RegularInter
                              .copyWith(color: appTheme.gray_600),
                        ),
                      ],
                    ),
                  ),
                Text(
                  message.message,
                  style: TextStyleHelper.instance.body14RegularInter
                      .copyWith(color: appTheme.black_900),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 32.h),
      ],
    );
  }

  Widget _buildAiMessage(BuildContext context, ChatMessage message) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
                decoration: BoxDecoration(
                  color: appTheme.black_900,
                  borderRadius: BorderRadius.circular(18.h),
                ),
                child: Text(
                  message.message,
                  style: TextStyleHelper.instance.body14RegularInter
                      .copyWith(color: appTheme.white_A700),
                ),
              ),
              if (message.type == MessageType.ai)
                SupportFeedbackWidget(
                  messageId: message.id,
                  onFeedbackTap: _handleFeedback,
                ),
            ],
          ),
        ),
        SizedBox(width: 32.h),
      ],
    );
  }

  Widget _buildCannedQuestionsSection(BuildContext context) {
    return CannedQuestionsWidget(
      categorizedQuestions: _openAIService.getCategorizedQuestions(),
      onQuestionTap: _handleCannedQuestionTap,
      onClose: () => setState(() => _showCannedQuestions = false),
    );
  }

  Widget _buildMessageInputSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        boxShadow: [
          BoxShadow(
            color: appTheme.black_900.withAlpha(13),
            blurRadius: 8.h,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(
                    () => _showCannedQuestions = !_showCannedQuestions),
                child: Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: _showCannedQuestions
                        ? appTheme.gray_600
                        : appTheme.grey100,
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 20.h,
                        color: _showCannedQuestions
                            ? appTheme.white_A700
                            : appTheme.gray_600,
                      ),
                      if (!_showCannedQuestions) ...[
                        SizedBox(width: 4.h),
                        Text(
                          'Quick Questions',
                          style: TextStyleHelper.instance.body12RegularInter
                              .copyWith(color: appTheme.gray_600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: CustomMessageInput(
                  placeholder: "Type your message...",
                  controller: _messageController,
                  onChanged: (text) {
                    // Character limit is handled by the listener
                  },
                  onMicTap: () => _handleVoiceInput(context),
                  keyboardType: TextInputType.text,
                  enabled: !_isLoading,
                ),
              ),
              SizedBox(width: 12.h),
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () => _sendMessage(_messageController.text),
                child: Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: _isLoading || _messageController.text.trim().isEmpty
                        ? appTheme.gray_300
                        : appTheme.gray_600,
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Icon(
                    Icons.send,
                    size: 20.h,
                    color: appTheme.white_A700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showCannedQuestions
                    ? 'Select a question from the categories above'
                    : 'Ask anything about bus travel or tap (?) for quick questions!',
                style: TextStyleHelper.instance.body12RegularInter
                    .copyWith(color: appTheme.gray_600),
              ),
              Text(
                '$_characterCount/$_maxCharacters',
                style: TextStyleHelper.instance.body12RegularInter.copyWith(
                  color: _characterCount > _maxCharacters
                      ? Colors.red
                      : appTheme.gray_600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleVoiceInput(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Voice Input'),
          content: Text(
              'Voice recording feature will be available in the next update. For now, please type your message.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
