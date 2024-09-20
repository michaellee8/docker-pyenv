ARG BASE_OS=alpine:3.20
FROM ${BASE_OS} AS base-os
# Need to be adapted according to https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN apk add --no-cache busybox git bash build-base libffi-dev openssl-dev bzip2-dev zlib-dev xz-dev readline-dev sqlite-dev tk-dev linux-headers
RUN adduser -D -s /bin/bash developer
USER developer
WORKDIR /home/developer

FROM base-os AS base-pyenv
ARG PYENV_GIT_TAG=v2.4.13
RUN git clone https://github.com/pyenv/pyenv.git -b ${PYENV_GIT_TAG} ~/.pyenv
# According to pyenv README pyenv will still works even this fails, so we make it always success
RUN cd ~/.pyenv && src/configure && make -C src || true
COPY --chown=developer:developer /content/* /home/developer/
CMD ["/bin/bash"]
VOLUME [ "/home/developer/workspace" ]
WORKDIR /home/developer/workspace

FROM base-pyenv AS pyenv-39
RUN /bin/bash -c -l "pyenv install 3.9"

FROM base-pyenv AS pyenv-310
RUN /bin/bash -c -l "pyenv install 3.10"

FROM base-pyenv AS pyenv-311
RUN /bin/bash -c -l "pyenv install 3.11"

FROM base-pyenv AS pyenv-312
RUN /bin/bash -c -l "pyenv install 3.12"

FROM base-pyenv AS workspace
COPY --from=pyenv-39 /home/developer/.pyenv/versions/ /home/developer/.pyenv/versions
COPY --from=pyenv-310 /home/developer/.pyenv/versions/ /home/developer/.pyenv/versions
COPY --from=pyenv-311 /home/developer/.pyenv/versions/ /home/developer/.pyenv/versions
COPY --from=pyenv-312 /home/developer/.pyenv/versions/ /home/developer/.pyenv/versions
RUN /bin/bash -c -l "pyenv global 3.12"