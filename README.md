# Letter Typer

A personal iPhone keyboard that types copied text character-by-character, with adjustable speed, optional simulated typos and corrections, and a Stop button. Includes a companion app for preparing text. Requires iOS 16 or later.

The source files are saved directly in this repository. The GitHub workflow tests the typing engine, compiles it on a cloud Mac, and packages an unsigned IPA. You can run this from a Windows PC; no personally owned Mac is needed.

## Build and install

1. Open **Actions → Build iPhone app → Run workflow**.
2. After the green check, download the **LetterTyper-unsigned** artifact and extract its IPA.
3. Set up **AltStore Classic** from Windows and install the IPA, keeping the keyboard extension.
4. Add Letter Typer in iPhone Keyboard Settings. Allow Full Access for clipboard import.
5. Test in Notes, then refresh free signing through AltStore before seven days expire.

**[Read the click-by-click guide](NEXT-STEPS.md)** for the Windows and iPhone steps.

No JSBox subscription is needed. The app has no network code, analytics, ads, or in-app purchases. Custom keyboards are unavailable in secure fields and apps that block them. Timing and host-app behavior must be checked on a real iPhone.

No Apple account credentials or signing files are used in GitHub. The IPA is unsigned until signed locally through AltStore. The workflow performs the compilation check; installation and physical-device tests are still required.
