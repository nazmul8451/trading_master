import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../model/journal_model.dart';
import '../../service/journal_storage_service.dart';
import '../../service/ad_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final JournalModel? existingNote;
  final String? folderId;

  const NoteEditorScreen({super.key, this.existingNote, this.folderId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _storageService = JournalStorageService();
  bool _isAutoSaving = false;
  final FocusNode _contentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title ?? '';
      _contentController.text =
          widget.existingNote!.content ?? widget.existingNote!.note;
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty)
      return;

    setState(() => _isAutoSaving = true);

    final note = JournalModel(
      id:
          widget.existingNote?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      emotion: widget.existingNote?.emotion ?? 'Calm',
      note: _contentController.text.length > 50
          ? _contentController.text.substring(0, 50)
          : _contentController.text,
      content: _contentController.text,
      title: _titleController.text.isEmpty
          ? 'Untitled Note'
          : _titleController.text,
      type: 'custom',
      folderId: widget.folderId ?? widget.existingNote?.folderId,
    );

    if (widget.existingNote != null) {
      await _storageService.deleteJournal(widget.existingNote!.id);
    }
    await _storageService.saveJournal(note);

    if (mounted) {
      setState(() => _isAutoSaving = false);
    }
  }

  void _insertFormat(String prefix, [String suffix = '']) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final selectedText = selection.textInside(text);
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            selection.start +
            prefix.length +
            selectedText.length +
            suffix.length,
      ),
    );
    _contentFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textMain,
            size: 20.sp,
          ),
          onPressed: () async {
            await _saveNote();
            AdService().showInterstitialAd();
            if (mounted) Navigator.pop(context, true);
          },
        ),
        actions: [
          if (_isAutoSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                await _saveNote();
                AdService().showInterstitialAd();
                if (mounted) Navigator.pop(context, true);
              },
              child: Text(
                'Done',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: AppTypography.heading.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Note Title',
                      hintStyle: TextStyle(
                        color: AppColors.textBody.withOpacity(0.2),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                  Text(
                    DateFormat('MMMM dd, hh:mm a').format(DateTime.now()),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textBody.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _contentController,
                    focusNode: _contentFocus,
                    style: AppTypography.body.copyWith(
                      fontSize: 16.sp,
                      height: 1.6,
                      color: AppColors.textMain.withOpacity(0.9),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing your notes...',
                      hintStyle: TextStyle(
                        color: AppColors.textBody.withOpacity(0.2),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ),
          _buildFormattingToolbar(),
        ],
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _buildToolbarIcon(
            Icons.format_underlined_rounded,
            () => _insertFormat('_', '_'),
          ),
          _buildToolbarIcon(
            Icons.format_list_bulleted_rounded,
            () => _insertFormat('\n• '),
          ),
          _buildToolbarIcon(
            Icons.format_bold_rounded,
            () => _insertFormat('**', '**'),
          ),
          _buildToolbarIcon(
            Icons.format_italic_rounded,
            () => _insertFormat('*', '*'),
          ),
          const Spacer(),
          _buildToolbarIcon(
            Icons.keyboard_hide_rounded,
            () => _contentFocus.unfocus(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: AppColors.textMain.withOpacity(0.7), size: 22.sp),
      onPressed: onTap,
    );
  }
}
