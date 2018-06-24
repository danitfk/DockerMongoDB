# Based on Ubuntu 18.04

FROM       ubuntu:18.04

# Installation:

# Update apt-get sources AND install MongoDB
RUN apt-get update
RUN apt-get install gnupg -y
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
RUN echo 'deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/testing multiverse' | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN apt-get update
RUN apt-get install -y mongodb-org openssh-server net-tools pwgen 



# Create the MongoDB data directory
VOLUME ["/data/db"]
WORKDIR /data
RUN mkdir -p /data/db
RUN chown -R mongodb:mongodb /data/db
# Expose port 27017 from the container to the host
EXPOSE 27017

# Set /usr/bin/mongod as the dockerized entry-point application
CMD ["/usr/bin/mongod", "--bind_ip_all"]
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
ENTRYPOINT ["/usr/bin/mongod", "--bind_ip_all"]
