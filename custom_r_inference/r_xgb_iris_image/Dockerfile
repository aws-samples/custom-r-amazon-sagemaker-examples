
FROM r-base

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    wget \
    apt-transport-https \
    ca-certificates \
    libcurl4-openssl-dev \
    libsodium-dev

RUN R -e "install.packages(c('xgboost','plumber', 'readr', 'jsonlite'), repos='https://cloud.r-project.org')"

COPY xgb.model /opt/ml/model/xgb.model
COPY endpoints.R /opt/ml/endpoints.R
COPY deploy.R /opt/ml/deploy.R

ENTRYPOINT ["/usr/bin/Rscript", "/opt/ml/deploy.R", "--no-save"]