import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/teacher_models.dart';
import '../../../providers/teacher_provider.dart';
import '../widgets/video_review_dialog.dart';

enum _RemarkType {
  omission('Omission', Colors.red),
  repetition('Repetition', Color(0xFF8B5CF6)),
  selfCorrection('Self Correction', Color(0xFF10B981)),
  mispronunciation('Mispronunciation', Color(0xFFF97316));

  const _RemarkType(this.label, this.color);

  final String label;
  final Color color;
}

class EvaluationDetailPopup extends StatefulWidget {
  final StudentProgress student;
  final EvaluationMetrics eval;
  final String storyTitle;
  final ReadingSubmissionReview? submission;

  const EvaluationDetailPopup({
    super.key,
    required this.student,
    required this.eval,
    required this.storyTitle,
    this.submission,
  });

  @override
  State<EvaluationDetailPopup> createState() => _EvaluationDetailPopupState();
}

class _EvaluationDetailPopupState extends State<EvaluationDetailPopup> {
  final Map<_RemarkType, Set<int>> _remarkIndexes = {
    for (final type in _RemarkType.values) type: <int>{},
  };
  final TextEditingController _feedbackController = TextEditingController();
  _RemarkType? _activeType;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _feedbackController.text = widget.eval.feedback;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  List<String> get _transcriptWords {
    final transcript = widget.submission?.rawTranscript.trim() ?? '';
    if (transcript.isEmpty) return const [];
    return transcript.split(RegExp(r'\s+'));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 750;

    return Center(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              width: isMobile ? double.infinity : 1080,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              padding: EdgeInsets.all(isMobile ? 20 : 30),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context, isMobile),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 14),
                  Expanded(
                    child: SingleChildScrollView(
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _content(context, true),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: _buildLeftColumn(context, false),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: _buildMainColumn(context, false),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, bool isMobile) {
    return [
      _buildLeftColumn(context, isMobile),
      const SizedBox(height: 18),
      ..._buildMainColumn(context, isMobile),
    ];
  }

  List<Widget> _buildMainColumn(BuildContext context, bool isMobile) {
    return [
      _buildRemarkSelector(isMobile),
      const SizedBox(height: 16),
      _buildTextColumns(isMobile),
      const SizedBox(height: 16),
      _buildFeedbackArea(),
      const SizedBox(height: 16),
      _buildSendButton(context),
    ];
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Oral Reading Evaluation Report - ${widget.storyTitle}',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 15 : 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildLeftColumn(BuildContext context, bool isMobile) {
    final image = widget.student.avatarUrl.isEmpty
        ? Image.asset('lib/assets/student_avatar.png', fit: BoxFit.cover)
        : Image.network(
            widget.student.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Image.asset('lib/assets/student_avatar.png', fit: BoxFit.cover),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: isMobile ? 180 : 220,
            height: isMobile ? 140 : 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF60A5FA), width: 3.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: image,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          widget.student.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.student.grade} • ${widget.student.section}',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: widget.submission?.videoUrl.isNotEmpty == true
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) => VideoReviewDialog(
                      videoUrl: widget.submission!.videoUrl,
                      title: widget.submission!.bookTitle,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('Review Video'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildSubmissionSummary(),
      ],
    );
  }

  Widget _buildSubmissionSummary() {
    final selectedSubmission = widget.submission;
    final accuracy = selectedSubmission?.readingAccuracy == null
        ? 'Pending'
        : '${(selectedSubmission!.readingAccuracy! * 100).round()}%';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryText('Submitted', selectedSubmission?.submittedAtLabel ?? ''),
          _summaryText('Accuracy', accuracy),
          _summaryText(
            'Quiz',
            selectedSubmission == null
                ? 'N/A'
                : '${selectedSubmission.quizScore}/${selectedSubmission.quizTotal}',
          ),
        ],
      ),
    );
  }

  Widget _summaryText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: ${value.isEmpty ? 'N/A' : value}',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRemarkSelector(bool isMobile) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _RemarkType.values.map((type) {
        final selected = _activeType == type;
        final count = _remarkIndexes[type]!.length;
        return InkWell(
          onTap: () {
            setState(() {
              _activeType = selected ? null : type;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: isMobile ? null : 170,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? type.color : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: type.color, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: selected ? Colors.white : type.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    color: selected ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextColumns(bool isMobile) {
    final transcript = _buildTranscriptBox(isMobile);
    final passage = _buildPassageBox(isMobile);
    if (isMobile) {
      return Column(
        children: [transcript, const SizedBox(height: 14), passage],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: transcript),
        const SizedBox(width: 16),
        Expanded(child: passage),
      ],
    );
  }

  Widget _buildTranscriptBox(bool isMobile) {
    final words = _transcriptWords;
    return _buildTextContainer(
      title: 'Transcribed Text',
      child: words.isEmpty
          ? _emptyText('Transcript is not available yet.')
          : Wrap(
              spacing: 6,
              runSpacing: 8,
              children: words.asMap().entries.map((entry) {
                final type = _typeForIndex(entry.key);
                return InkWell(
                  onTap: _activeType == null
                      ? null
                      : () {
                          setState(() {
                            final selected = _remarkIndexes[_activeType!]!;
                            if (selected.contains(entry.key)) {
                              selected.remove(entry.key);
                            } else {
                              selected.add(entry.key);
                            }
                          });
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: type == null
                          ? Colors.transparent
                          : type.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: type?.color ?? Colors.transparent,
                        width: type == null ? 0 : 1.2,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: GoogleFonts.outfit(
                        color: type?.color ?? Colors.black87,
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: type == null
                            ? FontWeight.w600
                            : FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildPassageBox(bool isMobile) {
    final passage = widget.submission?.passageText.trim() ?? '';
    return _buildTextContainer(
      title: 'Actual Passage Text',
      child: passage.isEmpty
          ? _emptyText('Actual passage text is not available.')
          : Text(
              passage,
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
    );
  }

  Widget _buildTextContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _emptyText(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.black54,
        fontSize: 13,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildFeedbackArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextField(
        controller: _feedbackController,
        maxLines: 5,
        decoration: const InputDecoration(
          labelText: 'Teacher Feedback',
          hintText: 'Enter feedback for the student...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: _isSending ? null : () => _sendFeedback(context),
        icon: _isSending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        label: const Text('Send'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF60A5FA),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
      ),
    );
  }

  Future<void> _sendFeedback(BuildContext context) async {
    final selectedSubmission = widget.submission;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (selectedSubmission == null) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('No selected reading submission was found.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    final error = await context
        .read<TeacherProvider>()
        .sendFeedbackForSubmission(
          submission: selectedSubmission,
          studentId: widget.student.id,
          feedback: _composeFeedback(),
        );
    if (!mounted) return;
    setState(() => _isSending = false);

    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text('Feedback successfully sent to ${widget.student.name}.'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
    navigator.pop();
  }

  String _composeFeedback() {
    return jsonEncode({
      'format': 'readbloom_teacher_review_v1',
      'feedback': _feedbackController.text.trim(),
      'transcript': widget.submission?.rawTranscript ?? '',
      'passage': widget.submission?.passageText ?? '',
      'remarks': {
        for (final type in _RemarkType.values)
          type.name: {
            'label': type.label,
            'count': _remarkIndexes[type]!.length,
            'indexes': (_remarkIndexes[type]!.toList()..sort()),
            'words': _wordsForType(type),
          },
      },
    });
  }

  List<String> _wordsForType(_RemarkType type) {
    final words = _transcriptWords;
    final indexes = _remarkIndexes[type]!.toList()..sort();
    return indexes
        .where((index) => index >= 0 && index < words.length)
        .map((index) => words[index])
        .toList();
  }

  _RemarkType? _typeForIndex(int index) {
    for (final type in _RemarkType.values) {
      if (_remarkIndexes[type]!.contains(index)) return type;
    }
    return null;
  }
}
