# Ubuntu - Behringer UMC 404 Fix
A simple bash script resolving the issue of only rear channels being used in default Ubuntu installation.

## Why it Exists?
After deciding to switch to ubuntu, I realized my UMC 404 wasn't working out of the box. Simple test on the speaker test section in sound settings shows the issue: UMC404 is recognized as 4 channel surround system and entire sounds are playing on rear channels (Rear Left and Rear Right) while the PipeWire uses front channels as default output, and no obvious (at least to me) way to merge front and back channels. So after having a chat with a non-human friend of mine, I figured out the solution and decided to share it so others might save some time.

Currently confirmed to be working fine on Behringer UMC404HD (should probably work fine with UMC202 or basically any UMC series, but I only tested it with my 404)

## You know any other audio interface with exact solution?

Feel free to open a PR. Might even use folders for manufacturer, if this is a known issue.

## You want to improve the Readme? You tested in <foo> OS and confirm it's working?
Feel free to open a PR and populate the list.
