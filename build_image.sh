#!/bin/zsh

# Docker Desktop muss laufen, damit der Build erstellt werden kann

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
echo "Aktuelle Version: $CURRENT_VERSION"

# Frage nach der neuen Version
echo "Bitte geben Sie die neue Version ein: "
read NEW_VERSION

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
fi

echo "Alle Operationen erfolgreich ausgeführt."
