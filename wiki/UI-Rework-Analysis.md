# UI Rework Technical Analysis

- [Proposed Tasks](#proposed-tasks)
  - [1. Core Architecture \& Design System](#1-core-architecture--design-system)
    - [1.1 Qt Model/View Architecture. (Should be an Epic by itself.)](#11-qt-modelview-architecture-should-be-an-epic-by-itself)
    - [1.2 Identification of base usable components](#12-identification-of-base-usable-components)
    - [1.3 Centralized system for strings/texts.](#13-centralized-system-for-stringstexts)
    - [1.4 Centralized management of application and/or user settings.](#14-centralized-management-of-application-andor-user-settings)
      - [1.4.1 Application Settings](#141-application-settings)
      - [1.4.2 User Settings](#142-user-settings)
    - [1.5 App Base Skeleton](#15-app-base-skeleton)
    - [1.6 Theme management](#16-theme-management)
    - [1.7 Modal/Popup management](#17-modalpopup-management)
    - [1.8 Siderail items configuration file maybe?](#18-siderail-items-configuration-file-maybe)
    - [1.9 Guidelines for folder structuring and naming](#19-guidelines-for-folder-structuring-and-naming)
    - [1.10 Assets management.](#110-assets-management)
    - [1.11 Event/Communication system.](#111-eventcommunication-system)
    - [1.12 Singleton Manager-based approach?](#112-singleton-manager-based-approach)
    - [1.13 Data filtering.](#113-data-filtering)
    - [1.14 Data fetching management.](#114-data-fetching-management)
    - [1.15 Command Pattern (Undo/Redo)](#115-command-pattern-undoredo)
    - [1.16 Centralized app state.](#116-centralized-app-state)
    - [1.17 Developer experience tooling.](#117-developer-experience-tooling)
    - [1.18 Notifications/Toast management.](#118-notificationstoast-management)
    - [1.19 Application versioning.](#119-application-versioning)
    - [1.20 Internal documentation guidelines.](#120-internal-documentation-guidelines)
    - [1.21 Role management?](#121-role-management)
    - [1.22 Testing.](#122-testing)
    - [1.23 Offline support.](#123-offline-support)
    - [1.24 Performance reviews.](#124-performance-reviews)
    - [1.25 Race Conditions](#125-race-conditions)
  - [2. Global Layout \& Navigation](#2-global-layout--navigation)
    - [2.1 Side rail.](#21-side-rail)
      - [2.1.1 Side menu items management system.](#211-side-menu-items-management-system)
      - [2.1.2 Expand/Collapse side panel icon near the user profile's icon](#212-expandcollapse-side-panel-icon-near-the-user-profiles-icon)
      - [2.1.3 User Icon](#213-user-icon)
    - [2.2 Side panel.](#22-side-panel)
      - [2.2.1 Side panel content depending on chosen side rail icon](#221-side-panel-content-depending-on-chosen-side-rail-icon)
      - [2.2.2 Wizard/Stepper functionality](#222-wizardstepper-functionality)
    - [2.3 Titlebar](#23-titlebar)
      - [2.3.1 Analysis on how to hide system default's title bar with a customized one.](#231-analysis-on-how-to-hide-system-defaults-title-bar-with-a-customized-one)
      - [2.3.2 Date and time.](#232-date-and-time)
      - [2.3.3 Tab bar. (The one with the Overview text)](#233-tab-bar-the-one-with-the-overview-text)
      - [2.3.4 Change language.](#234-change-language)
      - [2.3.5 Search bar.](#235-search-bar)
      - [2.3.6 Window related icons. (Minimize/Maximize/Close)](#236-window-related-icons-minimizemaximizeclose)
    - [2.4 Map Toolbar](#24-map-toolbar)
      - [2.4.1 Map tileset switcher icon.](#241-map-tileset-switcher-icon)
      - [2.4.2 Home button?](#242-home-button)
      - [2.4.3 Current position button.](#243-current-position-button)
      - [2.4.4 Zoom controls: increase and decrease.](#244-zoom-controls-increase-and-decrease)
    - [2.5 Alert Panel](#25-alert-panel)
      - [2.5.1 Alert timeline.](#251-alert-timeline)
      - [2.5.2 Arrow pointing to right with vertical bar?](#252-arrow-pointing-to-right-with-vertical-bar)
      - [2.5.3 Circled underlined check?](#253-circled-underlined-check)
    - [2.6 Context Panel (should we call it this way for general use?)](#26-context-panel-should-we-call-it-this-way-for-general-use)
      - [2.6.1 Assets/tracks list](#261-assetstracks-list)
  - [3. Multilingual Support](#3-multilingual-support)
    - [3.1 From the title bar, there's the "world" icon which opens up the language side panel.](#31-from-the-title-bar-theres-the-world-icon-which-opens-up-the-language-side-panel)
    - [3.2 Ability to change language.](#32-ability-to-change-language)
  - [4. User Management](#4-user-management)
    - [4.1 Authentication/Registration](#41-authenticationregistration)
    - [4.2 User Details Modification](#42-user-details-modification)
    - [4.3 User Settings Modification](#43-user-settings-modification)
  - [5. Map \& Layers](#5-map--layers)
    - [5.1 Ability to change tilesets. (Open Street Map)](#51-ability-to-change-tilesets-open-street-map)
    - [5.2 Where to open the "Map Layer" side panel?](#52-where-to-open-the-map-layer-side-panel)
    - [5.3 "New Map Layer" not needed.](#53-new-map-layer-not-needed)
    - [5.4 Analysis on creating/destroying a map when changing tileset. (Qt-related limitation)](#54-analysis-on-creatingdestroying-a-map-when-changing-tileset-qt-related-limitation)
  - [6. Geometry \& Drawing Tools](#6-geometry--drawing-tools)
    - [6.1 Area drawing through tools or manual coordinates insertion](#61-area-drawing-through-tools-or-manual-coordinates-insertion)
    - [6.2 Vertex UI and labelling like A, B, C, etc. above each vertex when drawing a polygon/polyline.](#62-vertex-ui-and-labelling-like-a-b-c-etc-above-each-vertex-when-drawing-a-polygonpolyline)
  - [7. Alert Zones](#7-alert-zones)
    - [7.1 How do we get to the creation of alert zones though? Where is this in Figma?](#71-how-do-we-get-to-the-creation-of-alert-zones-though-where-is-this-in-figma)
    - [7.2 Management of alert zones](#72-management-of-alert-zones)
  - [8. Points of Interest (PoI)](#8-points-of-interest-poi)
    - [8.1 How do we get to the creation of PoIs? Where is this in Figma?](#81-how-do-we-get-to-the-creation-of-pois-where-is-this-in-figma)
    - [8.2 Management of PoIs.](#82-management-of-pois)
    - [8.3 Clicking on a PoI, opens up a side panel containing its data. (Look at the Payload artboard in Figma)](#83-clicking-on-a-poi-opens-up-a-side-panel-containing-its-data-look-at-the-payload-artboard-in-figma)
  - [9. Asset \& Track Management](#9-asset--track-management)
    - [9.1 Perhaps from the side rail, there's an icon which opens the panel for assets/tracks management.](#91-perhaps-from-the-side-rail-theres-an-icon-which-opens-the-panel-for-assetstracks-management)
    - [9.2 What _is_ an asset? Are tracks, PoIs, etc. considered assets?](#92-what-is-an-asset-are-tracks-pois-etc-considered-assets)
    - [9.3 Search for assets.](#93-search-for-assets)
    - [9.4 List of searched assets.](#94-list-of-searched-assets)
    - [9.5 Selecting assets somehow on the map.](#95-selecting-assets-somehow-on-the-map)
    - [9.6 Clicking an asset opens its details view.](#96-clicking-an-asset-opens-its-details-view)
    - [9.7 Track detail in side panel. (There's a task called "Payload Input Status" which is about integrating the legacy track's panel into the side panel.)](#97-track-detail-in-side-panel-theres-a-task-called-payload-input-status-which-is-about-integrating-the-legacy-tracks-panel-into-the-side-panel)
    - [9.8 UI cues when an asset is selected or being viewed.](#98-ui-cues-when-an-asset-is-selected-or-being-viewed)
  - [10. Video Streams](#10-video-streams)
    - [10.1 Perhaps from the side rail, click like a video icon and opens the video stream panel?](#101-perhaps-from-the-side-rail-click-like-a-video-icon-and-opens-the-video-stream-panel)
    - [10.2 Tabbed side panel with "Live" or "Offline".](#102-tabbed-side-panel-with-live-or-offline)
    - [10.3 Ability to add video.](#103-ability-to-add-video)
    - [10.4 List videos with thumbnail.](#104-list-videos-with-thumbnail)
    - [10.5 Video player.](#105-video-player)
  - [11. Accessibility](#11-accessibility)
    - [11.1 Keyboard navigation](#111-keyboard-navigation)
    - [11.2 Keyboard shortcuts](#112-keyboard-shortcuts)
    - [11.3 Screenreader support](#113-screenreader-support)
  - [12. Breaking Change Rework](#12-breaking-change-rework)
    - [12.1 Top Toolbar will be removed and integrated to the side panel.](#121-top-toolbar-will-be-removed-and-integrated-to-the-side-panel)
    - [12.2 Radial menu will be removed and integrated to the side rail/panel.](#122-radial-menu-will-be-removed-and-integrated-to-the-side-railpanel)
    - [12.3 Track panel (which opens up when a user selects a moving track) will be removed and integrated to the side panel.](#123-track-panel-which-opens-up-when-a-user-selects-a-moving-track-will-be-removed-and-integrated-to-the-side-panel)
    - [12.4 Map layer (all layers) is to be removed since each layer will have its own side panel.](#124-map-layer-all-layers-is-to-be-removed-since-each-layer-will-have-its-own-side-panel)
- [General Questions](#general-questions)
  - [Fincantieri](#fincantieri)
    - [F.1. Do we have UI as to when the user icon in the side panel is clicked?](#f1-do-we-have-ui-as-to-when-the-user-icon-in-the-side-panel-is-clicked)
    - [F.2. Why is there two versions of the map toolbar? One on the bottom and the other integrated in the title bar.](#f2-why-is-there-two-versions-of-the-map-toolbar-one-on-the-bottom-and-the-other-integrated-in-the-title-bar)
    - [F.3. What does the search bar in the title bar actually do?](#f3-what-does-the-search-bar-in-the-title-bar-actually-do)
    - [F.4. We don't need Mission right?](#f4-we-dont-need-mission-right)
    - [F.5. Why do side panel's icons in Figma sometimes there and sometimes aren't? For example:](#f5-why-do-side-panels-icons-in-figma-sometimes-there-and-sometimes-arent-for-example)
    - [F.6. Why is there an "X" in the Search Assets? Where are the other searches for like PoIs? Wait, is PoI an asset as well?](#f6-why-is-there-an-x-in-the-search-assets-where-are-the-other-searches-for-like-pois-wait-is-poi-an-asset-as-well)
    - [F.7. Where's the tool to select assets?](#f7-wheres-the-tool-to-select-assets)
    - [F.8. There's no mention of annotations or shapes. Do we still need it? If so, where's the UI to create one?](#f8-theres-no-mention-of-annotations-or-shapes-do-we-still-need-it-if-so-wheres-the-ui-to-create-one)
    - [F.9. How do we get to the video streams panel? Like does the side panel have its icon? The Figma doesn't show it. Also, why is there an "X" next to the "Video Stream List" label?](#f9-how-do-we-get-to-the-video-streams-panel-like-does-the-side-panel-have-its-icon-the-figma-doesnt-show-it-also-why-is-there-an-x-next-to-the-video-stream-list-label)
    - [F.10. The language side panel also have the "X", was it for?](#f10-the-language-side-panel-also-have-the-x-was-it-for)
    - [F.11. And do we really need "Save" for selecting a language?](#f11-and-do-we-really-need-save-for-selecting-a-language)
    - [F.12. We don't have a way to sign up or log in accounts. What are the plans on this?](#f12-we-dont-have-a-way-to-sign-up-or-log-in-accounts-what-are-the-plans-on-this)
    - [F.13. The map toolbar isn't part of the main skeleton:](#f13-the-map-toolbar-isnt-part-of-the-main-skeleton)
    - [F.14. What's the Home button for in the map toolbar?](#f14-whats-the-home-button-for-in-the-map-toolbar)
    - [F.15. There's an alert timeline with circled numbered items, what do they do? Do they open a modal/popup?](#f15-theres-an-alert-timeline-with-circled-numbered-items-what-do-they-do-do-they-open-a-modalpopup)
    - [F.16. Also what do the icons on the right do? The "right pointing to a vertical bar arrow" and "circled underlined check".](#f16-also-what-do-the-icons-on-the-right-do-the-right-pointing-to-a-vertical-bar-arrow-and-circled-underlined-check)
    - [F.17. What's EWS Network?](#f17-whats-ews-network)
    - [F.18. There's no "panning" (or hand) icon in the map toolbar:](#f18-theres-no-panning-or-hand-icon-in-the-map-toolbar)
  - [Technical](#technical)
    - [T.1. How should we handle the background color though?](#t1-how-should-we-handle-the-background-color-though)
    - [T.2. How many points can a polygon create? This can be in an application manifest handled by AppConfig or something like that.](#t2-how-many-points-can-a-polygon-create-this-can-be-in-an-application-manifest-handled-by-appconfig-or-something-like-that)


## Proposed Tasks

These are the proposed tasks. A goal approach is to have a bit of theoretical analysis on expected functionalities first then implementing it and discovering what's really needed for concrete implementations to be able to plan the correct approach and lessen the additional pre-analysis time which could be or could be not even implemented. And therefore this document tried its best to balance between concrete and abstract implementations of each task because going to the implementation details is best tackled when already doing the task.

### 1. Core Architecture & Design System

#### 1.1 Qt Model/View Architecture. (Should be an Epic by itself.)

- Migrate all models to Qt's architecture of handling models.

#### 1.2 Identification of base usable components

- As for base components like buttons, text, etc. Qt already provides these.
- We should check how to style them the Qt-way. (To deepen.)

#### 1.3 Centralized system for strings/texts.

- Basically to support easily changing languages. [3.2](#32-ability-to-change-language)

#### 1.4 Centralized management of application and/or user settings.

##### 1.4.1 Application Settings

- Like limits, configs, etc.
- It could or should act as a manifest file for the application.
- Manifest in the sense that it contains the paths of other configuration files.

##### 1.4.2 User Settings

Related: [4.3](#4-user-management)

- Handle local user preferences and other user related settings.
- Part of this is preferred language.
- Also are user settings also persisted online?

#### 1.5 App Base Skeleton

- Divisions between the different parts of the app.

#### 1.6 Theme management

- We only have one theme but it's worth to already write the code to be easily swapped with another theme if it'll exist.

#### 1.7 Modal/Popup management

- What will constitute as a modal? Or as a popup?
  - Because to me a modal takes the full screen with dim background while a popup can be moved around. (To deepen.)
- **Do we still need these movable popups?**
- Where should they be created? They should dynamically be created in the parent.
- Should we support multiple modals? (Stack-based.)
- We also need manager to tell which modal/popup is on the top of the stack of all other popups.
  - Should they have their own managers (modal and popup)?

#### 1.8 Siderail items configuration file maybe?

#### 1.9 Guidelines for folder structuring and naming

#### 1.10 Assets management.

- There's QRC but how should we use it well? I remember there being multiple .qrc files.

#### 1.11 Event/Communication system.

- There are signals and slots of Qt. But how should we decouple and make modular our communication between modules?
- I don't believe in a centralized global event manager, rather, the modules themselves have signals and slots that other modules can connect/disconnect to. This avoids recreating an event in two places (event manager and the module) and also manually handling event-handler maps.

#### 1.12 Singleton Manager-based approach?

- Currently, we eventually did something like singleton manager-based approach which solves coupling very well but I think a proper analysis on this should be made.

#### 1.13 Data filtering.

- Useful for searching. This is a task since Qt has a word on this ([QSortFilterProxyModel Class](https://doc.qt.io/qt-6/qsortfilterproxymodel.html)) that must be analyzed and learned to use.

#### 1.14 Data fetching management.

- Single file for all urls.
- Loading.
- Retry.
- Caching.
- Check if Qt's Network Access Manager has these functionalities. Or if there's a library for this like TanStack Query for web.

#### 1.15 Command Pattern (Undo/Redo)

- This is more linked to drawing but how should this be tackled if ever we want an undo/redo feature?

#### 1.16 Centralized app state.

- Current selected tool, etc.
- Like where do common global state be stored?

#### 1.17 Developer experience tooling.

- Linting.
- QML live reload? I think there's a tool for this that can be downloaded but probably a good nice-to-have.

#### 1.18 Notifications/Toast management.

- Provide standardized feedback for success/error/info events.
- Perhaps just like modal/popup, it's a global QML component latched onto the App component. To avoid nesting toasts.

#### 1.19 Application versioning.

- How should we deal with our own modules' versioning? Should we already implement a standard for this?

#### 1.20 Internal documentation guidelines.

- Explain how should the application should be extended.
- What to do and not to do.
- What to avoid.
- What to keep in mind.
- Etc.

#### 1.21 Role management?

- Should we already be thinking of roles? Probably overkill for now.

#### 1.22 Testing.

- Learn how to use Qt's testing modules to write unit tests.

#### 1.23 Offline support.

- What happens if there's no connection?
- A notification (toast) should pop up if connection falls.

#### 1.24 Performance reviews.

- Stress testing (like multiple map objects), etc.
- Qt Map _does_ support viewport culling which does not render map objects outside the viewport but how much does Qt handle this culling?

#### 1.25 Race Conditions

- Like when two people are changing the same PoI. (Maybe a notification if one PoI has been changed.)

### 2. Global Layout & Navigation

The side panel during analysis is realized as a core part of the application. A lot of functionalities depend on the side panel. Do not confuse side rail with side panel. Side rail contains the icons which opens up their respective side panel.

One of main goal is to avoid ambiguity by giving each component a self-descriptive and non-conflicting names.

#### 2.1 Side rail.

##### 2.1.1 Side menu items management system.

- For example, vscode has this feature where a menu item can pop inside the side panel even though it isn't really there at first. I think we need this for certain features.
- Also where are the menu items stored? In the sense that we should have an easy to extend side panel's menu items configuration file or something like that. [1.8](#18-siderail-items-configuration-file-maybe)
- Does the side rail contain Asset, etc.?

##### 2.1.2 Expand/Collapse side panel icon near the user profile's icon

##### 2.1.3 User Icon

- Below the siderail there's the user profile icon.
- Possible popup when clicked. (There's no Figma here I think. Also what will the popup contain?)

#### 2.2 Side panel.

##### 2.2.1 Side panel content depending on chosen side rail icon

##### 2.2.2 Wizard/Stepper functionality

- Must be navigable like Wizard/Stepper/Pagination. Perhaps this is a component in itself.

#### 2.3 Titlebar

##### 2.3.1 Analysis on how to hide system default's title bar with a customized one.

##### 2.3.2 Date and time.

##### 2.3.3 Tab bar. (The one with the Overview text)

- It was stated in the call that this feature is to be evaluated.

##### 2.3.4 Change language.

##### 2.3.5 Search bar.

- What does the search bar actually do? Because it conflicts with a search bar in the "Search" of the side rail.

##### 2.3.6 Window related icons. (Minimize/Maximize/Close)

#### 2.4 Map Toolbar

##### 2.4.1 Map tileset switcher icon.

##### 2.4.2 Home button?

- What does it actually do?

##### 2.4.3 Current position button.

##### 2.4.4 Zoom controls: increase and decrease.

#### 2.5 Alert Panel

##### 2.5.1 Alert timeline.

- I think this has the list of alerts/notifications.

##### 2.5.2 Arrow pointing to right with vertical bar?

- What's this for?

##### 2.5.3 Circled underlined check?

- What's this for?

#### 2.6 Context Panel (should we call it this way for general use?)

##### 2.6.1 Assets/tracks list

- List available tracks with icons. (Like submarine in the Figma)

### 3. Multilingual Support

#### 3.1 From the title bar, there's the "world" icon which opens up the language side panel.

#### 3.2 Ability to change language.

### 4. User Management

#### 4.1 Authentication/Registration

#### 4.2 User Details Modification

- Profile picture, settings, etc.

#### 4.3 User Settings Modification

- Preferred language, etc.

### 5. Map & Layers

#### 5.1 Ability to change tilesets. (Open Street Map)

#### 5.2 Where to open the "Map Layer" side panel?

#### 5.3 "New Map Layer" not needed.

#### 5.4 Analysis on creating/destroying a map when changing tileset. (Qt-related limitation)

### 6. Geometry & Drawing Tools

#### 6.1 Area drawing through tools or manual coordinates insertion

#### 6.2 Vertex UI and labelling like A, B, C, etc. above each vertex when drawing a polygon/polyline.

### 7. Alert Zones

#### 7.1 How do we get to the creation of alert zones though? Where is this in Figma?

#### 7.2 Management of alert zones

- Creation/modification/deletion of alert zones

### 8. Points of Interest (PoI)

#### 8.1 How do we get to the creation of PoIs? Where is this in Figma?

#### 8.2 Management of PoIs.

#### 8.3 Clicking on a PoI, opens up a side panel containing its data. (Look at the Payload artboard in Figma)

### 9. Asset & Track Management

#### 9.1 Perhaps from the side rail, there's an icon which opens the panel for assets/tracks management.

#### 9.2 What _is_ an asset? Are tracks, PoIs, etc. considered assets?

#### 9.3 Search for assets.

#### 9.4 List of searched assets.

#### 9.5 Selecting assets somehow on the map.

- List selected assets.
  - Should the list be scrollable or paginated?
  - Open a details view when clicked on a selected asset.

#### 9.6 Clicking an asset opens its details view.

#### 9.7 Track detail in side panel. (There's a task called "Payload Input Status" which is about integrating the legacy track's panel into the side panel.)

#### 9.8 UI cues when an asset is selected or being viewed.

### 10. Video Streams

#### 10.1 Perhaps from the side rail, click like a video icon and opens the video stream panel?

#### 10.2 Tabbed side panel with "Live" or "Offline".

- Right now, only "Offline" is requested but write the code in the way it can be extended for "Live" as well.

#### 10.3 Ability to add video.

#### 10.4 List videos with thumbnail.

- Click on video to open the video player.
- Video management: deletion. (Renaming?)

#### 10.5 Video player.

### 11. Accessibility

#### 11.1 Keyboard navigation

#### 11.2 Keyboard shortcuts

#### 11.3 Screenreader support

### 12. Breaking Change Rework

#### 12.1 Top Toolbar will be removed and integrated to the side panel.

#### 12.2 Radial menu will be removed and integrated to the side rail/panel.

#### 12.3 Track panel (which opens up when a user selects a moving track) will be removed and integrated to the side panel.

#### 12.4 Map layer (all layers) is to be removed since each layer will have its own side panel.

## General Questions

### Fincantieri

#### F.1. Do we have UI as to when the user icon in the side panel is clicked?
#### F.2. Why is there two versions of the map toolbar? One on the bottom and the other integrated in the title bar.

![map toolbar in title bar](.attachments/ui-rework-analysis/map-toolbar-in-title.png)

#### F.3. What does the search bar in the title bar actually do?

#### F.4. We don't need Mission right?

#### F.5. Why do side panel's icons in Figma sometimes there and sometimes aren't? For example:

![siderail icons](.attachments/ui-rework-analysis/siderail-icons.png)

#### F.6. Why is there an "X" in the Search Assets? Where are the other searches for like PoIs? Wait, is PoI an asset as well?

![search assets](.attachments/ui-rework-analysis/sidepanel-search-assets.png)

#### F.7. Where's the tool to select assets?

#### F.8. There's no mention of annotations or shapes. Do we still need it? If so, where's the UI to create one?

#### F.9. How do we get to the video streams panel? Like does the side panel have its icon? The Figma doesn't show it. Also, why is there an "X" next to the "Video Stream List" label?

#### F.10. The language side panel also have the "X", was it for?

#### F.11. And do we really need "Save" for selecting a language?

![language side panel](.attachments/ui-rework-analysis/sidepanel-languages.png)

#### F.12. We don't have a way to sign up or log in accounts. What are the plans on this?

#### F.13. The map toolbar isn't part of the main skeleton:

![mising map toolbar](.attachments/ui-rework-analysis/missing-map-toolbar.png)

#### F.14. What's the Home button for in the map toolbar?

#### F.15. There's an alert timeline with circled numbered items, what do they do? Do they open a modal/popup?

#### F.16. Also what do the icons on the right do? The "right pointing to a vertical bar arrow" and "circled underlined check".

![alert panel](.attachments/ui-rework-analysis/alert-panel.png)

#### F.17. What's EWS Network?

![context panel listing assets](.attachments/ui-rework-analysis/context-panel-assets-list.png)

#### F.18. There's no "panning" (or hand) icon in the map toolbar:

![map toolbar](.attachments/ui-rework-analysis/map-toolbar.png)

### Technical

#### T.1. How should we handle the background color though?
#### T.2. How many points can a polygon create? This can be in an application manifest handled by AppConfig or something like that.
