# Prerequisites

Ensure you have mkdocs installed. This can be done with:

```
pip install mkdocs
```

# Making changes

Fork a copy to your own repo, then clone it locally. Make any edits you wish to edit. To see what your edits look like, run:

```
mkdocs serve
```

In the same directory as your mkdocs.yml file. This will spin up a local web server for you to view what the docs look like. Make sure you’re satisfied with your edits.

Once you’re happy with the content and layout, commit and push to your repo.

Then, make a pull request back to the main repo, and request a review (or wait till someone notices).

Once changes have been accepted to master, they will automatically build in a PRIVATE version of the docs on the readthedocs.io site. 

When maintainers are happy with the content and the time is right, cut a new release on the repo, which tag a release. A webhook will notify readthedocs which will then build a new version. 

Maintainers can then change the “latest” tag to match the new release. When the 
latest release should be promoted to stable, the pointer on the readthedocs site can be updated under “Versions”.
