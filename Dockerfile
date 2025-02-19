# Copyright (c) 2024-2025 Bartholomé Gili <dev.bartho@gmail.com>
# Copyright (c) 2019-2020 Eric D. Hough   <eric@tubepress.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM alpine:latest

# Définition des variables d'environnement pour éviter les erreurs de substitution
ENV ARCHITECTURE=linux_x64 \
    VERSION_DUPLICACY=3.2.4 \
    VERSION_DUPLICACY_WEB=1.8.3 \
    SHA256_DUPLICACY_WEB=9cdcaa875ae5fc0fcf93941df3a5133fb3c3ff92c89f87babddc511ba6dd7ef8 \
    _BIN_DUPLICACY=/usr/local/bin/duplicacy \
    _BIN_DUPLICACY_WEB=/usr/local/bin/duplicacy_web \
    _DIR_WEB=/root/.duplicacy-web \
    _DIR_CONF=/etc/duplicacy \
    _DIR_CACHE=/var/cache/duplicacy

# Définition des URLs
RUN set -eux; \
    _URL_DUPLICACY="https://github.com/gilbertchen/duplicacy/releases/download/v${VERSION_DUPLICACY}/duplicacy_${ARCHITECTURE}_${VERSION_DUPLICACY}"; \
    _URL_DUPLICACY_WEB="https://acrosync.com/duplicacy-web/duplicacy_web_${ARCHITECTURE}_${VERSION_DUPLICACY_WEB}"; \
    \
    # Installer les dépendances
    apk update && apk add --no-cache ca-certificates tzdata wget bash && \
    \
    # Télécharger et installer duplicacy
    wget -O "${_BIN_DUPLICACY}" "${_URL_DUPLICACY}" && chmod +x "${_BIN_DUPLICACY}" && \
    \
    # Télécharger et vérifier duplicacy web
    wget -O "${_BIN_DUPLICACY_WEB}" "${_URL_DUPLICACY_WEB}" && \
    echo "${SHA256_DUPLICACY_WEB}  ${_BIN_DUPLICACY_WEB}" | sha256sum -c - && chmod +x "${_BIN_DUPLICACY_WEB}" && \
    \
    # Création des répertoires
    mkdir -p "${_DIR_CACHE}/repositories" "${_DIR_CACHE}/stats" "${_DIR_WEB}/bin" "/var/lib/dbus" && \
    \
    # Lien symbolique pour duplicacy_web
    ln -s "${_BIN_DUPLICACY}" "${_DIR_WEB}/bin/duplicacy_${ARCHITECTURE}_${VERSION_DUPLICACY}" && \
    ln -s /dev/stdout /var/log/duplicacy_web.log && \
    \
    # Lien symbolique pour la configuration
    ln -s "${_DIR_CONF}/settings.json"  "${_DIR_WEB}/settings.json" && \
    ln -s "${_DIR_CONF}/duplicacy.json" "${_DIR_WEB}/duplicacy.json" && \
    ln -s "${_DIR_CONF}/licenses.json"  "${_DIR_WEB}/licenses.json" && \
    ln -s "${_DIR_CONF}/filters"        "${_DIR_WEB}/filters" && \
    ln -s "${_DIR_CACHE}/stats"         "${_DIR_WEB}/stats"

EXPOSE 3875
CMD [ "/usr/local/bin/entrypoint.sh" ]

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/var/cache/duplicacy", "/etc/duplicacy"]
