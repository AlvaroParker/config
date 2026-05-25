// Important:
// Removing prefs from user.js does NOT reset already-modified prefs in your profile.
// After saving this file, manually reset the old hardening-like prefs listed below in about:config.

/****************************************************************************
 * Tracking protection / content blocking
 ****************************************************************************/

// Firefox Settings → Privacy & Security → Enhanced Tracking Protection → Strict
user_pref("browser.contentblocking.category", "strict");

// Strip known tracking query parameters during navigation and when sharing URLs.
user_pref("privacy.query_stripping.enabled", true);
user_pref("privacy.query_stripping.enabled.pbmode", true);
user_pref("privacy.query_stripping.strip_on_share.enabled", true);

// Tell sites not to sell or share browsing data.
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.globalprivacycontrol.functionality.enabled", true);

// Upgrade HTTP navigations to HTTPS when possible.
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_pbm", true);

/****************************************************************************
 * New Tab page
 ****************************************************************************/

// Hide sponsored content and weather widgets.
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.showWeather", false);
user_pref("browser.newtabpage.activity-stream.widgets.weather.enabled", false);

/****************************************************************************
 * Address bar / search UI
 ****************************************************************************/

// Keep address bar clean and minimal.
user_pref("browser.urlbar.maxRichResults", 5);
user_pref("browser.urlbar.showSearchTerms.enabled", false);
user_pref("browser.urlbar.trimURLs", false);

// Disable specific URL bar suggestion categories.
// These are UI preference choices, not network hardening.
user_pref("browser.urlbar.shortcuts.actions", false);
user_pref("browser.urlbar.shortcuts.bookmarks", false);
user_pref("browser.urlbar.shortcuts.history", false);
user_pref("browser.urlbar.shortcuts.tabs", false);

user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.quickactions", false);
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.urlbar.suggest.topsites", false);

// Fully disable Firefox Suggest remote/sponsored results.
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.quicksuggest.online.enabled", false);
user_pref("browser.urlbar.suggest.quicksuggest.all", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.sponsoredTopSites", false);

// Firefox Settings → Search → Show search suggestions
user_pref("browser.search.suggest.enabled", false);

/****************************************************************************
 * Tabs / session / startup
 ****************************************************************************/

// Restore previous session on startup.
user_pref("browser.startup.page", 3);

// Load restored tabs immediately instead of on demand.
// This is a behavior choice; it may use more resources at startup.
user_pref("browser.sessionstore.restore_on_demand", false);

// Reduce sessionstore disk churn while still keeping useful crash recovery.
user_pref("browser.sessionstore.interval", 30000);

// Disable smart tab group suggestions.
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.tabs.groups.smart.userEnabled", false);

// Hide the tab manager button.
user_pref("browser.tabs.tabmanager.enabled", false);

/****************************************************************************
 * UI / appearance
 ****************************************************************************/

// Enable compact mode option.
user_pref("browser.compactmode.show", true);

// Compact density.
user_pref("browser.uidensity", 1);

// Hide bookmarks toolbar.
user_pref("browser.toolbars.bookmarks.visibility", "never");

// Use custom userChrome.css / userContent.css if present.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

/****************************************************************************
 * Fonts
 ****************************************************************************/

user_pref("font.name.monospace.x-western", "FiraCode Nerd Font Mono");
user_pref("font.name.sans-serif.x-western", "Inter Display");
user_pref("font.name.serif.x-western", "Inter Display");

/****************************************************************************
 * Passwords
 ****************************************************************************/

// Firefox Settings -> Privacy & Security -> Ask to save passwords.
user_pref("signon.rememberSignons", false);

// Do not autofill saved logins or passwords into forms.
user_pref("signon.autofillForms", false);
user_pref("signon.autofillForms.autocompleteOff", false);

// Keep Firefox from capturing password changes or suggesting generated passwords.
user_pref("signon.capture.inputChanges.enabled", false);
user_pref("signon.formlessCapture.enabled", false);
user_pref("signon.generation.enabled", false);

/****************************************************************************
 * Downloads / media / permissions
 ****************************************************************************/

// Keep downloads quiet after starting.
user_pref("browser.download.alwaysOpenPanel", false);

// Block autoplaying media unless allowed per site.
user_pref("media.autoplay.default", 5);

// Block notification prompts by default.
user_pref("permissions.default.desktop-notification", 2);

/****************************************************************************
 * Translations
 ****************************************************************************/

// Disable translation prompts/features if you do not use them.
user_pref("browser.translations.automaticallyPopup", false);
user_pref("browser.translations.enable", false);

/****************************************************************************
 * Find bar
 ****************************************************************************/

// Highlight all matches by default.
user_pref("findbar.highlightAll", true);

/****************************************************************************
 * DevTools
 ****************************************************************************/

// DevTools dock position.
user_pref("devtools.toolbox.host", "right");

// Do not show the Responsive Design Mode reload notification.
user_pref("devtools.responsive.reloadNotification.enabled", false);

/****************************************************************************
 * AI / ML
 ****************************************************************************/

// Optional: keep these ONLY if you want Firefox's “Block AI enhancements”
// behavior preserved through user.js.
//
// If you prefer fully vanilla Firefox defaults, delete this whole section.

user_pref("browser.ai.control.default", "blocked");
user_pref("browser.ai.control.linkPreviewKeyPoints", "blocked");
user_pref("browser.ai.control.pdfjsAltText", "blocked");
user_pref("browser.ai.control.sidebarChatbot", "blocked");
user_pref("browser.ai.control.smartTabGroups", "blocked");
user_pref("browser.ai.control.smartWindow", "blocked");
user_pref("browser.ai.control.translations", "blocked");

/****************************************************************************
 * Sidebar / vertical tabs
 ****************************************************************************/

user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);
user_pref("sidebar.position_start", false);
user_pref("sidebar.visibility", "expand-on-hover");
user_pref("sidebar.main.tools", "bookmarks,history,syncedtabs");

// Use Mozilla's built-in Dark theme instead of the system/auto theme.
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");

// Keep Firefox chrome, internal pages, and prefers-color-scheme dark.
// 0 = dark, 1 = light, 2 = system/automatic.
user_pref("browser.theme.content-theme", 0);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("layout.css.prefers-color-scheme.content-override", 0);

/****************************************************************************
 * New Tab background
 ****************************************************************************/

// Set New Tab to the same solid color used by userChrome.css.
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.enabled", true);
user_pref(
    "browser.newtabpage.activity-stream.newtabWallpapers.customColor.enabled",
    true,
);
user_pref(
    "browser.newtabpage.activity-stream.newtabWallpapers.user.enabled",
    true,
);
user_pref(
    "browser.newtabpage.activity-stream.newtabWallpapers.user.enabled.migrated",
    true,
);
user_pref(
    "browser.newtabpage.activity-stream.newtabWallpapers.initialWallpaper",
    "",
);
user_pref(
    "browser.newtabpage.activity-stream.newtabWallpapers.wallpaper",
    "solid-color-picker-#1c1b22",
);
