# Description:
#     Github issue link looks for #nnn and links to that issue for your default
#     repo. Eg. "Hey guys check out #273"
#     Defaults to issues in HUBOT_GITHUB_REPO, unless a repo is specified Eg. "Hey guys, check out awesome-repo#273"
#
# Dependencies:
#     "githubot": "0.4.x"
#
# Configuration:
#     HUBOT_GITHUB_REPO
#     HUBOT_GITHUB_TOKEN
#     HUBOT_GITHUB_API
#     HUBOT_GITHUB_ISSUE_LINK_IGNORE_USERS
#
# Commands:
#     GHnnn - link to GitHub issue nnn for HUBOT_GITHUB_REPO project
#     repo#nnn - link to GitHub issue nnn for repo project
#     user/repo#nnn - link to GitHub issue nnn for user/repo project
#
# Notes:
#     HUBOT_GITHUB_API allows you to set a custom URL path (for Github enterprise users)
#
# Author:
#     tenfef

module.exports = (robot) ->
    gitlab = (require 'gitlab')
      url:   process.env.HUBOT_GITLAB_URL
      token: process.env.HUBOT_GITLAB_TOKEN
    _ = require 'underscore'

    gitlabIgnoreUsers = process.env.HUBOT_GITLAB_ISSUE_LINK_IGNORE_USERS
    if gitlabIgnoreUsers == undefined
        gitlabIgnoreUsers = "hubot"

    rx = /\S*GL(\!?\d+)\S*/g

    robot.hear rx, (msg) ->
        return if msg.message.user.name.match(new RegExp(gitlabIgnoreUsers, "gi"))
        txt = msg.message.text
        match = rx.exec(txt)
        issues = []
        while match != null
            issue_number = match[1]
            # if isNaN(issue_number)
            #     break
            issues.push(issue_number)
            match = rx.exec(txt)

        bot_gitlab_repo = process.env.HUBOT_GITLAB_URL + process.env.HUBOT_GITLAB_REPO

        _.uniq(issues).map (issue_number) ->
            issue_title = ""
            base_url = process.env.HUBOT_GITLAB_URL
            gitlab_repo = process.env.HUBOT_GITLAB_REPO

            url = "#{base_url}/#{gitlab_repo}/issues/#{issue_number}"

            iid = issue_number
            apiUrl = "projects/" + encodeURIComponent(gitlab_repo) + "/issues";
            if issue_number[0] == "!"
                iid = issue_number.substr(1)
                apiUrl = "projects/" + encodeURIComponent(gitlab_repo) + "/merge_requests";

            gitlab.get apiUrl, {iid: iid}, (error, res) ->
                if !error && res.length
                    msg.send "#{url}<<GL#{issue_number}>>: #{res[0].title}"
