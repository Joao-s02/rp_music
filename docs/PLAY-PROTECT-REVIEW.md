# Evidence prepared for Google Play Protect review — not submitted

Application: RP Music (com.example.rp_music), local/offline music player for Android, optional user-authorized network music sources and extensions. Public source: https://github.com/Joao-s02/rp_music .

User report: Play Protect first requests analysis. Earlier versions completed without warnings. The user reports a potentially harmful warning after analysis on0.3.12/0.3.13, with installation still possible. Exact wording, classification category, original device/Play Protect version and screenshot have not been obtained. We do not claim this is a confirmed false positive.

Affected published universal0.3.13+22 SHA256:1d60ee61153dc4f7e0a2020d7772b86ef33971a1654628e53d6f792172b3848a. Historical certificate SHA256:eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d (Android Debug). Publication configuration incorrectly used a debug signing identity; this is being corrected independently of the classification investigation.

Permissions inspected: internet/network state, wake lock, media playback foreground services, notifications and package-install requests for explicit app updates, plus an internal receiver permission. No SMS, contacts, accessibility or notification-listener access declared. The updater validates package/version/hash/signer and uses the Android system installer. Optional source code extensions require user installation/declared grants; this is executable extension functionality, not a claim of hard isolation of every runtime.

The0.3.11/0.3.13 archive comparison found unchanged DEX and third-party native libraries; Flutter AOT and resources changed. Valid ZIPs, no duplicate entries. This is a limited composition comparison and not a complete security audit or malware clearance.

Local0.3.14+23 has fail-closed production signing, platform proof of rotation (production onAndroid9+, legacy signer onolder Android for update compatibility), and lineage-aware future update verification. Same app identity preserved. AnAPI37 emulator accepted an update over0.3.13 and retained a synthetic playlist after restart. A subsequent installed-app Play Protect scan reported No harmful apps found and listed RP Music as recently scanned. This does not reproduce or clear the reported physical-device installation-time warning.

No Google appeal has been sent, no classification response obtained and no security protection disabled. If the physical-device warning persists after the corrected candidate is reviewed, request the specific classification and review through the official appeal channel, attaching the exact warning/device details and matching APK hash. Do not claim that changing certificates cures the warning.

Final review candidate SHA256:779936fdcae781ed5ab87ab7e08345043365d982ff60e68e2008ba87a904245a. Production certificate SHA256:f1aa76f72f2c5df21ddeb5da304c7b7b8f9cbea320560b2767f18d0e49e7723f. Certificate migration is not presented as a proven cause or cure for the original warning.

Follow-up user result: after receiving the0.3.14 review candidate, the user reports that the harmful-app warning still appears on the phone. The original issue remains unresolved. Matching the tested-file hash, obtaining the exact warning/category and device/Play Protect versions are still pending. The emulator installed-app scan must not be used to claim this phone warning is cleared.

Official form inspected: https://support.google.com/googleplay/android-developer/contact/protectappeals . It requires a contact email, package name, SHA256 of an APK uploaded to VirusTotal, and supporting information. The form states that decisions are final and that no response will be provided. No upload to VirusTotal and no Google submission have been performed; those actions need explicit authorization, and contact email must come from the owner. Public lookup of an existing report is distinct from uploading an unpublished candidate.

Screenshot now received: Google Play Protect displays the Spanish title "Se bloqueó la app dañina" and description "Es posible que esta app sea dañina" for RP Music, with Install anyway and Got it controls. It supports a harmful-app block report rather than just an unknown-app scan prompt. No specific threat/category, APK version/hash, Android version or Play Protect version is visible. The full screenshot includes unrelated personal surroundings and has not been copied into the public repository. No VirusTotal submission has been authorized or performed yet.

VirusTotal submission explicitly authorized and completed. Public report: https://www.virustotal.com/gui/file/779936fdcae781ed5ab87ab7e08345043365d982ff60e68e2008ba87a904245a/detection. Visible results: 67 undetected, 7 unable to process file type, Google FAILURE. No vendor flagged malicious; failure is not a clean Google result and does not clear the phone warning. Proposed appeal text is in PLAY-PROTECT-APPEAL-TEXT.txt; no Google form submitted.
