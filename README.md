psykopaint2-application
=======================

The robotlegs based Psykopaint 2 application repository.

Dependencies:
---------------
* psykopaint2-core-dependencies at https://github.com/psykosoft/psykopaint2-core-dependencies
* Swiftsuspenders-v2.0.0rc3stray1.swc at psykopaint2-core-dependencies/robotlegs-framework/lib/

How to do release builds on Intellij Idea:
-------------------------------------------
* Make sure options in Settings.as are optimal for release.
* Make sure ALL involved projects have <option name="additionalOptions" value="-debug=false" /> and <entry key="compiler.debug.swf" value="false" />
* Make sure Intellij -> Preferences -> Compiler -> Flex is set to mxml and ASC 2.0 is selected.
* Build -> Package AIR Application ( ad hoc distribution ).