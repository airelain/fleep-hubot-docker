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
    github = require("githubot")(robot)
    _ = require 'underscore'

    githubIgnoreUsers = process.env.HUBOT_GITHUB_ISSUE_LINK_IGNORE_USERS
    if githubIgnoreUsers == undefined
        githubIgnoreUsers = "github|hubot"

    rx = /\S*GH(\d+)\S*/g

    robot.hear rx, (msg) ->
        return if msg.message.user.name.match(new RegExp(githubIgnoreUsers, "gi"))
        txt = msg.message.text
        match = rx.exec(txt)
        issues = []
        while match != null
            issue_number = match[1]
            if isNaN(issue_number)
                break
            issues.push(issue_number)
            match = rx.exec(txt)

        bot_github_repo = github.qualified_repo process.env.HUBOT_GITHUB_REPO

        _.uniq(issues).map (issue_number) ->
            issue_title = ""
            base_url = process.env.HUBOT_GITHUB_API || 'https://api.github.com'

            url = "#{base_url}/repos/#{bot_github_repo}/issues/" + issue_number

            github.get url, (issue_obj) ->
                issue_title = issue_obj.title
                issue_number = issue_obj.number
                unless process.env.HUBOT_GITHUB_API
                     url = "https://github.com"
                 else
                     url = base_url.replace /\/api\/v3/, ''

                msg.send "#{url}/#{bot_github_repo}/issues/#{issue_number}<<GH#{issue_number}>>: #{issue_title}"