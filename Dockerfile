# Based on Ubuntu 16.04

FROM       ubuntu:16.04

# Installation:

# Update apt-get sources AND install MongoDB
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN apt-get update && apt-get install -y mongodb-server openssh-server nano pwgen wget net-tools telnet 

# Create the MongoDB data directory
RUN mkdir -p /data/db
CMD chown -R mongodb:mongodb /data/db
# Expose port 27017 from the container to the host
EXPOSE 27017

# Set /usr/bin/mongod as the dockerized entry-point application
CMD /etc/init.d/mongodb start

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
RUN /etc/init.d/mongodb start
CMD tail -f /dev/null
