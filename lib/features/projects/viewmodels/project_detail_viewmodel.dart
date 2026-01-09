import 'package:flutter/foundation.dart';
import 'package:small_project/core/utils/constants.dart';
import 'package:small_project/features/auth/services/auth_service.dart';
import 'package:small_project/features/milestones/services/milestone_service.dart';
import 'package:small_project/features/projects/services/project_service.dart';
import 'package:small_project/shared/models/milestone_model.dart';
import 'package:small_project/shared/models/project_model.dart';

class ProjectDetailViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final MilestoneService _milestoneService = MilestoneService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  ProjectModel? _project;
  List<MilestoneModel> _milestones = [];
  String? _currentUserRole;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProjectModel? get project => _project;
  List<MilestoneModel> get milestones => _milestones;
  String? get currentUserRole => _currentUserRole;

  Future<void> _loadCurrentUserRole() async {
    final profile = await _authService.getCurrentProfile();
    _currentUserRole = profile?.role;
    notifyListeners();
  }

  Future<void> loadProject(String projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _project = await _projectService.getProjectById(projectId);
      if (_project != null) {
        await loadMilestones(projectId);
      }
      await _loadCurrentUserRole();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load project: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMilestones(String projectId) async {
    try {
      _milestones = await _milestoneService.getMilestonesByProject(projectId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load milestones: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Check if the current user can change the project status
  bool canChangeStatus() {
    if (_project == null || _currentUserRole == null) return false;
    
    final currentStatus = _project!.status.toLowerCase().trim();
    
    switch (_currentUserRole!) {
      case AppConstants.roleHomeowner:
        // Homeowner can change status when project is completed → can close it
        return currentStatus == AppConstants.statusCompleted.toLowerCase() ||
               currentStatus == 'completed';
      
      case AppConstants.roleRoofingCompany:
        // Roof company can change status if current status is inspection or construction
        return currentStatus == AppConstants.statusInspection.toLowerCase() ||
               currentStatus == 'inspection' ||
               currentStatus == AppConstants.statusConstruction.toLowerCase() ||
               currentStatus == 'construction';
      
      case AppConstants.roleAssessDirect:
        // Assess direct can change status if status is claim_lodged or claim_approved
        return currentStatus == AppConstants.statusClaimLodged.toLowerCase() ||
               currentStatus == 'claim_lodged' ||
               currentStatus == AppConstants.statusClaimApproved.toLowerCase() ||
               currentStatus == 'claim_approved';
      
      default:
        return false;
    }
  }

  /// Get the list of allowed next statuses based on current role and status
  /// Returns valid project_status ENUM values
  List<String> getAllowedNextStatuses() {
    if (_project == null || _currentUserRole == null) return [];
    
    final currentStatus = _project!.status.toLowerCase().trim();
    final List<String> allowedStatuses = [];
    
    switch (_currentUserRole!) {
      case AppConstants.roleHomeowner:
        // Homeowner can change from completed to closed
        if (currentStatus == AppConstants.statusCompleted.toLowerCase() ||
            currentStatus == 'completed') {
          allowedStatuses.addAll([
            AppConstants.statusClosed,
          ]);
        }
        break;
      
      case AppConstants.roleRoofingCompany:
        // Roof company can change from inspection or construction
        if (currentStatus == AppConstants.statusInspection.toLowerCase() ||
            currentStatus == 'inspection') {
          // From inspection, can change to construction
          allowedStatuses.addAll([
            AppConstants.statusConstruction,
          ]);
        } else if (currentStatus == AppConstants.statusConstruction.toLowerCase() ||
                   currentStatus == 'construction') {
          // From construction, can change to completed
          allowedStatuses.addAll([
            AppConstants.statusCompleted,
          ]);
        }
        break;
      
      case AppConstants.roleAssessDirect:
        // Assess direct can change from claim_lodged or claim_approved
        if (currentStatus == AppConstants.statusClaimLodged.toLowerCase() ||
            currentStatus == 'claim_lodged') {
          // From claim_lodged, can change to claim_approved or inspection
          allowedStatuses.addAll([
            AppConstants.statusClaimApproved,
            AppConstants.statusInspection,
          ]);
        } else if (currentStatus == AppConstants.statusClaimApproved.toLowerCase() ||
                   currentStatus == 'claim_approved') {
          // From claim_approved, can change to inspection to start work
          allowedStatuses.addAll([
            AppConstants.statusInspection,
          ]);
        }
        break;
    }
    
    return allowedStatuses;
  }

  Future<bool> updateProjectStatus(String newStatus) async {
    if (_project == null) return false;

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
      await _projectService.updateProjectStatus(_project!.id, newStatus);
      await loadProject(_project!.id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status: ${e.toString()}';
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

