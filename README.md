# linux-org-helpers

Helpers to improve Linux experience

## project-command-collection.sh

* With this script you can run a collection of arbitrary commands as your flexible command menu for more effective working

* The user defines a "settings" Bash file, in which an array named OPTIONS is declared.

* Inside the **OPTIONS** array, the user can specify as many lines as they like
  
  * each line must follow this format: **description#newWindowFlag#command**
  
  * **description** : the text that will appear in the menu when selecting this option
  
  * newWindowFlag: can be true, false, or [path]
    
    * **true**  = open a new terminal (no custom working directory) and run the command there
    
    * **false** = execute the command in the current terminal window
    
    * **[path]** = same as “true”, but the newly opened terminal changes to [path] before executing the command
  
  * **command** : any valid shell command. You must take care of quoting and escaping (e.g. when to wrap in quotes or escape spaces). Refer to other sources if needed.

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
