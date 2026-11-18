import test from "node:test";
import assert from "node:assert/strict";
import {isValidAccountEmail,hasMinimumPassword,modeFromAccountPath} from "../src/lib/auth-utils.js";

test("email input accepts typical addresses and ignores surrounding spaces", () => {
  assert.equal(isValidAccountEmail(" student@example.org "), true);
  assert.equal(isValidAccountEmail("student@example.org"), true);
});
test("email input rejects missing domains and malformed values", () => {
  for (const input of ["", "someone@", "student@localhost", "student.example.com", "a b@example.com"]) {
    assert.equal(isValidAccountEmail(input), false);
  }
});
test("password validation mirrors minimum form requirement", () => {
  assert.equal(hasMinimumPassword("secret1"), true);
  assert.equal(hasMinimumPassword("abcde"), false);
  assert.equal(hasMinimumPassword(null), false);
});
test("full-page signup and reset URLs use their correct form modes", () => {
  assert.equal(modeFromAccountPath("/signup"), "signup");
  assert.equal(modeFromAccountPath("/reset-password"), "update");
  assert.equal(modeFromAccountPath("/login"), "signin");
  assert.equal(modeFromAccountPath("/"), "signin");
});
