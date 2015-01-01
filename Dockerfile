FROM hpess/chef:latest
MAINTAINER Karl Stoney <karl@jambr.co.uk>

# Install Mono
RUN yum -y install yum-utils && \
    rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" && \
    yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ && \
    yum -y install openssl openssl-devel mono mono-devel mediainfo libzen libmediainfo gettext gcc gcc-c++ make && \
    yum -y clean all

# Install a newer version of sqlite
RUN curl --silent -L http://www.sqlite.org/2014/sqlite-autoconf-3080500.tar.gz -o /tmp/sqlite-autoconf-3080500.tar.gz && \
    tar -zxf /tmp/sqlite-autoconf-*.tar.gz -C /tmp/ && \
    cd /tmp/sqlite-autoconf* && \
    ./configure --prefix=/opt/sqlite3.8.5 --disable-static CFLAGS="-Os -frecord-gcc-switches -DSQLITE_ENABLE_COLUMN_METADATA=1" && \
    make && \
    make install && \
    rm -rf /tmp/sqlite*

# Install sonarr
RUN curl --silent -L http://update.nzbdrone.com/v2/master/mono/NzbDrone.master.tar.gz -o /tmp/NzbDrone.master.tar.gz && \
    tar zxf /tmp/NzbDrone.master.tar.gz -C /opt/ && \
    rm -rf /tmp/NzbDrone* && \
    mv /opt/NzbDrone /opt/sonarr && \
    echo "PATH=/opt/sqlite3.8.5/bin:$PATH" > /etc/sysconfig/sonarr && \
    useradd sonarr && \
    mkdir -p /home/sonarr/.config && \
    chown -R sonarr:sonarr /opt/sonarr

# Install pvk conversion tool
RUN mkdir -p /usr/local/src/pvk && \
    cd /usr/local/src/pvk && \
    wget --quiet http://www.drh-consultancy.demon.co.uk/pvksrc.tgz.bin && \
    tar -xzf pvksrc.tgz.bin && \
    make && \
    mv pvk /bin && \
    rm -rf /usr/local/src/pvk

EXPOSE 8989
EXPOSE 9898

ENV PATH /opt/sqlite3.8.5/bin:$PATH
ENV chef_node_name sonarr.docker.local
ENV chef_run_list sonarr 

COPY services/* /etc/supervisord.d/
COPY cookbooks/ /chef/cookbooks/
