import test from "node:test";
import assert from "node:assert/strict";
import { profileFromRow, profileToRow } from "../src/lib/profile.js";

const sample = {
  full_name: "Student", country: "Nigeria",
  institution: "Federal University", course_of_study: "Computer Engineering",
  academic_level: "Undergraduate", cgpa: "4.71", cgpa_scale: "5",
  age: "", interests: "AI, Engineering", qualifications: "Research",
};

test("profile maps directly to the owner-locked SQL contract", () => {
  const row = profileToRow("user-id", sample);
  assert.equal(row.user_id, "user-id");
  assert.equal(row.cgpa, 4.71);
  assert.equal(row.cgpa_scale, 5);
  assert.equal(row.age, null);
  assert.deepEqual(row.interests, ["AI", "Engineering"]);
  assert.ok(!("created_at" in row));
});

test("profile rehydrates numeric fields for controlled inputs", () => {
  const row = profileToRow("user-id", sample);
  const ui = profileFromRow(row);
  assert.equal(ui.cgpa, "4.71");
  assert.equal(ui.cgpa_scale, "5");
  assert.equal(ui.interests, "AI, Engineering");
});

test("CGPA scale mismatch and invalid age are rejected before a write", () => {
  assert.throws(() => profileToRow("user-id", { ...sample, cgpa: "4.71", cgpa_scale: "4" }));
  assert.throws(() => profileToRow("user-id", { ...sample, age: "0" }));
  assert.throws(() => profileToRow(null, sample));
});
