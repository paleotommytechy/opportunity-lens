import React, { useEffect, useState } from "react";
import {
  ArrowLeft, ArrowRight, CheckCircle2, Eye, EyeOff, GraduationCap,
  KeyRound, LockKeyhole, Mail, ShieldCheck, Sparkles
} from "lucide-react";
import { supabase, supabaseConfigured } from "../lib/supabase.js";
import "./auth-scene.css";
import { isValidAccountEmail, hasMinimumPassword, modeFromAccountPath } from "../lib/auth-utils.js";

/** Original vector dusk landscape: no image download, heavy canvas, or third-party asset. */
function EveningLandscape() {
  const firs = [
    [15, 750, .8], [105, 725, 1.15], [181, 760, .94], [265, 785, 1.1],
    [360, 745, .75], [435, 810, 1.25], [530, 755, .87], [628, 800, 1.1],
    [715, 760, .78], [830, 780, 1.0], [945, 766, .94], [1043, 788, 1.15],
    [1135, 744, .85], [1250, 765, .98], [1390, 738, 1.24], [1490, 753, .95],
    [1585, 760, 1.12],
  ];
  return (
    <svg className="evening-landscape" viewBox="0 0 1600 900" preserveAspectRatio="xMidYMid slice" aria-hidden="true" focusable="false">
      <defs>
        <linearGradient id="nightSky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#14142c"/>
          <stop offset=".39" stopColor="#4b385f"/>
          <stop offset=".69" stopColor="#bf7778"/>
          <stop offset="1" stopColor="#e1a47b"/>
        </linearGradient>
        <linearGradient id="waterGlow" x1="0" y1="0" x2=".2" y2="1">
          <stop offset="0" stopColor="#ce8190"/>
          <stop offset=".5" stopColor="#5b5377"/>
          <stop offset="1" stopColor="#14243b"/>
        </linearGradient>
        <radialGradient id="sunsetHalo">
          <stop offset="0" stopColor="#f8cea2" stopOpacity=".72"/>
          <stop offset=".55" stopColor="#efab91" stopOpacity=".21"/>
          <stop offset="1" stopColor="#d57e95" stopOpacity="0"/>
        </radialGradient>
      </defs>
      <rect width="1600" height="900" fill="url(#nightSky)"/>
      <circle cx="1008" cy="420" r="290" fill="url(#sunsetHalo)"/>
      <circle cx="1010" cy="429" r="93" fill="#f1b490" opacity=".83"/>
      <g fill="#f2decd" opacity=".63">
        <circle cx="142" cy="117" r="1.7"/><circle cx="277" cy="231" r="1.5"/>
        <circle cx="448" cy="99" r="1.4"/><circle cx="662" cy="174" r="1.4"/>
        <circle cx="752" cy="85" r="1.8"/><circle cx="1186" cy="136" r="1.7"/>
        <circle cx="1332" cy="223" r="1.8"/><circle cx="1533" cy="124" r="1.1"/>
        <circle cx="925" cy="102" r="1.3"/><circle cx="1037" cy="207" r="1.2"/>
      </g>
      <path d="M0 536 L144 393 281 459 433 323 583 462 707 382 868 500 1051 321 1239 489 1399 351 1600 502 1600 900 0 900Z" fill="#5b4c69"/>
      <path d="M0 595 L164 466 341 556 520 430 672 548 810 457 1009 573 1229 425 1422 542 1600 430 1600 900 0 900Z" fill="#3e405e"/>
      <path d="M0 650 L240 543 429 607 653 516 810 613 1073 524 1284 603 1450 526 1600 587 1600 900 0 900Z" fill="#282f49"/>
      <path d="M0 633 Q398 584 795 630 T1600 608 L1600 900 L0 900Z" fill="url(#waterGlow)" opacity=".78"/>
      <g stroke="#f7c5a5" strokeOpacity=".32" strokeLinecap="round">
        <path d="M610 673 H1252" strokeWidth="3"/><path d="M740 692 H1310" strokeWidth="2"/>
        <path d="M530 721 H1170" strokeWidth="2"/><path d="M880 747 H1500" strokeWidth="3"/>
        <path d="M300 760 H880" strokeWidth="2"/><path d="M750 799 H1340" strokeWidth="2"/>
      </g>
      <path d="M0 732 L207 651 399 739 588 677 740 756 911 679 1181 753 1398 670 1600 715 L1600 900 0 900Z" fill="#1c2b38" opacity=".9"/>
      <g fill="#15242e">
        {firs.map(([x,y,s],i)=><g key={i} transform={'translate('+x+' '+y+') scale('+s+')'}>
          <path d="M0 -172 L-59 -70 -31 -78 -78 18 -38 6 -102 114 0 90 102 114 38 6 78 18 31 -78 59 -70Z"/>
          <rect x="-5" y="44" width="10" height="94"/>
        </g>)}
      </g>
      <path d="M0 850 Q260 791 460 843 T910 817 T1600 835 L1600 900H0Z" fill="#0d1b26"/>
      <g fill="#0b1720" opacity=".96">
        <path d="M0 0H42V900H0Z"/><path d="M1550 0H1600V900H1550Z"/>
        <path d="M0 95Q240 9 360 0H0Z"/><path d="M1600 150Q1340 25 1217 0H1600Z"/>
      </g>
      <g fill="#101a25">
        <path d="M0 0 Q46 120 169 149 Q263 170 318 113 Q199 209 98 171 Q55 173 0 140Z"/>
        <path d="M1600 0 Q1559 118 1433 154 Q1311 182 1257 103 Q1355 208 1498 176 Q1568 162 1600 139Z"/>
      </g>
    </svg>
  );
}

const googleEnabled = import.meta.env.VITE_GOOGLE_AUTH_ENABLED === "true";
const appleEnabled = import.meta.env.VITE_APPLE_AUTH_ENABLED === "true";
const initialMode = () => modeFromAccountPath(window.location.pathname);

export default function AuthScene({
  user, authReady, profileSync, onGuest, onProfile, onSignOut, signingOut,
}) {
  const [mode, setMode] = useState(initialMode);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);
  const [recoverySession, setRecoverySession] = useState(false);

  useEffect(() => {
    if (!supabase) return;
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event) => {
      if (event === "PASSWORD_RECOVERY") {
        setRecoverySession(true);
        setMode("update");
        setMessage("Choose a new password for your account.");
        setIsError(false);
      }
    });
    return () => subscription.unsubscribe();
  }, []);

  const changeMode = (next) => {
    setMode(next); setPassword(""); setMessage(""); setIsError(false);
    if (next === "signin" || next === "signup") {
      const path = next === "signup" ? "/signup" : "/login";
      if (window.location.pathname !== path) window.history.replaceState({}, "", path);
    }
  };

  async function submit(event) {
    event.preventDefault();
    if (!supabase) {
      setMessage("Sign-in isn't connected yet. You can still explore OpportunityLens as a guest.");
      setIsError(true);
      return;
    }
    setMessage(""); setIsError(false);
    const cleanedEmail = email.trim().toLowerCase();
    if (mode !== "update" && !isValidAccountEmail(cleanedEmail)) {
      setMessage("Enter a valid email address."); setIsError(true); return;
    }
    if ((mode === "signin" || mode === "signup" || mode === "update") && !hasMinimumPassword(password)) {
      setMessage("Use a password with at least 6 characters."); setIsError(true); return;
    }
    setBusy(true);
    try {
      if (mode === "signin") {
        const { error } = await supabase.auth.signInWithPassword({email:cleanedEmail,password});
        if (error) throw error;
        setMessage("Signed in successfully. You can open your workspace.");
      } else if (mode === "signup") {
        const { data, error } = await supabase.auth.signUp({
          email: cleanedEmail, password,
          options: { emailRedirectTo: window.location.origin + "/login" },
        });
        if (error) throw error;
        setMessage(data.session
          ? "Account created. Your workspace is ready."
          : "Check your inbox for the confirmation email before signing in.");
      } else if (mode === "forgot") {
        const { error } = await supabase.auth.resetPasswordForEmail(cleanedEmail,{
          redirectTo: window.location.origin + "/reset-password",
        });
        if (error) throw error;
        setMessage("If this email belongs to an account, we'll send a reset link. Check your inbox.");
      } else if (mode === "magic") {
        const { error } = await supabase.auth.signInWithOtp({
          email: cleanedEmail,
          options: { emailRedirectTo: window.location.origin + "/login", shouldCreateUser: false },
        });
        if (error) throw error;
        setMessage("If this email has an account, check your inbox for a sign-in link.");
      } else if (mode === "update") {
        if (!recoverySession) {
          throw new Error("Open a valid password-reset link from your email to update the password.");
        }
        const { error } = await supabase.auth.updateUser({password});
        if (error) throw error;
        setRecoverySession(false); setPassword("");
        setMessage("Password updated. Your account is ready.");
        setMode("signin");
        window.history.replaceState({}, "", "/login");
      }
      setIsError(false);
    } catch(err) {
      setIsError(true);
      setMessage(err.message || "That didn't work. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  async function useProvider(provider) {
    if (!supabase) return;
    setBusy(true); setMessage(""); setIsError(false);
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider, options: { redirectTo: window.location.origin + "/login" },
      });
      if (error) throw error;
    } catch(err) {
      setMessage(err.message || "This sign-in method is unavailable.");
      setIsError(true); setBusy(false);
    }
  }

  const isRecovery = mode === "forgot" || mode === "update";
  const title = mode === "signup" ? "Create your account"
    : mode === "forgot" ? "Reset your password"
    : mode === "update" ? "Choose a new password"
    : mode === "magic" ? "Sign in with email"
    : "Welcome back";
  const subtitle = mode === "signup"
    ? "One account for the opportunities ahead."
    : mode === "forgot"
      ? "We'll email you a secure recovery link."
      : mode === "update"
        ? "Set a new password to protect your account."
        : mode === "magic"
          ? "No password needed. We'll email you a sign-in link."
          : "A clearer path to your next opportunity.";

  return (
    <main className="auth-world" id="main-content">
      <EveningLandscape/>
      <div className="auth-scene-scrim" aria-hidden="true"/>
      <div className="auth-scene-frame">
        <header className="auth-scene-header">
          <button className="auth-scene-brand" onClick={onGuest} aria-label="OpportunityLens home">
            <span className="auth-brand-glyph"><GraduationCap size={21}/></span>
            <span>opportunity<span>lens.</span></span>
          </button>
          <button className="auth-top-back" onClick={onGuest}><ArrowLeft size={17}/> Explore the app</button>
        </header>
        <div className="auth-scene-layout">
          <div className="auth-story">
            <span className="auth-story-eyebrow"><span/> A BETTER VIEW OF WHAT'S POSSIBLE</span>
            <h1>Every opportunity<br/>starts with a <em>clearer view.</em></h1>
            <p>Scholarships, requirements and next steps—all in one thoughtful place.</p>
            <div className="auth-story-note"><Sparkles size={17}/> Find your path. We'll help you see it.</div>
          </div>
          <section className="auth-sheet" aria-label="OpportunityLens account">
            <div className="auth-sheet-symbol"><GraduationCap size={27}/></div>
            {!authReady ? <div className="auth-loading" role="status">Checking your session…</div> :
            user && mode !== "update" ? <>
              <div className="auth-heading">
                <h2>You're all set.</h2>
                <p>Signed in as <strong>{user.email}</strong></p>
              </div>
              <div className="auth-signed-in"><CheckCircle2 size={19}/>
                <span>{profileSync === "synced" ? "Your academic profile is synced." :
                  profileSync === "error" ? "Your profile database still needs setup." :
                  "Your account is ready. Set up your academic profile next."}</span>
              </div>
              <div className="auth-logged-actions">
                <button className="auth-submit" onClick={onProfile}>Open my workspace <ArrowRight size={18}/></button>
                <button className="auth-secondary" onClick={onSignOut} disabled={signingOut}>Sign out</button>
              </div>
            </> : <>
              {!isRecovery && <div className="auth-tabs" role="group" aria-label="Account mode">
                <button type="button" className={mode === "signup" ? "" : "selected"} aria-pressed={mode !== "signup"} onClick={()=>changeMode("signin")}>Sign in</button>
                <button type="button" className={mode === "signup" ? "selected" : ""} aria-pressed={mode === "signup"} onClick={()=>changeMode("signup")}>Sign up</button>
              </div>}
              <div className="auth-heading"><h2>{title}</h2><p>{subtitle}</p></div>
              {!supabaseConfigured && <div className="auth-not-configured" role="status">
                <LockKeyhole size={17}/><span>Account sign-in is being set up. You can continue exploring as a guest.</span>
              </div>}
              <form className="auth-form" onSubmit={submit}>
                {mode !== "update" && <label className="auth-field">
                  <span>Email address</span>
                  <span className="auth-input-wrap"><Mail size={18}/><input type="email" value={email}
                    autoComplete="email" placeholder="you@example.com" required
                    onChange={e=>setEmail(e.target.value)} maxLength={254}/></span>
                </label>}
                {["signin","signup","update"].includes(mode) && <label className="auth-field">
                  <span>{mode === "update" ? "New password" : "Password"}</span>
                  <span className="auth-input-wrap"><LockKeyhole size={18}/>
                    <input type={showPassword ? "text" : "password"} value={password}
                      autoComplete={mode === "signin" ? "current-password" : "new-password"}
                      placeholder={mode === "signup" ? "At least 6 characters" : "Enter your password"}
                      required minLength={6} onChange={e=>setPassword(e.target.value)}/>
                    <button type="button" className="auth-eye" aria-label={showPassword ? "Hide password" : "Show password"}
                      aria-pressed={showPassword} onClick={()=>setShowPassword(p=>!p)}>
                      {showPassword ? <EyeOff size={18}/> : <Eye size={18}/>}
                    </button>
                  </span>
                </label>}
                {mode === "signin" && <div className="auth-form-row"><button type="button" className="auth-inline" onClick={()=>changeMode("forgot")}>Forgot password?</button></div>}
                {message && <div className={"auth-feedback "+(isError?"auth-feedback-error":"")} role={isError?"alert":"status"}>{message}</div>}
                <button className="auth-submit" type="submit" disabled={busy || !supabaseConfigured}>
                  {busy ? "Please wait…" : mode === "signup" ? "Create account"
                    : mode === "forgot" ? "Send reset link"
                    : mode === "update" ? "Update password"
                    : mode === "magic" ? "Email me a sign-in link" : "Sign in"}
                  {!busy && <ArrowRight size={18}/>}
                </button>
              </form>
              {isRecovery && <button className="auth-secondary auth-recovery-back" onClick={()=>changeMode("signin")}><ArrowLeft size={15}/> Back to sign in</button>}
              {!isRecovery && <div className="auth-alternates">
                {((googleEnabled || appleEnabled) && supabaseConfigured) && <>
                  <div className="auth-divider"><span>or continue with</span></div>
                  <div className="auth-provider-list">
                    {googleEnabled && <button type="button" onClick={()=>useProvider("google")} disabled={busy}>Continue with Google</button>}
                    {appleEnabled && <button type="button" onClick={()=>useProvider("apple")} disabled={busy}>Continue with Apple</button>}
                  </div>
                </>}
                <button className="auth-magic-link" onClick={()=>changeMode(mode === "magic"?"signin":"magic")}>
                  {mode === "magic" ? "Use a password instead" : "Prefer a one-time email link?"}
                </button>
                <p className="auth-switch"> {mode === "signup" ? "Already have an account?" : "New to OpportunityLens?"}
                  <button onClick={()=>changeMode(mode === "signup"?"signin":"signup")}>{mode === "signup" ? "Sign in" : "Create an account"}</button>
                </p>
              </div>}
            </>}
            <div className="auth-sheet-footer"><ShieldCheck size={15}/> Your academic profile belongs to you.</div>
          </section>
        </div>
        <footer className="auth-scene-footer"><span>© OpportunityLens · Designed for what's next</span><button onClick={onGuest}>Continue as guest <ArrowRight size={14}/></button></footer>
      </div>
    </main>
  );
}
