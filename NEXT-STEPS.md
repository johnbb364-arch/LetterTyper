# Install Letter Typer from Windows

You do not need JSBox Pro or a paid Apple Developer membership for this personal testing route. Your project is already on GitHub. It builds on a cloud Mac, so you do not need to own one.

## Step 2 — Get the iPhone app file

On your Windows PC:

1. Open [your project](https://github.com/johnbb364-arch/LetterTyper).
2. Click **Actions** near the top.
3. Click **Build iPhone app** on the left.
4. Click **Run workflow**, leave the branch set to **main**, and click the Run workflow button inside the dialog.
5. Open the new run and wait for a **green check**. It tests the typing logic, then compiles and packages the app. This can take several minutes.
6. Scroll down on the completed run to **Artifacts**. Click **LetterTyper-unsigned** to download its ZIP.
7. On Windows, find the downloaded ZIP, right-click it, and choose **Extract All**.
8. Open the extracted folder and find **LetterTyper-unsigned.ipa**. This IPA is the compiled iPhone app. Keep the .ipa ending.

If a successful run is already available, you can download its artifact without running another build. If you see a red X, open the failed step and copy the error text into chat. Do not rename the source-code ZIP to .ipa.

GitHub provides standard hosted runners free for public repositories. This workflow uses a standard runner. [GitHub runner rules](https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/choose-the-runner-for-a-job).

## Step 3 — Set up AltStore Classic

iOS needs the app signed for your phone. AltStore Classic signs your IPA using your Apple account and installs it. It does not compile the project.

Have your Windows PC, unlocked iPhone, and normal USB charging/data cable ready. The first setup needs a cable connection; no Mac or other accessory is needed.

On Windows:

1. Open the [official AltStore Windows guide](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows).
2. Install the required Apple iTunes and iCloud versions using that guide's download links. Follow the guide rather than guessing which Microsoft Store versions to install.
3. Download **AltServer for Windows** from [AltStore](https://altstore.io/) and install it. Use **AltStore Classic**, not AltStore PAL.
4. Open AltServer. Find its icon near the Windows taskbar clock; click the small up-arrow if necessary.
5. Connect your unlocked iPhone to the PC. Tap **Trust** on the phone and enter your phone passcode yourself if requested.
6. Open iTunes, select your phone, enable **Sync with this iPhone over Wi-Fi**, and apply the change. Keep the cable connected for the first installation.
7. Click AltServer's taskbar icon, then **Install AltStore → your iPhone's name**.
8. Enter your Apple account details yourself when AltServer asks. Never put your password on GitHub or send it in chat.

On iPhone:

9. If developer trust is requested, open **Settings → General → VPN & Device Management**, select the profile matching your account, and trust it.
10. Enable **Settings → Privacy & Security → Developer Mode**, then complete its restart and confirmation. Follow the official guide if the setting is missing or has a different name.
11. Open **AltStore** on your phone.

## Step 4 — Install Letter Typer

1. Transfer **LetterTyper-unsigned.ipa** from Windows to your iPhone's **Files** app. Your existing iCloud Drive account is one option. Wait for the file to finish downloading on the phone.
2. Leave AltServer open on Windows and keep your phone connected for this first attempt.
3. On the phone, open **AltStore → My Apps**, tap **+**, find the IPA in Files, and select it.
4. Sign in yourself if requested.
5. If asked whether to remove extensions, choose **Keep App Extensions**. The keyboard is an extension; removing it removes the feature you want.
6. Wait for **Letter Typer** to appear on the Home Screen, then open it.

If signing reports an App ID limit, copy the error into chat. Do not remove the keyboard extension or buy a signing service to fix it. Free accounts have a weekly App ID limit, and extensions consume IDs too. [AltStore App IDs](https://faq.altstore.io/altstore-classic/app-ids).

## Step 5 — Enable and try the keyboard

On iPhone:

1. Open **Settings → General → Keyboard → Keyboards → Add New Keyboard**.
2. Select **Letter Typer**.
3. Tap Letter Typer in the keyboard list, then enable **Allow Full Access** if you want clipboard import. iOS shows a broad permission warning. This project's source has no network code; the permission is used for reading copied text. With Full Access off, the built-in demo still works. [Apple keyboard clipboard capability](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html).
4. Open the **Letter Typer app**, write a short sentence with your usual keyboard, and tap **Copy for keyboard**.
5. Open **Notes**, create a blank note, and tap its text area.
6. Hold the **globe** button on the current keyboard and choose **Letter Typer**. If you see an emoji key instead, try holding it to open the keyboard list.
7. Tap **Load copied text**, allow Paste if requested, and check the preview.
8. Start with a slow speed and simulated typos off. Tap **Start**.
9. The text should appear one character at a time. Tap **Stop** to end the run early.
10. Test **Simulate typos** afterward. Some lowercase letters are briefly wrong, then corrected. A short sentence may show no random errors.

**Start begins the whole sentence again; it is not Resume.** Keep the app and target field focused. If you change fields or dismiss the keyboard during a typo, inspect the last letter yourself. Review all output before sending it.

Speed is adjustable from 0.5 to 30 characters per second. Emoji and combined letters are handled as characters. Timing is approximate, and typo corrections add an extra timer tick.

## Keep it working

Free signing expires after seven days. Before then, open **AltStore → My Apps → Refresh All** with AltServer running and your phone connected by its trusted cable or configured Wi-Fi sync. You do not need a new GitHub build just to renew signing. [Apple free-signing limits](https://developer.apple.com/help/account/basics/about-your-developer-account).

Password fields, phone keypad fields, and apps that reject third-party keyboards do not support Letter Typer. The keyboard cannot type across the entire phone in the background. Test in Notes first, then check your intended app. [Apple keyboard restrictions](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html).

Physical iPhone tests are still required. Test stopping, switching fields, both screen orientations, and Full Access off/on before relying on it.
