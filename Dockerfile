FROM    ruby:2.5-slim
RUN     apt-get update -qq && \
        apt-get install -y awscli curl build-essential && \
        gem install --no-document bundler && \
        useradd -m -U -s /bin/bash app
COPY    --chown=app:app . /home/app/fcrepo-cloud-migrator
USER    app
WORKDIR /home/app/fcrepo-cloud-migrator
RUN     bundle install --path vendor/gems
CMD     /bin/bash
