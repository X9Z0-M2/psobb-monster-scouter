## Semi-Automatic Updating
Rather than having to download each new version of this addon, extract it, and place inside the appropriate "addons" folder there is a fairly simple way to set up one click updating which involves making use of GitHub Desktop clone and pull features.

_Please review Github's Docs on connecting and cloning repos if you'd like to learn more. There are a multitude of methods ranging from git cli, personal action tokens to ssh keys, and the github cli tool._

### Github Desktop
This is by far the easiest and most intuitive way of accessing repositories, and doesn't require one to have knowledge of git (although it helps), or methods of authentication.

Some deciphered terms for you:
* Clone = Copy and Download all the code locally (to your system)
* Fetch = Lookup what was changed
* Pull = Download latest changes into your cloned folder

_Clone is alot like setting up a dropbox or google drive whereas Fetch and Pull (together) are akin to syncing to the cloud._

#### Steps:

1. [Installing Github Desktop](https://docs.github.com/en/desktop/installing-and-authenticating-to-github-desktop/installing-github-desktop)

2. [Authentication for Github Desktop](https://docs.github.com/en/desktop/installing-and-authenticating-to-github-desktop/authenticating-to-github-in-github-desktop)
    * You'll need to get Github Desktop authenticated with your account and signed in before you're able to use it.

3. [Cloning with Github Desktop](https://docs.github.com/en/desktop/adding-and-cloning-repositories/cloning-a-repository-from-github-to-github-desktop)
    * Clone the psobb addon via github desktop
    * I'd recommend creating a folder outside of your psobb install folder, as it is likely that if the game ever needs to be uninstalled or reinstalled everything inside will be deleted.

4. [Symlink From Clone to addons Folder](https://blogs.windows.com/windowsdeveloper/2016/12/02/symlinks-windows-10/) | [Another Site outlining the process](https://www.howtogeek.com/16226/complete-guide-to-symbolic-links-symlinks-on-windows-or-linux/)
    * Go inside the "addons" folder and make sure a folder called "Drop Radar" does NOT exist, delete it if so.
    * Run Command Prompt as administrator.
    * The basic "Command Prompt" command is as follows:
        * `mklink /D [DESTINATION] [SOURCE]`
        * example: 
            * `mklink /D "C:\Users\x9z0\EphineaPSO\addons\Drop Radar" "C:\Users\x9z0\GithubDesktop\psobb-drop-radar\Drop Radar"`
    * If the "Drop Radar" folder inside of the "addons" folder was missing before and is now present after running the command, it has worked!

    * You can double-check this worked by opening the "addons" folder. There should be a special icon on the "Drop Radar" folder that looks like a shortcut. (has a small curved arrow on the bottom left). If your system icons are custom/non-default or even fudged by freeware/malware (_not a result of this process here or this addon!_), it may look different than described. 

5. [Fetch and Pull Changes to Local (repeat)](https://docs.github.com/en/desktop/working-with-your-remote-repository-on-github-or-github-enterprise/syncing-your-branch-in-github-desktop#pulling-to-your-local-branch-from-the-remote)
    * Doing this will allow you to one-click sync the latest changes and get the newest version that might be released to the addon.
    * You might do this from time to time, or when the addon has a bug - the bug might have been fixed!

