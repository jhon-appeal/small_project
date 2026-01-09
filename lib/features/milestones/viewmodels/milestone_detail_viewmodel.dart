import 'package:flutter/foundation.dart';
import '../services/milestone_service.dart';
import '../../../shared/models/milestone_model.dart';
import '../../photos/services/photo_service.dart';
import '../../../shared/models/progress_photo_model.dart';

class MilestoneDetailViewModel extends ChangeNotifier {
  final MilestoneService _milestoneService = MilestoneService();
  final PhotoService _photoService = PhotoService();

  bool _isLoading = false;
  String? _errorMessage;
  MilestoneModel? _milestone;
  List<ProgressPhotoModel> _photos = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MilestoneModel? get milestone => _milestone;
  List<ProgressPhotoModel> get photos => _photos;

  Future<void> loadMilestone(String milestoneId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _milestone = await _milestoneService.getMilestoneById(milestoneId);
      if (_milestone != null) {
        await loadPhotos(milestoneId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load milestone: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPhotos(String milestoneId) async {
    try {
      _photos = await _photoService.getPhotosByMilestone(milestoneId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load photos: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> updateMilestoneStatus(String newStatus) async {
    if (_milestone == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _milestoneService.updateMilestoneStatus(
        _milestone!.id,
        newStatus,
      );
      await loadMilestone(_milestone!.id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadPhoto(
    String projectId,
    String milestoneId,
    String imagePath,
    String? description,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _photoService.uploadPhoto(
        projectId: projectId,
        milestoneId: milestoneId,
        imagePath: imagePath,
        description: description,
      );
      await loadPhotos(milestoneId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upload photo: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

