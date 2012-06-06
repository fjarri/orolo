Orolo, yet another clock menulet
================================

Idea: does not show you anything until there is something in your iCal nearby.
Then it shows the event and slowly changes color to red.

Release history
---------------

0.0.1
~~~~~

- Context menu: full event title, Show Time (in case the current time is needed for some reason), Preferences, Quit
- Show time - how will it work? Show for fixed interval, show until next event? Former is better, but harder to implement
- Synchronize with chosen calendar(s) from iCal (set in preferences)
  - When the calendar is added or removed in appears instantly in preferences (can we do that?)
  - When the calendar is removed, stop watching it (shouldn't be any error thrown)
- Show only start of the event title in the status bar
  - The limit on title length is set in preferences
  - The full title is shown as a first line in context menu
- Set the looking-forward interval in preferences
  - Fade in the closest event
  - Color is set in preferences, proportional to distance from now
- Set the looking-backward interval in preferences
  - When there are no forward events, slowly fade away the last event
  - Color is set in preferences, proportional to distance from now
- Find a way to specifically mark events (like, process only start date etc). Notes maybe?
