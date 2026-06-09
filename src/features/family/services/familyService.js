import { supabase } from "../../../lib/supabase";

export async function createFamily(familyName, userId) {
  if (!familyName || !userId) {
    throw new Error("Family name and user ID are required.");
  }

  if (familyName.trim().length < 2 || familyName.trim().length > 100) {
    throw new Error("Family name must be between 2 and 100 characters.");
  }

  const { data: familyId, error } = await supabase.rpc(
    "create_family_with_owner_member",
    {
      p_name: familyName.trim(),
      p_owner_user_id: userId,
    }
  );

  if (error) {
    throw error;
  }

  return {
    familyId,
  };
}