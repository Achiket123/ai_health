import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class ProfileService {
  final SupabaseClient _supabaseClient;

  ProfileService({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  /// Check if user has completed their profile
  /// Returns true if profile exists, false otherwise
  Future<bool> isProfileCompleted() async {
    try {
      final user = _supabaseClient.auth.currentUser;

      print(
        'ProfileService.isProfileCompleted - Checking profile for user: ${user?.id}',
      );

      if (user == null) {
        print('ProfileService.isProfileCompleted - User is null');
        return false;
      }

      final response = await _supabaseClient
          .from('user_profile_answers')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      final isCompleted = response != null;
      print(
        'ProfileService.isProfileCompleted - Profile completed: $isCompleted',
      );

      return isCompleted;
    } on PostgrestException catch (e) {
      print(
        'ProfileService.isProfileCompleted - PostgrestException: ${e.message}',
      );
      return false;
    } catch (e) {
      print('ProfileService.isProfileCompleted - Error: $e');
      return false;
    }
  }

  /// Check if user has completed their survey
  /// Returns true if survey exists, false otherwise
  Future<bool> isSurveyCompleted() async {
    try {
      final user = _supabaseClient.auth.currentUser;

      print(
        'ProfileService.isSurveyCompleted - Checking survey for user: ${user?.id}',
      );

      if (user == null) {
        print('ProfileService.isSurveyCompleted - User is null');
        return false;
      }

      final response = await _supabaseClient
          .from('user_survey_responses')
          .select()
          .eq('user_id', user.id)
          .limit(1)
          .maybeSingle();

      final isCompleted = response != null;
      print(
        'ProfileService.isSurveyCompleted - Survey completed: $isCompleted',
      );

      return isCompleted;
    } on PostgrestException catch (e) {
      print(
        'ProfileService.isSurveyCompleted - PostgrestException: ${e.message}',
      );
      return false;
    } catch (e) {
      print('ProfileService.isSurveyCompleted - Error: $e');
      return false;
    }
  }

  /// Check if user has completed both profile and survey
  /// Returns true if both are completed, false otherwise
  Future<bool> isBothCompleted() async {
    try {
      final profileCompleted = await isProfileCompleted();
      final surveyCompleted = await isSurveyCompleted();

      print(
        'ProfileService.isBothCompleted - Profile: $profileCompleted, Survey: $surveyCompleted',
      );

      return profileCompleted && surveyCompleted;
    } catch (e) {
      print('ProfileService.isBothCompleted - Error: $e');
      return false;
    }
  }
}
