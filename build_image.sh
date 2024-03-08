#!/bin/zsh

#
# Docker Desktop muss laufen, damit der Build erstellt werden kann
#
# Check if Docker is not running
if ! docker info &> /dev/null; then
    echo "Docker is not running. Starting Docker..."
    open -a Docker
fi

# Wait until Docker daemon is ready
while ! docker info &> /dev/null; do
    echo "Waiting for Docker to start..."
    sleep 1
done

# Docker is running
echo "Docker is now ready to use."

# Variablen setzen
source ~/.docker/.env
IMAGE_NAME="n8n_python_mjml"

# In lokales verzeichnis wechseln
VERZEICHNIS=~/dev/docker/n8n_python_mjml
cd "$VERZEICHNIS"

# Pfad zur Datei mit der versionsnummer
VERSION_FILE=version.txt

# Überprüfe, ob die Versionsdatei existiert
if [ ! -f $VERSION_FILE ]; then
    echo "0.0.0" > $VERSION_FILE
    echo "Keine Versionsdatei gefunden. Starte mit Version 0.0.0."
fi

# Lese die aktuelle Version aus der Datei
CURRENT_VERSION=$(<$VERSION_FILE)

# Zeige die aktuelle Version an
echo "Letzte erstellte Version: $CURRENT_VERSION"

#
# Suche nach der aktuellen n8n Version
#
# Senden einer Anfrage, um die Location-Header zu bekommen
location_header=$(curl -I -sS https://github.com/n8n-io/n8n/releases/latest | grep -i location)

# Extrahieren Sie den Teil der URL nach dem "@"-Symbol
n8n_version=$(echo $location_header | grep -o 'n8n@[^"]*' | cut -d'@' -f 2 | tr -d '\r')

# Ausgabe der Versionsnummer
echo "Die aktuelle n8n Version ist: $n8n_version"

# Überprüfen Sie, ob die Versionsnummer dem Schema x.y.z entspricht
echo "Überprüfe, ob die n8n Versionsnummer $n8n_version dem Schema x.y.z entspricht..."

if [[ $n8n_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Die gefundene Versionsnummer ist korrekt: $n8n_version"
    NEW_VERSION=$n8n_version
else
    echo "Die gefundene Versionsnummer entspricht nicht dem Schema 'x.y.z'"
    # Frage nach der neuen Version
    echo "Bitte geben Sie die neue Version ein: "
    read NEW_VERSION
fi

# Speichere die neue Version in die Datei
echo $NEW_VERSION > $VERSION_FILE
echo "Die Version wurde auf $NEW_VERSION aktualisiert."

# Stelle sicher, dass das Dockerfile im aktuellen Verzeichnis existiert
    if [ ! -f "Dockerfile" ]; then
    echo "Dockerfile nicht gefunden!"
    exit 1
fi

# Docker Login
docker login

# Build das Docker Image
docker buildx build --platform linux/amd64,linux/arm64 -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${NEW_VERSION} -t ${DOCKER_USERNAME}/${IMAGE_NAME}:latest --push .
if [ $? -ne 0 ]; then
    echo "Image konnte nicht gebaut werden."
    exit 1
else
    echo "Image wurde erfolgreich gebaut."
    # Lösche das lokale Image
    # docker rmi ${DOCKER_USERNAME}/${IMAGE_NAME}:${NEW_VERSION}
    # docker rmi ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
    # Git add, commit und push für die Versionsänderung
    git add .
    git commit -m "Version $NEW_VERSION"
    git push
fi

echo "Alle Operationen erfolgreich ausgeführt."
