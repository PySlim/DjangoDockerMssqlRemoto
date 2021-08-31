FROM python:3.8
ENV PYTHONUNBUFFERED 1

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
	curl apt-transport-https debconf-utils curl wget gnupg  netcat \
	python3 \
    python3-pip \
    python3-dev \
    musl-dev \
    unixodbc \
    unixodbc-dev \
    && apt-get -y autoclean \
    && apt-get -y autoremove  \
    && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers and tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN /bin/bash -c "source ~/.bashrc"

RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8



RUN mkdir /code

WORKDIR /code

RUN pip3 install --upgrade pip

COPY requirements.txt /code/


RUN pip3 install -r requirements.txt --no-cache-dir

RUN sed -i '1i openssl_conf = default_conf' /etc/ssl/openssl.cnf && echo -e "\n[ default_conf ]\nssl_conf = ssl_sect\n[ssl_sect]\nsystem_default = system_default_sect\n[system_default_sect]\nMinProtocol = TLSv1\nCipherString = DEFAULT:@SECLEVEL=1" >> /etc/ssl/openssl.cnf

COPY . /code/


