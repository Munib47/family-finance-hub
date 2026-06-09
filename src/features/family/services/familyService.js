import { supabase } from "../../../lib/supabase";

const OWNER_ROLE = "owner";
const ACTIVE_STATUS = "active";

export async function createFamily(familyName, userId) {
  if (!familyName || !userId) {
    throw new Error("Family name and user ID are required.");
  }

  if (familyName.trim().length < 2 || familyName.trim().length > 100) {
    throw new Error("Family name must be between 2 and 100 characters.");
  }

  // Create family record
  const { data: familyData, error: familyError } = await supabase
    .from("families")
    .insert({
      name: familyName.trim(),
      owner_user_id: userId,
      default_currency: "USD",
      fiscal_month_start_day: 1,
      status: "active",
    })
    .select()
    .single();

  if (familyError) {
    throw familyError;
  }

  if (!familyData) {
    throw new Error("Failed to create family record.");
  }

  // Create owner family_members record
  const { data: memberData, error: memberError } = await supabase
    .from("family_members")
    .insert({
      family_id: familyData.id,
      user_id: userId,
      base_role: OWNER_ROLE,
      membership_status: ACTIVE_STATUS,
      joined_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (memberError) {
    throw memberError;
  }

  if (!memberData) {
    throw new Error("Failed to create family membership record.");
  }

  return {
    family: familyData,
    member: memberData,
  };
}
