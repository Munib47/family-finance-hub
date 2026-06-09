import { supabase } from "../../../lib/supabase";

const OWNER_ROLE = "owner";

function mapPermissionDefinitions(permissionDefinitions, value) {
  return permissionDefinitions.reduce((permissions, permissionDefinition) => {
    permissions[permissionDefinition.permission_key] = value;
    return permissions;
  }, {});
}

function normalizePermissionResult(result) {
  if (result.error) {
    throw result.error;
  }

  return Boolean(result.data);
}

export async function loadProfile(userId) {
  const { data, error } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", userId)
    .maybeSingle();

  if (error) {
    throw error;
  }

  return data;
}

export async function loadActiveFamilyMembership(userId) {
  const { data, error } = await supabase
    .from("family_members")
    .select("*, families(*)")
    .eq("user_id", userId)
    .eq("membership_status", "active")
    .order("joined_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) {
    throw error;
  }

  return data;
}

export async function loadPermissionDefinitions() {
  const { data, error } = await supabase
    .from("permission_definitions")
    .select("permission_key, module, description, is_assignable")
    .eq("is_assignable", true)
    .order("permission_key", { ascending: true });

  if (error) {
    throw error;
  }

  return data ?? [];
}

export async function loadPermissions({ familyId, role, permissionDefinitions }) {
  if (!familyId || !role) {
    return mapPermissionDefinitions(permissionDefinitions, false);
  }

  if (role === OWNER_ROLE) {
    return mapPermissionDefinitions(permissionDefinitions, true);
  }

  const permissionResults = await Promise.all(
    permissionDefinitions.map((permissionDefinition) =>
      supabase.rpc("has_permission", {
        p_family_id: familyId,
        p_permission_key: permissionDefinition.permission_key,
      })
    )
  );

  return permissionDefinitions.reduce((permissions, permissionDefinition, index) => {
    permissions[permissionDefinition.permission_key] = normalizePermissionResult(
      permissionResults[index]
    );

    return permissions;
  }, {});
}

export async function bootstrapAuthState(session) {
  const user = session?.user ?? null;

  if (!user) {
    return {
      family: null,
      membership: null,
      permissionDefinitions: [],
      permissions: {},
      profile: null,
      role: null,
      session: null,
      user: null,
    };
  }

  const [profile, membership, permissionDefinitions] = await Promise.all([
    loadProfile(user.id),
    loadActiveFamilyMembership(user.id),
    loadPermissionDefinitions(),
  ]);

  const family = membership?.families ?? null;
  const role = membership?.base_role ?? null;
  const permissions = await loadPermissions({
    familyId: membership?.family_id,
    permissionDefinitions,
    role,
  });

  return {
    family,
    membership,
    permissionDefinitions,
    permissions,
    profile,
    role,
    session,
    user,
  };
}
