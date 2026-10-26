# signup_app

MAD 4360 - In-Class Activity 10

Track: Undergraduate

Task: Core signup form + Task A (AI Signup Coach)

Student: Wilder Edwards

## What the app does

The app has a signup form with Full Name, Email Address, and Password fields. Each field
uses a leading icon and an `OutlineInputBorder`. The local validators check for empty
fields, an email with `@`, and a password of at least 6 characters. A valid form shows a
green SnackBar. No account is created or stored.

The theme choice is purple: the AppBar and Sign Up button both use purple.

Task A adds an "AI Signup Coach" section below the form. Tapping "Get a signup tip" shows
a loading state, then displays a tip labeled "AI-generated suggestion". If the request
fails, the app shows a friendly message and changes the button to "Try again".

## AI service and privacy

No instructor endpoint or AI model was provided for this activity.
The app therefore uses `MockSignupTipService`. It returns one fixed canned tip after a
900 ms delay. **No live model is called.** The screen shows a `MOCK` badge and the line
"Mock mode - no live model is called."

The request contract is implemented in `HttpSignupTipService` for a future course
endpoint. It sends an HTTPS `POST` with the fixed task and topic.

It expects HTTP 200 and a non-empty `{"tip":"..."}` response, times out after 10 seconds,
and trims the displayed text to 240 characters.

```bash
flutter build apk --release --dart-define=SIGNUP_TIP_ENDPOINT=https://example.edu/tip
```

The form's name, email, and password are never used in the request. No API keys,
tokens, or real credentials are in the app. The endpoint is supplied at build time.
The AI tip is only advice; it cannot approve or reject signup and does not replace the
local validators.

## Reflection - Wilder Edwards

**Question 1: Trace the AI tip feature from button tap to displayed text. Which
widget/state changes while the request is waiting, and how does the user recover if it
fails?**

When the tip button is tapped, _getTip() sets _loadingTip to true and clears the old
tip and error before calling SignupTipService.fetchTip(). While waiting the button is
disabled, its icon becomes a CircularProgressIndicator, and its label changes to
"Getting a tip...". If the call throws, `setState()` shows a friendly red error box and
changes the button label to "Try again", so the user recovers without leaving the form.

**Question 3: Name the exact information your request sends and one piece of information
it deliberately does not send. Why?**

The request sends only the fixed task signup_tip and the non-sensitive topic
password_help. It deliberately does not send the user's name, email, password, or any
other form value, because those are private and the tip does not need them. The app also
has no provider key; the endpoint comes from a build-time setting.


## Contributions

- **Wilder Edwards:** Built the signup form and validators, connected the mock tip
  service, added the AI loading/success/error UI, and prepared the README and APK.


