#!bz
// https://mvnrepository.com/artifact/org.kohsuke/github-api
//@Grapes()

@Grab(group='org.kohsuke', module='github-api', version='1.308')

import org.kohsuke.github.GitHub
import org.kohsuke.github.GitHubBuilder

//def github = GitHub.connect();
def github = new GitHubBuilder().withOAuthToken('**************************************').build();

def repo = github.getRepository("bazurto/groovy")

def releases = repo.listReleases()

releases.each({ it ->
  if (it.draft == false) { return }
  if (it.prerelease == true) { return }
})

System.exit(9)


