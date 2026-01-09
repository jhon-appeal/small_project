import 'package:flutter/foundation.dart';
import '../services/project_service.dart';
import '../../../shared/models/project_model.dart';

class ProjectsViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  bool _isLoading = false;
  String? _errorMessage;
  List<ProjectModel> _projects = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProjectModel> get projects => _projects;

  Future<void> loadProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await _projectService.getProjects();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load projects: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _projectService.updateProjectStatus(projectId, newStatus);
      // Reload projects to get updated data
      await loadProjects();
    } catch (e) {
      _errorMessage = 'Failed to update project: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

