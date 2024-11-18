## Drop Chart Updater
Occasionally Ephinea will update its drop chart tables and you'll need to that change to reflect in your addon with correct rates and drops. The update script will replace with the latest charts directly into the ```Monster Scouter/Drops/``` folder.

### Use a virtual environment
**NOTE: This is highly recommended!**

#### Create the virtual environment (for the first time):
```
python -m venv ./.env
```

#### Use the virtual environment:
windows:
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\.env\Scripts\Activate.ps1
```

linux:
```
source env/bin/activate
```


### Install Dependencies

```
pip install -r requirements.txt
```

### Run Script

```
python dropchart_updater.py
```
