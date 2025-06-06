# linux-org-helpers

Helpers to improve Linux experience

## project-command-collection.sh

* With this script you can run a collection of arbitrary commands as your flexible command menu for more effective working

* The user defines a "settings" Bash file, in which an array named OPTIONS is declared.

* Inside the **OPTIONS** array, the user can specify as many lines as they like
  
  * each line must follow this format: <code>"description#newWindowFlag#command"</code> OR <code>"-"</code>
  
  * **description** : the text that will appear in the menu when selecting this option
  
  * newWindowFlag: can be true, false, or [path]
    
    * **true**  = open a new terminal (no custom working directory) and run the command there
    
    * **false** = execute the command in the current terminal window
    
    * **[path]** = same as “true”, but the newly opened terminal changes to [path] before executing the command
  
  * **command** : any valid shell command. You must take care of quoting and escaping (e.g. when to wrap in quotes or escape spaces). Refer to other sources if needed.
  
  * Dash <code>"-"</code> : If the user just uses dash then a line will be printed to separate options optically. This will NOT affect the choice numbers however

* The user may also use the variable <code>$DIR</code> inside OPTIONS; $DIR will contain the parent directory of the config file.

* example call (you can also add the path to the <code>$PATH</code> variable) <code>/home/user/project-command-collection.sh /home/user/project1/project-cmd-config.sh</code> with this content in the config file
  
  ```
  #!/bin/bash
  
  OPTIONS=(
   "Git add commit push#$DIR/01 DEV#./git-solo-push.sh"
   "Terminal in project folder#$DIR#clear"
   "VSCode in code folder#false#code \"$DIR/01 DEV/susi-repo\""
   "Todo for proejct#false#setsid mousepad '$DIR/live-log.txt' >/dev/null 2>&1 &"
   "Edit this list#false#nohup gedit '$DIR/project-cmd-config.sh' >/dev/null 2>&1 &"
  )
  ```

## Version numbers

- I'm experimenting with a new versioning format for dense informative content. As I did not find any mention of this idea I call it "**Date-Impact Versioning (or DI-Versioning or  DIV)**".

- Structure <code>YYYYMMDD-<Major><S|M|L>-<Minor><S|M|L>-<Patch><S|M|L></code>
  
  - The first part is the date in this format YYYYMMDD
  
  - Then follows the classical versioning with major-minor-patch, separated by dashes for better visibility (for example on websites where links are underlined and dots are hardly visible)
  
  - All version also have either the letter S (small), M (medium) or L (large) behind one of the version digits. This simulatenously indicates which change was the latest one and how much impact this change had. For example you could implement a breaking change and therefore would formally have to increase the major version, but in reality that's not a big deal for most users and would therefore get an S. Or you could fix a security bug, which could have a huge impact and would therefore warrant an L rating. This would be subjective, but as this would also just be informative the subjective nature is welcome
  
  - Contrary to most CalVer systems the date at the beginning is merely informativ but at the same time helpful when auto-sorting files in the file system

- Example `20250605-1L-0-0`
