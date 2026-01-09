import 'package:flutter/foundation.dart';
import 'package:small_project/core/utils/constants.dart';
import 'package:small_project/features/auth/services/auth_service.dart';
import 'package:small_project/features/milestones/services/milestone_service.dart';
import 'package:small_project/features/photos/services/photo_service.dart';
import 'package:small_project/shared/models/milestone_model.dart';
import 'package:small_project/shared/models/progress_photo_model.dart';

class MilestoneDetailViewModel extends ChangeNotifier {
  final MilestoneService _milestoneService = MilestoneService();
  final PhotoService _photoService = PhotoService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  MilestoneModel? _milestone;
  List<ProgressPhotoModel> _photos = [];
  String? _currentUserRole;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MilestoneModel? get milestone => _milestone;
  List<ProgressPhotoModel> get photos => _photos;
  String? get currentUserRole => _currentUserRole;

  Future<void> _loadCurrentUserRole() async {
    final profile = await _authService.getCurrentProfile();
    _currentUserRole = profile?.role;
    notifyListeners();
  }

  Future<void> loadMilestone(String milestoneId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _milestone = await _milestoneService.getMilestoneById(milestoneId);
      if (_milestone != null) {
        await loadPhotos(milestoneId);
      }
      await _loadCurrentUserRole();
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

  /// Check if the current user can change the milestone status
  /// This checks the milestone NAME (not status) to determine permissions
  bool canChangeStatus() {
    if (_milestone == null || _currentUserRole == null) return false;
    
    // Check milestone name (not status) to determine permissions
    final milestoneName = _milestone!.name.trim();
    
    switch (_currentUserRole!) {
      case AppConstants.roleHomeowner:
        // Homeowner can only change status when milestone name is "Final Inspection"
        return milestoneName == AppConstants.milestoneNameFinalInspection ||
               milestoneName.toLowerCase() == 'final inspection';
      
      case AppConstants.roleRoofingCompany:
        // Roof company can change status if milestone name is "Initial Inspection" or "Roof Construction"
        return milestoneName == AppConstants.milestoneNameInitialInspection ||
               milestoneName.toLowerCase() == 'initial inspection' ||
               milestoneName == AppConstants.milestoneNameRoofConstruction ||
               milestoneName.toLowerCase() == 'roof construction';
      
      case AppConstants.roleAssessDirect:
        // Assess direct can change status if milestone name is "Claim Lodged" or "Claim Approved"
        return milestoneName == AppConstants.milestoneNameClaimLodged ||
               milestoneName.toLowerCase() == 'claim lodged' ||
               milestoneName == AppConstants.milestoneNameClaimApproved ||
               milestoneName.toLowerCase() == 'claim approved';
      
      default:
        return false;
    }
  }

  /// Get the list of allowed next statuses based on current role and milestone name
  /// Returns valid milestone_status ENUM values: pending, in_progress, completed, approved
  List<String> getAllowedNextStatuses() {
    if (_milestone == null || _currentUserRole == null) return [];
    
    // Check milestone name (not status) to determine allowed next statuses
    final milestoneName = _milestone!.name.trim();
    final List<String> allowedStatuses = [];
    
    switch (_currentUserRole!) {
      case AppConstants.roleHomeowner:
        // Homeowner can only change when milestone name is "Final Inspection"
        if (milestoneName == AppConstants.milestoneNameFinalInspection ||
            milestoneName.toLowerCase() == 'final inspection') {
          // Can change to completed or approved (valid ENUM values)
          allowedStatuses.addAll([
            AppConstants.milestoneCompleted,
            AppConstants.milestoneApproved,
          ]);
        }
        break;
      
      case AppConstants.roleRoofingCompany:
        // Roof company can change from "Initial Inspection" or "Roof Construction"
        if (milestoneName == AppConstants.milestoneNameInitialInspection ||
            milestoneName.toLowerCase() == 'initial inspection') {
          // From Initial Inspection, can change to in_progress
          allowedStatuses.addAll([
            AppConstants.milestoneInProgress,
          ]);
        } else if (milestoneName == AppConstants.milestoneNameRoofConstruction ||
                   milestoneName.toLowerCase() == 'roof construction') {
          // From Roof Construction, can change to completed
          allowedStatuses.addAll([
            AppConstants.milestoneCompleted,
            AppConstants.milestoneInProgress, // Keep in progress if work continues
          ]);
        }
        break;
      
      case AppConstants.roleAssessDirect:
        // Assess direct can change from "Claim Lodged" or "Claim Approved"
        if (milestoneName == AppConstants.milestoneNameClaimLodged ||
            milestoneName.toLowerCase() == 'claim lodged') {
          // From Claim Lodged, can change to approved or in_progress
          allowedStatuses.addAll([
            AppConstants.milestoneApproved,
            AppConstants.milestoneInProgress,
          ]);
        } else if (milestoneName == AppConstants.milestoneNameClaimApproved ||
                   milestoneName.toLowerCase() == 'claim approved') {
          // From Claim Approved, can change to in_progress to start work
          allowedStatuses.addAll([
            AppConstants.milestoneInProgress,
          ]);
        }
        break;
    }
    
    return allowedStatuses;
  }

  Future<bool> updateMilestoneStatus(String newStatus) async {
    if (_milestone == null) return false;

    // Validate that user can change status
    if (!canChangeStatus()) {
      _errorMessage = 'You do not have permission to change status at this stage.';
      notifyListeners();
      return false;
    }

    // Validate that the new status is allowed
    final allowedStatuses = getAllowedNextStatuses();
    final newStatusLower = newStatus.toLowerCase().trim();
    if (!allowedStatuses.any((s) => s.toLowerCase().trim() == newStatusLower)) {
      _errorMessage = 'Invalid status transition. Please select an allowed status.';
      notifyListeners();
      return false;
    }

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

