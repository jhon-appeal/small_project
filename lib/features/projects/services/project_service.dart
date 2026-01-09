import 'package:small_project/core/config/supabase_config.dart';
import 'package:small_project/shared/models/project_model.dart';

class ProjectService {
  final _client = SupabaseConfig.client;

  // Get all projects for current user
  Future<List<ProjectModel>> getProjects() async {
    final response = await _client
        .from('projects')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  // Get project by ID
  Future<ProjectModel?> getProjectById(String projectId) async {
    final response = await _client
        .from('projects')
        .select()
        .eq('id', projectId)
        .single();

    if (response == null) return null;
    return ProjectModel.fromJson(response);
  }

  // Update project status
  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    await _client
        .from('projects')
        .update({'status': newStatus})
        .eq('id', projectId);
  }

  // Create new project (Assess Direct only)
  Future<ProjectModel> createProject({
    required String address,
    required String homeownerId,
    String? roofingCompanyId,
    String? assessDirectId,
  }) async {
    final response = await _client.from('projects').insert({
      'address': address,
      'homeowner_id': homeownerId,
      'roofing_company_id': roofingCompanyId,
      'assess_direct_id': assessDirectId,
      'status': 'pending',
    }).select().single();

    return ProjectModel.fromJson(response);
  }
}

