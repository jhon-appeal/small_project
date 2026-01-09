
import 'package:small_project/core/config/supabase_config.dart';
import 'package:small_project/shared/models/milestone_model.dart';

class MilestoneService {
  final _client = SupabaseConfig.client;

  // Get milestones by project
  Future<List<MilestoneModel>> getMilestonesByProject(String projectId) async {
    final response = await _client
        .from('milestones')
        .select()
        .eq('project_id', projectId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => MilestoneModel.fromJson(json))
        .toList();
  }

  // Get milestone by ID
  Future<MilestoneModel?> getMilestoneById(String milestoneId) async {
    final response = await _client
        .from('milestones')
        .select()
        .eq('id', milestoneId)
        .single();

    if (response == null) return null;
    return MilestoneModel.fromJson(response);
  }

  // Update milestone status
  Future<void> updateMilestoneStatus(
    String milestoneId,
    String newStatus,
  ) async {
    final updateData = {'status': newStatus};
    
    if (newStatus == 'completed') {
      updateData['completed_at'] = DateTime.now().toIso8601String();
    }

    await _client
        .from('milestones')
        .update(updateData)
        .eq('id', milestoneId);
  }
}

