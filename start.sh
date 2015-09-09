#!/bin/bash

docker run -d --env-file ./hubot.env -it --name hubot airelain/hubot-fleep-gh
