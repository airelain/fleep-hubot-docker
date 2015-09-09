# Docker 1.5.0

FROM nodesource/jessie

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y redis-server git-core
# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install coffee-script, hubot
RUN npm install -g yo generator-hubot coffee-script

# Working enviroment
ENV BOTDIR /opt/bot
RUN install -o nobody -d ${BOTDIR}
ENV HOME ${BOTDIR}
WORKDIR ${BOTDIR}

# Install Hubot
USER nobody
RUN yo hubot --name="Hubot" --defaults

# Install fleep adapter
RUN npm install hubot-fleep --save

# Install githubot and underscore
RUN npm install githubot underscore --save

# Patch all the stuff
COPY ./scripts/github-issue-link.coffee ${BOTDIR}/scripts/github-issue-link.coffee
COPY ./patch/fleep.coffee ${BOTDIR}/node_modules/hubot-fleep/src/fleep.coffee

# Entrypoint
ENTRYPOINT ["/bin/sh", "-c", "cd ${BOTDIR} && bin/hubot --adapter fleep"]
