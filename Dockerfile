FROM ubuntu:latest

ARG username
ARG password

# copy system files
COPY ./etc/apt/sources.list /etc/apt/sources.list
COPY ./usr/local/sbin/unminimize /usr/local/sbin/unminimize

# install system software
RUN chmod 755 /usr/local/sbin/unminimize && \
  unminimize && \
  apt-get install openssh-server -y && \
  sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config && \
  mkdir /var/run/sshd && \
  /usr/bin/ssh-keygen -A

# create user
RUN echo "root:$password" | chpasswd && \
  echo "$username:x:1000::" >> /etc/group && \
  echo "$username:x:1000:1000:,,,:/home/$username:/bin/bash" >> /etc/passwd && \
  echo "$username:$password" | chpasswd && \
  usermod -G sudo $username

# install user software
RUN apt-get install fish htop git -y && \
  chsh -s `which fish` $username

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
