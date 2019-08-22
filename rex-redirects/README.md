Concourse pipeline for updating CNX's REX redirects
===================================================

This is a concourse pipeline that is triggered by new versions of
https://staging.openstax.org/rex/environment.json (configurable), regenerates
the `rex-uris.map` files based on what books are on the rex release, pushes a
branch in cnx-deploy called `update-rex-redirects-staging` (configurable) and
creates a pull request for developers to review.

There are a number of variables that this pipeline uses.  You will need to set
these up.

1. Copy `vars.yml.example` to `vars.yml`:

   ```
   cp vars.yml.example vars.yml
   ```

2. Paste your existing private github ssh key in `git-private-key`.

   1. Alternatively, you can generate a new one using `ssh-keygen`.  See
      github's guides
      https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
      and
      https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account

3. Fill in `git-author-name` and `git-author-email`.  These are used as the
   author of the commits for updating `rex-uris.map` files.

4. Decide which `rex-domain` this pipeline is watching, for example,
   `staging.openstax.org` for non prod environments.

5. Create a github token for the pipeline to create a pull request.

   1. Log in at github.com
   2. Go to github.com and select `settings` from the top right menu
   3. Click on `developer settings`
   4. Click on `personal access tokens`
   5. Select `public_repo` and save
   6. Copy and paste the token into the `github-token` field

6. Put in the github usernames of all the users that should review the pull
   request, separated by commas in `reviewers`.

