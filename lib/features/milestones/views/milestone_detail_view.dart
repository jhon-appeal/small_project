import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/milestone_detail_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../photos/services/photo_service.dart';

class MilestoneDetailView extends StatefulWidget {
  final String projectId;
  final String milestoneId;

  const MilestoneDetailView({
    super.key,
    required this.projectId,
    required this.milestoneId,
  });

  @override
  State<MilestoneDetailView> createState() => _MilestoneDetailViewState();
}

class _MilestoneDetailViewState extends State<MilestoneDetailView> {
  final ImagePicker _picker = ImagePicker();
  final PhotoService _photoService = PhotoService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MilestoneDetailViewModel>().loadMilestone(widget.milestoneId);
    });
  }

  Future<void> _pickAndUploadImage() async {
    final viewModel = context.read<MilestoneDetailViewModel>();
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final success = await viewModel.uploadPhoto(
          widget.projectId,
          widget.milestoneId,
          image.path,
          null,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Failed to upload photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final viewModel = context.read<MilestoneDetailViewModel>();
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final success = await viewModel.uploadPhoto(
          widget.projectId,
          widget.milestoneId,
          image.path,
          null,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Failed to upload photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Milestone Details'),
        ),
        body: Consumer<MilestoneDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.milestone == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null && viewModel.milestone == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.clearError();
                        viewModel.loadMilestone(widget.milestoneId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final milestone = viewModel.milestone;
            if (milestone == null) {
              return const Center(child: Text('Milestone not found'));
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.loadMilestone(widget.milestoneId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Milestone Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              milestone.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (milestone.description != null) ...[
                              const SizedBox(height: 8),
                              Text(milestone.description!),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text(
                                  'Status: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Chip(
                                  label: Text(
                                    milestone.status
                                        .replaceAll('_', ' ')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor:
                                      AppTheme.getStatusColor(milestone.status.toLowerCase()),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ],
                            ),
                            if (milestone.dueDate != null) ...[
                              const SizedBox(height: 8),
                              Text('Due Date: ${_formatDate(milestone.dueDate!)}'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Photos Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress Photos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_photo_alternate),
                          onPressed: _showImageSourceDialog,
                          tooltip: 'Add Photo',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (viewModel.photos.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('No photos yet. Tap + to add one.'),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: viewModel.photos.length,
                        itemBuilder: (context, index) {
                          final photo = viewModel.photos[index];
                          final photoUrl = _photoService.getPhotoUrl(
                            photo.storagePath,
                          );
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: photoUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                                if (photo.description != null)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black54,
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        photo.description!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

