#!/usr/bin/env groovy

@Grab('com.konghq:unirest-java:3.11.09')


public class Global {
    public static String token;
    public static String baseUrl = "https://api.github.com"
}
Global.token = System.env.GITHUB_TOKEN;

if (!Global.token) {
    println "";
    println "GITHUB_TOKEN is required";
    println "";
    System.exit(-1);
}

if (args.size() < 2) {
    println "";
    println "Usage ./command <owner>/<repo> <version>";
    println "";
    println "      ./command hcm/myApiRepo 1.2";
    println "";
    System.exit(-1);
}

def ownerRepo       = args[0];
def majorMinor  = args[1];

def (owner, repo) = ownerRepo.split("/");

def buildno = getBuildNumber(owner, repo, majorMinor);
println buildno;


def getBuildNumber(owner, repo, majorMinor) {
    def token = Global.token;
    def dataTag = "data/v$majorMinor"
    def buildno = "0";
    def response = gh(GET: "https://api.github.com/repos/$owner/$repo/git/ref/tags/$dataTag").asJson()
    if (response.getStatus() == 200) {
        def blobUrl = response?.getBody().getObject().getJSONObject("object").getString("url")
        def buildnoBytes = gh(GET: blobUrl).asJson()?.getBody()?.getObject()?.getString("content")?.decodeBase64()

        if (buildnoBytes != null) {
            buildno = new String(buildnoBytes).trim()
        }
    }
    return buildno as Integer;
}

def gh(Map m) {
    def uri;
    def method;
    def data = null;

    if (m.GET) {
        uri = m.GET;
        method = "GET";
    } else if (m.POST) {
        uri = m.POST
        method = "POST"
        if (m.body) { data = m.body; }
    } else if (m.PATCH) {
        uri = m.PATCH
        method = "PATCH"
        if (m.body) { data = m.body; }
    }

    def ur;
    if (method == "GET") {
        ur = kong.unirest.Unirest.get(uri)
    } else if (method == "POST") {
        ur = kong.unirest.Unirest.post(uri)
    } else if (method == "PATCH") {
        ur = kong.unirest.Unirest.patch(uri)
    }

    ur = ur.header("Authorization", "Bearer ${Global.token}")
           .header("Accept", "application/vnd.github+json");

    if (method == "POST" || method == "PATCH") {
        if (data != null) {
            def body = groovy.json.JsonOutput.toJson(data);
            ur = ur.header("Content-Type", "application/json").body(body);
        }
    }
    return ur;
}
