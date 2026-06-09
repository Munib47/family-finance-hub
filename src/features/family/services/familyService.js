import { supabase } from "../../../lib/supabase";

const OWNER_ROLE = "owner";
const ACTIVE_STATUS = "active";

export async function createFamily(familyName, userId) {
  console.log("familyService createFamily called", {
    familyName,
    receivedUserId: userId,
  });

  if (!familyName || !userId) {
    throw new Error("Family name and user ID are required.");
  }

  if (familyName.trim().length < 2 || familyName.trim().length > 100) {
    throw new Error("Family name must be between 2 and 100 characters.");
  }

  // Create family record
  const insertPayload = {
    name: familyName.trim(),
    owner_user_id: userId,
    default_currency: "USD",
    fiscal_month_start_day: 1,
    status: "active",
  };

  const {
    data: { session },
  } = await supabase.auth.getSession();

  console.log("SESSION_USER_ID:", session?.user?.id);
  console.log("RECEIVED_USER_ID:", userId);
  console.log("MATCH:", session?.user?.id === userId);
  console.log(
    "PAYLOAD:",
    JSON.stringify(
      {
        name: familyName.trim(),
        owner_user_id: userId,
        default_currency: "USD",
        fiscal_month_start_day: 1,
        status: "active",
      },
      null,
      2
    )
  );

  const { data: familyData, error: familyError } = await supabase
    .from("families")
    .insert(insertPayload)
    .select()
    .single();

  console.log(
    "FAMILY_INSERT_RESPONSE",
    JSON.stringify(
      {
        data: familyData,
        error: familyError,
      },
      null,
      2
    )
  );

  if (familyError) {
    console.error("FAMILY_INSERT_ERROR_CODE:", familyError.code);
    console.error("FAMILY_INSERT_ERROR_MESSAGE:", familyError.message);
    console.error("FAMILY_INSERT_ERROR_DETAILS:", familyError.details);
    console.error("FAMILY_INSERT_ERROR_HINT:", familyError.hint);
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
