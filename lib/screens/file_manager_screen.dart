import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  List<FileItem> _allFiles = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  // تحميل الملفات من التخزين المحلي
  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('file_manager_data');
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        setState(() {
          _allFiles = jsonList.map((e) => FileItem.fromJson(e)).toList();
        });
      } catch (e) {
        // تجاهل إذا كان هناك خطأ في البيانات
      }
    }
  }

  // حفظ الملفات إلى التخزين المحلي
  Future<void> _saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _allFiles.map((e) => e.toJson()).toList();
    await prefs.setString('file_manager_data', json.encode(jsonList));
  }

  // اختيار ملفات جديدة
  Future<void> _pickFiles() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = 'صلاحية الوصول إلى الملفات مرفوضة.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var file in result.files) {
            _allFiles.add(FileItem(
              name: file.name,
              path: file.path ?? '',
              size: file.size ?? 0,
              extension: file.extension ?? '',
              isHidden: false, // الملفات الجديدة مرئية افتراضيًا
            ));
          }
        });
        await _saveFiles();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل فتح مستعرض الملفات. حاول مرة أخرى.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // حذف ملف واحد
  Future<void> _removeFile(int index) async {
    setState(() {
      _allFiles.removeAt(index);
    });
    await _saveFiles();
  }

  // تبديل حالة الإخفاء لملف معين
  Future<void> _toggleVisibility(int index) async {
    setState(() {
      _allFiles[index].isHidden = !_allFiles[index].isHidden;
    });
    await _saveFiles();
  }

  // مسح جميع الملفات
  Future<void> _clearAllFiles() async {
    setState(() {
      _allFiles.clear();
    });
    await _saveFiles();
  }

  // فتح الصورة في وضع ملء الشاشة
  void _openImagePreview(String imagePath, String imageName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              imageName,
              style: GoogleFonts.ibmPlexSansArabic(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'تعذر تحميل الصورة',
                        style: GoogleFonts.ibmPlexSansArabic(color: Colors.white54),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // تصنيف نوع الملف للترويسة
  FileCategory _getFileCategory(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return FileCategory.image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return FileCategory.video;
      case 'apk':
        return FileCategory.app;
      default:
        return FileCategory.other;
    }
  }

  // أيقونة تمثل نوع الملف
  IconData _getFileIcon(String? extension) {
    switch (_getFileCategory(extension)) {
      case FileCategory.image:
        return Icons.image;
      case FileCategory.video:
        return Icons.videocam;
      case FileCategory.app:
        return Icons.android;
      case FileCategory.other:
        switch (extension?.toLowerCase()) {
          case 'pdf':
            return Icons.picture_as_pdf;
          case 'zip':
          case 'rar':
          case '7z':
            return Icons.folder_zip;
          case 'doc':
          case 'docx':
            return Icons.description;
          default:
            return Icons.insert_drive_file;
        }
    }
  }

  // تنسيق حجم الملف
  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'غير معروف';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // بناء المجموعات المصنفة
  List<FileGroup> _buildGroups() {
    Map<FileCategory, List<FileItem>> grouped = {};
    for (var file in _allFiles) {
      final cat = _getFileCategory(file.extension);
      grouped.putIfAbsent(cat, () => []);
      grouped[cat]!.add(file);
    }
    List<FileGroup> groups = [];
    for (var entry in grouped.entries) {
      // ترتيب الملفات داخل المجموعة تنازليًا حسب الحجم
      entry.value.sort((a, b) => (b.size ?? 0).compareTo(a.size ?? 0));
      int totalSize = entry.value.fold(0, (sum, file) => sum + (file.size ?? 0));
      groups.add(FileGroup(category: entry.key, files: entry.value, totalSize: totalSize));
    }
    // ترتيب المجموعات تنازليًا حسب الحجم الإجمالي
    groups.sort((a, b) => b.totalSize.compareTo(a.totalSize));
    return groups;
  }

  String _groupTitle(FileCategory category) {
    switch (category) {
      case FileCategory.image:
        return 'الصور';
      case FileCategory.video:
        return 'الفيديوهات';
      case FileCategory.app:
        return 'التطبيقات';
      case FileCategory.other:
        return 'ملفات أخرى';
    }
  }

  IconData _groupIcon(FileCategory category) {
    switch (category) {
      case FileCategory.image:
        return Icons.image;
      case FileCategory.video:
        return Icons.videocam;
      case FileCategory.app:
        return Icons.android;
      case FileCategory.other:
        return Icons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groups = _buildGroups();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'مدير الملفات المرجعي',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          if (_allFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'مسح الكل',
              onPressed: _clearAllFiles,
            ),
        ],
      ),
      body: _allFiles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 64,
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'مدير الملفات المرجعي',
                      style: GoogleFonts.ibmPlexSansArabic(
                        textStyle: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اختر ملفات من جهازك دون نسخها.\nستكون جاهزة للمشاركة عبر الروابط الحية.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSansArabic(
                        textStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _pickFiles,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.folder_open, size: 18),
                      label: Text(
                        'اختيار ملفات',
                        style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53E3E).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Color(0xFFE53E3E), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    color: const Color(0xFFE53E3E),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groups.length + 1,
                    itemBuilder: (context, groupIndex) {
                      if (groupIndex == groups.length) {
                        // زر إضافة المزيد
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _pickFiles,
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              'إضافة المزيد من الملفات',
                              style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        );
                      }
                      final group = groups[groupIndex];
                      return Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          leading: Icon(_groupIcon(group.category), color: colorScheme.primary),
                          title: Text(
                            _groupTitle(group.category),
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            '${group.files.length} ملفات - ${_formatFileSize(group.totalSize)}',
                            style: GoogleFonts.ibmPlexSansArabic(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                          children: group.files.map((file) {
                            // إيجاد index الأصلي في القائمة الإجمالية
                            final originalIndex = _allFiles.indexOf(file);
                            final bool isImage = _getFileCategory(file.extension) == FileCategory.image;
                            
                            return ListTile(
                              leading: Icon(
                                _getFileIcon(file.extension),
                                color: colorScheme.primary,
                                size: 28,
                              ),
                              title: Text(
                                file.name,
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    _formatFileSize(file.size),
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (file.isHidden) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'مخفية',
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        color: const Color(0xFFE53E3E),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      file.isHidden ? Icons.visibility_off : Icons.visibility,
                                      size: 20,
                                      color: file.isHidden ? const Color(0xFFE53E3E) : colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      _toggleVisibility(originalIndex);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    color: const Color(0xFFE53E3E),
                                    onPressed: () => _removeFile(originalIndex),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (isImage && file.path.isNotEmpty) {
                                  _openImagePreview(file.path, file.name);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// نماذج البيانات (Models)
enum FileCategory { image, video, app, other }

class FileItem {
  final String name;
  final String path;
  final int? size;
  final String? extension;
  bool isHidden;

  FileItem({
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
    required this.isHidden,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'size': size,
        'extension': extension,
        'isHidden': isHidden,
      };

  factory FileItem.fromJson(Map<String, dynamic> json) => FileItem(
        name: json['name'] as String,
        path: json['path'] as String,
        size: json['size'] as int?,
        extension: json['extension'] as String?,
        isHidden: json['isHidden'] as bool,
      );
}

class FileGroup {
  final FileCategory category;
  final List<FileItem> files;
  final int totalSize;

  FileGroup({required this.category, required this.files, required this.totalSize});
}