FROM node

# Salesforce cli install
RUN npm install @salesforce/cli@latest -g

# sfdx-git-delta install for delta package generation
RUN echo 'y' | sf plugins install sfdx-git-delta

# sfdmu install for data deployment
RUN sf plugins install sfdmu

# sfdx scanner install for PMD
RUN sf plugins install @salesforce/sfdx-scanner

# sfdx skuid install for skuid deployemnt
RUN echo 'y' | sf plugins install skuid-sfdx

# java 17 install
RUN apt-get update && \
apt install -y openjdk-17-jre-headless && \
apt-get clean