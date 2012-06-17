Orolo, yet another clock menulet
================================

The menulet does not show anything until there is something in your iCal nearby (either a start or the end of the event).
Then it shows the event title and slowly changes its color from black to user defined (fade-in), and after the event has passed, back to black (fade-out).
In addition, by hotkey you can briefly look at current time, look how long it is untill the closest event in the future (not further than a day), and switch to a real-time mode, when the menulet is indistinguishable from system clock.

Release history
---------------

Future
~~~~~~

- Click on event to go to iCal
- A way to specifically mark events (like, process only start date etc). Notes maybe?
- Set the interval between timer updates in Preferences (governs the smoothness of color change)
- Show date/weekday near the clock
- Make text in status bar more aesthetical
- Use sliders for intervals in Preferences?
- Set global hotkeys in Preferences
- Fix possible bug when the timer for Constant Real Time may not be initialized if the call is very close to the whole minute border

1.0.0
~~~~~

- Removed all hardcoding
- Added localization stub
- Added "Show time till closest event" and "Always real time" mode
- Placing menu item to the right of the clock

0.0.1
~~~~~

Initial version.
