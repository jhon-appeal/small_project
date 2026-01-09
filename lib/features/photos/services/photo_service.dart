import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/config/supabase_config.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/models/progress_photo_model.dart';
import '../../../shared/services/supabase_service.dart';

class PhotoService {
  final _client = SupabaseConfig.client;

  // Upload photo to Supabase Storage
  Future<void> uploadPhoto({
    required String projectId,
    required String milestoneId,
    required String imagePath,
    String? description,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Create storage path: {project_id}/{milestone_id}/{timestamp}_{filename}
    final fileName = path.basename(imagePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = '$projectId/$milestoneId/${timestamp}_$fileName';

    // Upload file to storage
    final file = File(imagePath);

    await _client.storage
        .from(AppConstants.storageBucket)
        .upload(storagePath, file);

    // Create record in database
    await _client.from('progress_photos').insert({
      'milestone_id': milestoneId,
      'project_id': projectId,
      'storage_path': storagePath,
      'uploaded_by': userId,
      'description': description,
    });
  }

  // Get photos by milestone
  Future<List<ProgressPhotoModel>> getPhotosByMilestone(
    String milestoneId,
  ) async {
    final response = await _client
        .from('progress_photos')
        .select()
        .eq('milestone_id', milestoneId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProgressPhotoModel.fromJson(json))
        .toList();
  }

  // Get photo URL
  String getPhotoUrl(String storagePath) {
    return _client.storage
        .from(AppConstants.storageBucket)
        .getPublicUrl(storagePath);
  }

  // Delete photo
  Future<void> deletePhoto(String photoId, String storagePath) async {
    // Delete from storage
    await _client.storage
        .from(AppConstants.storageBucket)
        .remove([storagePath]);

    // Delete from database
    await _client.from('progress_photos').delete().eq('id', photoId);
  }
}

