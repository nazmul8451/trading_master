import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../model/journal_model.dart';
import '../../service/journal_storage_service.dart';
import 'note_editor_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalStorageService _storageService = JournalStorageService();
  List<JournalModel> _tradingJournals = [];
  List<JournalModel> _personalJournals = [];
  List<JournalFolderModel> _folders = [];
  int _selectedTab = 0; // 0 for Trading, 1 for Personal Notes
  JournalFolderModel? _selectedFolder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulate a small delay for premium feel and to show loader
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (mounted) {
      setState(() {
        _tradingJournals = _storageService.getTradingJournals();
        _folders = _storageService.getAllFolders();
        _personalJournals = _storageService.getAllJournals().where((j) => j.type == 'custom' && j.folderId == null).toList();
        _isLoading = false;
      });
    }
  }

  IconData _getIconForFolderName(String name) {
    String lowerName = name.toLowerCase();
    if (lowerName.contains('money') || lowerName.contains('cash') || lowerName.contains('withdra')) return Icons.payments_outlined;
    if (lowerName.contains('dream') || lowerName.contains('goal') || lowerName.contains('future')) return Icons.auto_awesome_outlined;
    if (lowerName.contains('personal') || lowerName.contains('me') || lowerName.contains('life')) return Icons.person_outline_rounded;
    if (lowerName.contains('trade') || lowerName.contains('market') || lowerName.contains('crypto')) return Icons.query_stats_rounded;
    if (lowerName.contains('psychology') || lowerName.contains('mind') || lowerName.contains('feel')) return Icons.psychology_outlined;
    if (lowerName.contains('plan') || lowerName.contains('todo') || lowerName.contains('list')) return Icons.assignment_outlined;
    return Icons.folder_open_rounded; // Default
  }

  Color _getColorForFolderName(String name) {
    String lowerName = name.toLowerCase();
    if (lowerName.contains('money')) return Colors.greenAccent;
    if (lowerName.contains('dream')) return Colors.purpleAccent;
    if (lowerName.contains('personal')) return Colors.blueAccent;
    if (lowerName.contains('trade')) return AppColors.primary;
    if (lowerName.contains('psychology')) return Colors.orangeAccent;
    return AppColors.primary;
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 24.h),
            _buildOptionTile(
              icon: Icons.create_new_folder_outlined,
              title: 'Create Folder',
              subtitle: 'Organize your notes into smart categories',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog();
              },
            ),
            SizedBox(height: 16.h),
            _buildOptionTile(
              icon: Icons.edit_note_outlined,
              title: 'New Note',
              subtitle: 'Jot down your latest trading ideas or personal thoughts',
              color: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                _navigateToEditor();
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.buttonText.copyWith(fontSize: 15.sp, color: AppColors.textMain)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11.sp, color: AppColors.textBody.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline_rounded, color: color.withOpacity(0.5), size: 18.sp),
          ],
        ),
      ),
    );
  }

  void _navigateToEditor({JournalModel? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          existingNote: note,
          folderId: _selectedFolder?.id,
        ),
      ),
    );
    if (result == true) _loadData();
  }

  void _showCreateFolderDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text('Smart Category', style: AppTypography.heading.copyWith(fontSize: 20.sp)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g., Psychology, Trade Plan, Personal',
            hintStyle: TextStyle(color: AppColors.textBody.withOpacity(0.2)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppColors.textBody))),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final folderName = nameController.text;
                final folder = JournalFolderModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: folderName,
                  colorValue: _getColorForFolderName(folderName).value,
                  iconCode: _getIconForFolderName(folderName).codePoint,
                );
                await _storageService.saveFolder(folder);
                _loadData();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedFolder != null) {
          setState(() => _selectedFolder = null);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              if (_selectedFolder == null) _buildTabSwitcher(),
              Expanded(
                child: _isLoading ? _buildLoadingState() : _buildBody(),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddOptions,
          backgroundColor: AppColors.primary,
          elevation: 6,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('New', style: AppTypography.buttonText.copyWith(fontSize: 14.sp)),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.r,
            height: 40.r,
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Syncing your journals...',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textBody.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 20.h, 20.w, 10.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20.sp),
            onPressed: () {
              if (_selectedFolder != null) {
                setState(() => _selectedFolder = null);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          SizedBox(width: 8.w),
          Text(
            _selectedFolder != null ? _selectedFolder!.name : 'Journals',
            style: AppTypography.heading.copyWith(fontSize: 26.sp),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: AppColors.border)),
            child: Icon(Icons.search_rounded, color: AppColors.textBody, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18.r), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(child: _buildTabItem(0, 'Personal', Icons.auto_stories_rounded)),
          Expanded(child: _buildTabItem(1, 'Trading', Icons.insights_rounded)),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        if (_selectedTab != index) {
          setState(() {
             _selectedTab = index;
             _isLoading = true;
          });
          _loadData();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.textBody, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTypography.buttonText.copyWith(fontSize: 14.sp, color: isSelected ? Colors.white : AppColors.textBody),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedFolder != null) {
      final folderNotes = _storageService.getJournalsByFolder(_selectedFolder!.id);
      if (folderNotes.isEmpty) return _buildEmptyState('No notes in this category yet', Icons.folder_open_rounded);
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: folderNotes.length,
        itemBuilder: (context, index) => _buildJournalCard(folderNotes[index]),
      );
    }
    return _selectedTab == 0 ? _buildPersonalContent() : _buildTradingList();
  }

  Widget _buildTradingList() {
    if (_tradingJournals.isEmpty) return _buildEmptyState('No trading journals recorded', Icons.analytics_outlined);
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _tradingJournals.length,
      itemBuilder: (context, index) {
        final journal = _tradingJournals[index];
        return _buildJournalCard(journal, isTrading: true);
      },
    );
  }

  Widget _buildPersonalContent() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        if (_folders.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CATEGORIES', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.textBody.withOpacity(0.4), fontSize: 9.sp)),
              Text('${_folders.length} Folders', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10.sp)),
            ],
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 16.w, mainAxisSpacing: 16.h, childAspectRatio: 1.6,
            ),
            itemCount: _folders.length,
            itemBuilder: (context, index) => _buildFolderCard(_folders[index]),
          ),
          SizedBox(height: 32.h),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('QUICK NOTES', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.textBody.withOpacity(0.4), fontSize: 9.sp)),
            if (_personalJournals.isNotEmpty) Text('${_personalJournals.length} Notes', style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10.sp)),
          ],
        ),
        SizedBox(height: 16.h),
        if (_personalJournals.isEmpty) _buildEmptyState('Your quick notes will appear here', Icons.history_edu_rounded)
        else ..._personalJournals.map((j) => _buildJournalCard(j)).toList(),
        SizedBox(height: 100.h),
      ],
    );
  }

  Widget _buildFolderCard(JournalFolderModel folder) {
    final count = _storageService.getJournalsByFolder(folder.id).length;
    // Use smart detection in UI for better responsiveness to name changes
    final folderColor = _getColorForFolderName(folder.name);
    final folderIcon = _getIconForFolderName(folder.name);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedFolder = folder),
      onLongPress: () => _showFolderOptions(folder),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: AppColors.border.withOpacity(0.8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: Stack(
            children: [
              // High-end Background Icon positioned at Top-Right
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: folderColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(folderIcon, color: folderColor.withOpacity(0.4), size: 40.sp),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end, // Push text to bottom
                  children: [
                    Text(
                      folder.name, 
                      style: AppTypography.buttonText.copyWith(
                        fontSize: 15.sp, 
                        color: AppColors.textMain, 
                        fontWeight: FontWeight.bold
                      ), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$count notes', 
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textBody.withOpacity(0.5), 
                        fontSize: 10.sp
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFolderOptions(JournalFolderModel folder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 24.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
              ),
              title: Text('Delete Category', style: AppTypography.buttonText.copyWith(color: AppColors.textMain)),
              subtitle: Text('This will permanently delete "${folder.name}" and all notes inside it.', style: AppTypography.bodySmall),
              onTap: () async {
                await _storageService.deleteFolder(folder.id);
                _loadData();
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(JournalModel journal, {bool isTrading = false}) {
    Color accentColor = isTrading ? AppColors.primary : AppColors.success;
    return GestureDetector(
      onTap: () => _navigateToEditor(note: journal),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Text(
                    isTrading ? (journal.title ?? 'Trading Day') : 'Quick Note',
                    style: TextStyle(color: accentColor, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
                Text(DateFormat('MMM dd, yyyy').format(journal.date), style: AppTypography.bodySmall.copyWith(fontSize: 10.sp, color: AppColors.textBody.withOpacity(0.4))),
              ],
            ),
            SizedBox(height: 12.h),
            Text(journal.title ?? 'Untitled Note', style: AppTypography.buttonText.copyWith(fontSize: 17.h, color: AppColors.textMain, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 8.h),
            Text(journal.content ?? journal.note, style: AppTypography.bodySmall.copyWith(color: AppColors.textMain.withOpacity(0.6), height: 1.5, fontSize: 12.sp), maxLines: 3, overflow: TextOverflow.ellipsis),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, size: 14.sp, color: AppColors.textBody.withOpacity(0.5)),
                SizedBox(width: 6.w),
                Text(journal.emotion, style: AppTypography.bodySmall.copyWith(fontSize: 11.sp, color: AppColors.textBody)),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.delete_sweep_outlined, color: AppColors.error.withOpacity(0.4), size: 20.sp),
                  onPressed: () async {
                    await _storageService.deleteJournal(journal.id);
                    _loadData();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border.withOpacity(0.5))),
            child: Icon(icon, size: 40.sp, color: AppColors.textBody.withOpacity(0.15)),
          ),
          SizedBox(height: 16.h),
          Text(message, style: AppTypography.bodySmall.copyWith(color: AppColors.textBody.withOpacity(0.5))),
        ],
      ),
    );
  }
}
