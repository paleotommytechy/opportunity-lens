/** Pure auth form helpers; no credentials or sessions are persisted here. */
export function isValidAccountEmail(input) {
  const email = String(input ?? "").trim();
  return email.length <= 254 && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

export function hasMinimumPassword(input) {
  return typeof input === "string" && input.length >= 6;
}

export function modeFromAccountPath(path) {
  return path === "/signup" ? "signup" : path === "/reset-password" ? "update" : "signin";
}
