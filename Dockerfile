# Based on Ubuntu 16.04

FROM       ubuntu:16.04

# Installation:

# Update apt-get sources AND install MongoDB
RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list && \
  apt-get update && \
  apt-get install -y mongodb-org openssh-server nano pwgen wget net-tools telnet && \
  rm -rf /var/lib/apt/lists/*


# Create the MongoDB data directory
VOLUME ["/data/db"]
WORKDIR /data
RUN mkdir -p /data/db
RUN chown -R mongodb:mongodb /data/db
# Expose port 27017 from the container to the host
EXPOSE 27017

# Set /usr/bin/mongod as the dockerized entry-point application
CMD ["mongod"]

RUN wget  -O /root/Secure-MongoDB.sh https://raw.githubusercontent.com/danitfk/DockerMongoDB/master/Secure-MongoDB.sh
RUN bash /root/Secure-MongoDB.sh
RUN rm -rf /root/Secure-MongoDB.sh

# Install SSH Server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
RUN /etc/init.d/ssh start
CMD ["mongod"]
