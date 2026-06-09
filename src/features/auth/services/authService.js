import { supabase } from "../../../lib/supabase";

export async function getCurrentSession() {
  return supabase.auth.getSession();
}

export function onAuthStateChange(callback) {
  return supabase.auth.onAuthStateChange(callback);
}

export async function signInWithEmail({ email, password }) {
  return supabase.auth.signInWithPassword({
    email,
    password,
  });
}

export async function signUpWithEmail({ email, password, metadata = {} }) {
  return supabase.auth.signUp({
    email,
    password,
    options: {
      data: metadata,
    },
  });
}

export async function signOut() {
  return supabase.auth.signOut();
}

export async function sendPasswordResetEmail(email, redirectTo) {
  const options = redirectTo ? { redirectTo } : undefined;

  return supabase.auth.resetPasswordForEmail(email, options);
}
