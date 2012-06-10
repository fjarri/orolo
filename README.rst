Orolo, yet another clock menulet
================================

Idea: does not show you anything until there is something in your iCal nearby.
Then it shows the event and slowly changes color to red.

Release history
---------------

Future
~~~~~~

- Click on event to go to iCal
- Set global hotkey for Show Real Time in Preferences
- A way to specifically mark events (like, process only start date etc). Notes maybe?
- Add localization (at least remove string hardcoding)
- Menulet can be moved around the menubar, like others (with Cmd key pressed). - seems to be impossible
- Set the interval between timer updates in Preferences (governs the smoothness of color change)
- Add "always real time mode" for cases when one needs to turn off the oven in 20 minutes or something
- Add 12/24 and AM-PM/not switch, to mimic usual clock (or take these from System Preferences)
- Add showing date too
- Remove all hardcoding
- Make text in status bar more aesthetical

0.0.1
~~~~~

- Context menu: full event title, Show Real Time (in case the current time is needed for some reason), Preferences, Quit
- Show Real Time:
  - Has a global hotkey (fixed)
  - Shows time for 5 seconds
- Preferences:
  - Changes are applied instantly
  - Start at launch
  - Set fade-in and fade-out colors and time frame
    - Time is set with sliders, ranges from 1 min to 60 min (1, 2, 3, 5, 10, 15, 20, 30, 40, 50, 60)
    - For fade-out, 0 is also available
  - List of calendars to get events from
    - Multiple choise
    - Dynamically updated
    - When the calendar is removed, stop watching it (shouldn't be any error thrown)
  - Maximum title length
  - Some pop-up help for elements of preferences
- Status element:
  - Show only start of the event title
  - The full title is shown as a first line in context menu
  - Color saturation is proportional to the distance from now
