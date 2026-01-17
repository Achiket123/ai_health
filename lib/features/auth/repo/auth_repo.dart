import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  
  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }
}
