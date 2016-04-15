#!/bin/bash

docker run -d --env-file ./hubot.env -it -v `pwd`/scripts:/opt/bot/scripts --name hubot airelain/hubot-fleep-gl
