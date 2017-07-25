# gitsync

Mirrors git repositories

## Limitations

* `lfs` is not supported yet.
* It's a _quick an' dirty_ script, so: **Do not use in production environment**
* Only tested by mirroring _gitlab_ repositories to _github_ for now
* Works only if your repositories are reachable via `ssh` 

## Installation

* Put `bin/gitsync.sh` in directory of your choice.
* Make it executable: `chmod +x bin/gitsync.sh`
* you need to configure your ssh client not to ask for credentials if you want to use it in batch mode

## Configuration

Create a configuration file at a location of your choice in `json` format, for example `/etc/gitsync/pairs.json`

Example:

```json
[
  {
    "source": "ssh://git@gitlab.yourdomain.de/yourgroup/repo1.git",
    "destination": "git@github.com:youruser/repo1-mirror.git",
    "branch": "dev"
  },
  {
    "source": "ssh://git@gitlab.yourdomain.de/yourgroup/repo2.git",
    "destination": "git@github.com:youruser/repo2-mirror.git"
  },
  {
    "source": "ssh://git@gitlab.yourdomain.de/yourgroup/repo3.git",
    "destination": "git@github.com:youruser/repo3-mirror.git"
  }
]
```

The file must contain  an array with item with the following keys:

* **`"source"`**: Source repository (required)
* **`"destination"`**: Destination repository (required)
* **`"branch"`**: Branch to mirror, set to **`"*"`** for all branchs (optional, default: **`"master"`**) 

## Execute

`path/to/your/bin /etc/gitsync/pairs.json` 


