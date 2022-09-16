#/bin/bash

echo "====== Docker-compose autoupdater ======"
DC_REMOTE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
DESTINATION=/usr/local/bin/docker-compose
echo "🔍 Latest remote version found: ${DC_REMOTE_VERSION}"
# check if docker-compose is installed
if [ -f $DESTINATION ]; then
	# check version installed (if present)
	DC_LOCAL_VERSION=$(${DESTINATION} -v | cut -d ' ' -f4)
	if [[ $DC_LOCAL_VERSION == $DC_REMOTE_VERSION ]]; then
		echo "✅ ${DC_LOCAL_VERSION} is up to date";
		exit;
	fi
fi

# install or update docker-compose
DESTINATION_TMP=/tmp/docker-compose
DC_RELEASE_URL=https://github.com/docker/compose/releases/download/${DC_REMOTE_VERSION}/docker-compose-$(uname -s)-$(uname -m)
echo "⌛ Downloading docker-compose version ${DC_REMOTE_VERSION}..."
sudo curl -sSL $DC_RELEASE_URL -o $DESTINATION_TMP
CHECKSUM_DOWNLOADED=$(sudo curl -sL ${DC_RELEASE_URL}.sha256 | cut -d ' ' -f1)
CHECKSUM_LOCAL=$(sha256sum ${DESTINATION_TMP} | cut -d ' ' -f1)
if [ $CHECKSUM_DOWNLOADED != $CHECKSUM_LOCAL ]; then
	echo "❌ Checksum validation failed";
	exit;
fi
sudo mv $DESTINATION_TMP $DESTINATION
sudo chmod 755 $DESTINATION
DC_LOCAL_VERSION=$(${DESTINATION} -v | cut -d ' ' -f4)
echo "✅ ${DC_LOCAL_VERSION} has been installed";
