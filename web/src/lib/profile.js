function cleanText(value, limit) {
  return String(value ?? "").trim().slice(0, limit);
}

export function profileToRow(userId, profile) {
  if (!userId) throw new Error("Sign in before saving a profile.");
  const scale = Number(profile.cgpa_scale || 5);
  if (![4, 5, 7].includes(scale)) throw new Error("Choose a valid CGPA scale (4, 5 or 7).");
  const cgpa = profile.cgpa === "" || profile.cgpa == null ? null : Number(profile.cgpa);
  if (cgpa != null && (!Number.isFinite(cgpa) || cgpa < 0 || cgpa > scale)) {
    throw new Error("Your CGPA must fit the selected grading scale.");
  }
  const age = profile.age === "" || profile.age == null ? null : Number(profile.age);
  if (age != null && (!Number.isInteger(age) || age < 1 || age > 120)) {
    throw new Error("Enter a valid age or leave it blank.");
  }
  const interests = String(profile.interests || "").split(",")
    .map((x) => x.trim()).filter(Boolean);
  if (interests.length > 30) throw new Error("Add no more than 30 interests.");
  return {
    user_id: userId,
    full_name: cleanText(profile.full_name, 120),
    country: cleanText(profile.country, 80),
    institution: cleanText(profile.institution, 160),
    course_of_study: cleanText(profile.course_of_study, 160),
    academic_level: cleanText(profile.academic_level, 80),
    cgpa,
    cgpa_scale: scale,
    age,
    qualifications: cleanText(profile.qualifications, 3000),
    interests,
  };
}

export function profileFromRow(row) {
  return {
    full_name: row.full_name || "",
    country: row.country || "",
    institution: row.institution || "",
    course_of_study: row.course_of_study || "",
    academic_level: row.academic_level || "",
    cgpa: row.cgpa == null ? "" : String(row.cgpa),
    cgpa_scale: row.cgpa_scale == null ? "5" : String(row.cgpa_scale),
    age: row.age == null ? "" : String(row.age),
    qualifications: row.qualifications || "",
    interests: Array.isArray(row.interests) ? row.interests.join(", ") : "",
  };
}
