# Erbe vom Standard n8n Image
FROM docker.n8n.io/n8nio/n8n

# Führe als root aus, um Pakete zu installieren
USER root

# Installiere 'python'
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python

# Installiere Python Virtual Environment
RUN python3 -m venv /venv

# Aktiviere das Virtual Environment für nachfolgende Befehle
ENV PATH="/venv/bin:$PATH"

# Installiere 'pip'
RUN apk add --update --no-cache py3-pip && ln -sf pip3 /usr/bin/pip
RUN apk add --update --no-cache py3-setuptools
RUN apk add --update --no-cache py3-wheel
RUN pip install --upgrade pip

RUN rm -rf /var/cache/apk/*

# Installiere mjml über npm
RUN npm install -g mjml

# Setze das Arbeitsverzeichnis
WORKDIR /home/automation

# Kopiere die requirements.txt ins Arbeitsverzeichnis
COPY ./requirements.txt /home/automation/requirements.txt

# Installiere die Python-Pakete
RUN pip3 install --no-cache-dir -r /home/automation/requirements.txt

# Wechsle zurück zum n8n User
USER node
