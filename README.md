# Brew With A View
## Enhanced Meditation & Alchemy

![thumbnail](https://github.com/user-attachments/assets/1de3414e-160d-4e22-b70e-a69483d138d0)

### Features
- Meditate whilst seeing the world around you.
- Seamless camera transitions from exploration to Meditation and back.
- Supports both Default and Close exploration camera settings.
- Adjusted layout and new appear animation for the Meditation UI.
- (Optional) The Meditation UI includes a prompt to open the Alchemy menu.
- Open the Alchemy menu during Meditation to brew potions, oils etc.
- (Optional) Crafting an Alchemy item advances the game time by 15 minutes.
- (Optional) Alchemy is prohibited outside of Meditation or a herbalist, though you can still access the menu at any time.
- Quest items can always be crafted, even outside of Meditation or a herbalist, and do not advance time.
- Full support for the Corvo Bianco bed, with minor UI tweaks and unchanged functionality.
- The Corvo Bianco Alchemy Table works as normal.
- (Optional) When in the wilderness Geralt will light a campfire when starting meditating, and put it out when stopping.
- Supports both gamepad and keyboard.

### Compatibility
- Incompatible with other similar mods, including Friendly Meditation, Preparations and Immersive Meditation. This mod aims to achieve similar things to these great mods in subtly different ways, and is intended as an alternative to them.
- Compatible with Simple Alchemy Refill (Brew With A View was made with this mod in mind, and I think the combination is great, that being said, it's not required, just highly recommended).
- Compatible with Swords and Meditation (another highly recommended combination, this will add Geralt's swords, crossbow and misc Alchemy items around the campfire, and really adds to that sense of preparation. Note: my mod will sometimes not spawn a campfire e.g. in an interior. However, Swords and Meditation will always spawn the items. So sometimes you will have items and no campfire when using these mods together. This isn't a major issue, and looks fine in my opinion, but is something to be aware of. I recommend editing the mod to remove the code using gamepad direction buttons to change the positions of the items, so you can use them instead to navigate the clock menu, if you'd like help with this, let me know!)
- Compatible with Brothers In Arms (probably the only must have mod!)
- Compatible with font replacers.
- Compatible with Smooth GUI (highly recommended). Just let this mod win any .redswf conflicts. I haven't made any changes to Meditation UI animation speeds to match Smooth GUI, but from playtesting it didn't feel like it needed anything. Please let me know if I missed something.
- This mod makes use of script annotations to reduce merge conflicts, but you should still always run Script Merger!

### Technical
- Current version: 1.3-dev
- The mod was formerly known as Alchemy Requires Meditation, the REDkit project retains this name and is frequently referenced in the project files.
- If you are looking for my changes inside .ws or .as files, search for "modcrab".
- Mod ID Space: 13425894

### Changelog
#### 1.1
- Hotfix to improve folder structure. Thank you to ElementaryLewis for pointing this out.
#### 1.2
- Added Russian translation. Thank you to Arkwulf for this.
- Added Hungarian translation. Thank you to Gergo900410 for this.
- Default to English for unlocalized languages in order to fix empty button prompts. Thank you to RovanFrost for pointing this out.
#### 1.3
- (Optional) Add a confirmation screen when switching tabs in the menu, before starting Meditation. A common scenario was that you would access your Inventory, and switch tabs with the shoulder buttons looking for another menu. You would accidently go to the Meditation panel, and it would kick you out into Brew With A View's new Meditation mode. This new feature would isolate this case, asking for confirmation first, and prevents accidently starting Meditation when you don't want to. It will remain optional, though.
- (Optional) Added an option to control the Camera Style. You can choose between the Brew With A View Default look, or a Close style like Geralt appears on the Main Menu.
- (Optional) Add a Manual Camera Control option, allowing you to pan the camera around after Geralt has entered the meditation pose.
- Prevented the HUD reappearing between the Radial Menu/Alchemy/other menus closing, and the overlayed Meditation menu opening.
- Fixed camera transitions when entering and exiting Meditation not working when playing with the 'Auto camera centering' option disabled.
- Fixed the game not properly pausing whilst resting in Corvo Bianco.
- Restored needlessly removed glow effect when the Meditation clock stops moving.
- (Keyboard) Pressing N during meditation will now function like pressing Escape.
- (Keyboard) Fixed the mouse cursor sometimes snapping when starting Meditation.
- (Keyboard) Fixed the mouse cursor snapping to the centre of the screen when opening another menu during Meditation.
- (Keyboard) Fixed the Alchemy prompt [L] losing it's square braces after meditating once.
- (Keyboard) Fixed the text on the input prompts on the Meditation menu not being centered.
- (Spanish) Fixed some missing accents.
- (French) Fixed some missing accents.
- Miscellaneous tweaks, fixes and improvements that are too small to mention.


### Permissions
- MIT Licence. Feel free to do whatever you like, I only ask that you credit me as the original author.

### Credits
- A huge thank you to wghost81 and ksolberg for their mods Friendly Meditation, Preparations and Immersive Meditation, which served as a source of inspiration for this mod as well as a great reference point for how to achieve certain things.
- Thank you to Aeltoth, Spontan, Focusnoot and ElementaryLewis on the Wolven Workshop Discord for helping me troubleshoot various issues I had throughout the development of this mod.
- Thank you to lupo_bianco89 for their save file Game plus DLC HOS and BaW Complete for NG plus, and Kromanjon for their save file Main story and Hearts of stone done, which were of great help in testing the mod.
- Thank you to my friend Lily for help translating the mod to French, Italian and Spanish.
- Thank you to my friend Charlie for help with the mod page.
- Thank you to JoannaVu for the brilliant thewitcher font.
- Thank you to CDPR for making such an awesome game and giving us the tools to mod it!
