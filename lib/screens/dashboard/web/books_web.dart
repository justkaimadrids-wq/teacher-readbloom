import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/teacher_provider.dart';
import '../../../models/teacher_models.dart';
import '../../../widgets/loading_dialog.dart';

class BooksWebBody extends StatefulWidget {
  const BooksWebBody({super.key});

  @override
  State<BooksWebBody> createState() => _BooksWebBodyState();
}

class _BooksWebBodyState extends State<BooksWebBody> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _questionDrafts = List.generate(3, (_) => _QuestionDraftControllers());
  String _selectedGrade = 'Grade 4';
  String _selectedSection = 'Section A';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (final draft in _questionDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _showAddBookDialog(BuildContext context) {
    final prov = context.read<TeacherProvider>();
    final sectionChoices = _sectionChoicesFor(prov);
    _titleController.clear();
    _contentController.clear();
    for (final draft in _questionDrafts) {
      draft.clear();
    }
    _selectedGrade = sectionChoices.first.grade;
    _selectedSection = sectionChoices.first.section;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      width: 600,
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).viewInsets.bottom -
                            64,
                      ),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Add New Book',
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Fill in the details below to publish a new book for students.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title Field
                              Text(
                                'Book Title',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _titleController,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Enter book title...',
                                  hintStyle: const TextStyle(
                                    color: Colors.black38,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Grade & Section Selection Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Grade Level',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedGrade,
                                              dropdownColor: const Color(
                                                0xFF1E293B,
                                              ),
                                              icon: const Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.white70,
                                              ),
                                              isExpanded: true,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              onChanged: (newValue) {
                                                setDialogState(() {
                                                  _selectedGrade = newValue!;
                                                  _selectedSection =
                                                      sectionChoices
                                                          .firstWhere(
                                                            (choice) =>
                                                                choice.grade ==
                                                                _selectedGrade,
                                                          )
                                                          .section;
                                                });
                                              },
                                              items: sectionChoices
                                                  .map((choice) => choice.grade)
                                                  .toSet()
                                                  .map<
                                                    DropdownMenuItem<String>
                                                  >((String value) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  })
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Section',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedSection,
                                              dropdownColor: const Color(
                                                0xFF1E293B,
                                              ),
                                              icon: const Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.white70,
                                              ),
                                              isExpanded: true,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              onChanged: (newValue) {
                                                setDialogState(() {
                                                  _selectedSection = newValue!;
                                                });
                                              },
                                              items: sectionChoices
                                                  .where(
                                                    (choice) =>
                                                        choice.grade ==
                                                        _selectedGrade,
                                                  )
                                                  .map<
                                                    DropdownMenuItem<String>
                                                  >((choice) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: choice.section,
                                                      child: Text(
                                                        choice.section,
                                                      ),
                                                    );
                                                  })
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Content Field
                              Text(
                                'Book Content (Paste full texts)',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _contentController,
                                maxLines: 8,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText:
                                      'Paste the book/story content here...',
                                  hintStyle: const TextStyle(
                                    color: Colors.black38,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter book content';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ...List.generate(
                                _questionDrafts.length,
                                (index) => _buildQuestionFields(
                                  setDialogState,
                                  _questionDrafts[index],
                                  index,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: prov.isBooksLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            final navigator = Navigator.of(
                                              context,
                                            );
                                            final error =
                                                await runWithLoadingDialog(
                                                  context,
                                                  () => context
                                                      .read<TeacherProvider>()
                                                      .addBook(
                                                        title: _titleController
                                                            .text,
                                                        grade: _selectedGrade,
                                                        section:
                                                            _selectedSection,
                                                        content:
                                                            _contentController
                                                                .text,
                                                        questions:
                                                            _questionDrafts
                                                                .map(
                                                                  (
                                                                    draft,
                                                                  ) => draft
                                                                      .toInput(),
                                                                )
                                                                .toList(),
                                                      ),
                                                  message: 'Saving book...',
                                                );
                                            if (error != null) {
                                              messenger.showSnackBar(
                                                SnackBar(content: Text(error)),
                                              );
                                              return;
                                            }
                                            navigator.pop();
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Book added successfully!',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF60A5FA),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: prov.isBooksLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Publish Book',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<_SectionChoice> _sectionChoicesFor(TeacherProvider prov) {
    final choices = prov.assignedSections
        .map(_SectionChoice.fromLabel)
        .whereType<_SectionChoice>()
        .toList();
    if (choices.isEmpty) {
      return const [
        _SectionChoice('Grade 4', 'Section A'),
        _SectionChoice('Grade 4', 'Section B'),
      ];
    }
    return choices;
  }

  Widget _buildQuestionFields(
    StateSetter setDialogState,
    _QuestionDraftControllers draft,
    int questionIndex,
  ) {
    final isRequired = questionIndex == 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRequired
                ? 'Quiz Question ${questionIndex + 1}'
                : 'Quiz Question ${questionIndex + 1} (optional)',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: draft.questionController,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Enter the quiz question...',
              hintStyle: const TextStyle(color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return 'Please enter at least one quiz question';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (optionIndex) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: optionIndex == 3 ? 0 : 10),
                  child: TextFormField(
                    controller: draft.optionControllers[optionIndex],
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            draft.correctOptionIndex = optionIndex;
                          });
                        },
                        icon: Icon(
                          draft.correctOptionIndex == optionIndex
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: const Color(0xFF60A5FA),
                        ),
                      ),
                      hintText: 'Option ${optionIndex + 1}',
                      hintStyle: const TextStyle(color: Colors.black38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    validator: (value) {
                      if (isRequired &&
                          optionIndex < 2 &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showBookContentDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (BuildContext context) {
        return Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  width: 600,
                  constraints: const BoxConstraints(maxHeight: 500),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${book.grade} • ${book.section}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, thickness: 1),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            book.content,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TeacherProvider>();

    // Sort books by grade, then by section, then by title
    final sortedBooks = List<Book>.from(prov.books)
      ..sort((a, b) {
        int gradeComp = a.grade.compareTo(b.grade);
        if (gradeComp != 0) return gradeComp;
        int sectComp = a.section.compareTo(b.section);
        if (sectComp != 0) return sectComp;
        return a.title.compareTo(b.title);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Glassmorphic Header
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              height: 85,
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Books Library',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBookDialog(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Add New Book',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF60A5FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Scrollable Table list
        Expanded(
          child: SafeArea(
            child: sortedBooks.isEmpty
                ? Center(
                    child: Text(
                      'No books available yet.',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(28.0),
                    itemCount: sortedBooks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final book = sortedBooks[index];
                      return InkWell(
                        onTap: () => _showBookContentDialog(context, book),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF60A5FA,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF60A5FA,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_book,
                                  color: Color(0xFF60A5FA),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  // Grade badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      book.grade,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Section badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFBBF24,
                                      ).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFBBF24,
                                        ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      book.section,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFBBF24),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _SectionChoice {
  final String grade;
  final String section;

  const _SectionChoice(this.grade, this.section);

  static _SectionChoice? fromLabel(String label) {
    final parts = label.split(' - ');
    if (parts.length < 2) return null;
    return _SectionChoice(parts.first.trim(), parts.sublist(1).join(' - '));
  }
}

class _QuestionDraftControllers {
  final questionController = TextEditingController();
  final optionControllers = List.generate(4, (_) => TextEditingController());
  int correctOptionIndex = 0;

  void clear() {
    questionController.clear();
    for (final controller in optionControllers) {
      controller.clear();
    }
    correctOptionIndex = 0;
  }

  void dispose() {
    questionController.dispose();
    for (final controller in optionControllers) {
      controller.dispose();
    }
  }

  BookQuestionInput toInput() {
    return BookQuestionInput(
      questionText: questionController.text,
      options: optionControllers.map((controller) => controller.text).toList(),
      correctOptionIndex: correctOptionIndex,
    );
  }
}
