FROM scratch

#https://partner-images.canonical.com/core/trusty/20170627/
ADD ubuntu-trusty-core-cloudimg-i386-root.tar.gz /

#
#https://github.com/moby/moby/blob/master/contrib/mkimage/debootstrap
#

#prevent init scripts from running during install/update
ADD rootfs/policy-rc.d /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN cp -a /usr/sbin/policy-rc.d /sbin/initctl
RUN sed -i 's/^exit.*/exit 0/' /sbin/initctl

#shrink a little, since apt makes us cache-fat (wheezy: ~157.5MB vs ~120MB)
RUN apt-get clean 

# this file is one APT creates to make sure we don't "autoremove" our currently
# in-use kernel, which doesn't really apply to debootstraps/Docker images that
# don't even have kernels installed
RUN rm -f /etc/apt/apt.conf.d/01autoremove-kernels

#_keep_ us lean by effectively running "apt-get clean" after every install
ADD rootfs/docker-clean /etc/apt/apt.conf.d/docker-clean


# remove apt-cache translations for fast "apt-get update"
ADD rootfs/docker-no-languages /etc/apt/apt.conf.d/docker-no-languages

ADD rootfs/docker-gzip-indexes /etc/apt/apt.conf.d/docker-gzip-indexes

# update "autoremove" configuration to be aggressive about removing suggests deps that weren't manually installed
ADD rootfs/docker-autoremove-suggests /etc/apt/apt.conf.d/docker-autoremove-suggests

#
RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends
RUN echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends

# make sure we're fully up-to-date
RUN apt-get update
RUN apt-get dist-upgrade -y

# delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*


# overwrite this with 'CMD []' in a dependent Dockerfile 
CMD ["/bin/bash"]
