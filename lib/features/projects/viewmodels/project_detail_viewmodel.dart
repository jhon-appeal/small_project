import 'package:flutter/foundation.dart';
import '../services/project_service.dart';
import '../../../shared/models/project_model.dart';
import '../../milestones/services/milestone_service.dart';
import '../../../shared/models/milestone_model.dart';

class ProjectDetailViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final MilestoneService _milestoneService = MilestoneService();

  bool _isLoading = false;
  String? _errorMessage;
  ProjectModel? _project;
  List<MilestoneModel> _milestones = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProjectModel? get project => _project;
  List<MilestoneModel> get milestones => _milestones;

  Future<void> loadProject(String projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _project = await _projectService.getProjectById(projectId);
      if (_project != null) {
        await loadMilestones(projectId);
      }
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

  Future<void> updateProjectStatus(String newStatus) async {
    if (_project == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _projectService.updateProjectStatus(_project!.id, newStatus);
      await loadProject(_project!.id);
    } catch (e) {
      _errorMessage = 'Failed to update status: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

