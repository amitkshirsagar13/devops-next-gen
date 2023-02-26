FROM jenkins/jenkins:2.391-alpine
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Install Plugins
# COPY workflow-plugins.txt /usr/share/jenkins/ref/workflow-plugins.txt
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/workflow-plugins.txt

# COPY pipeline-plugins.txt /usr/share/jenkins/ref/pipeline-plugins.txt
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/pipeline-plugins.txt

# COPY git-plugins.txt /usr/share/jenkins/ref/git-plugins.txt
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/git-plugins.txt

# COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# COPY user-auth.plugins.txt /usr/share/jenkins/ref/user-auth.plugins.txt
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/user-auth.plugins.txt

# COPY job-plugins.txt /usr/share/jenkins/ref/job-plugins.txt
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/job-plugins.txt


# Add JCasC
# ENV CASC_JENKINS_CONFIG=/var/casc/casc_configs
# COPY jcasc.yaml /var/casc/casc_configs/jcasc.yaml

# RUN apt-get update && apt-get install -y maven

# ENV SECRETS="/var/secrets/seed_secrets"
# ENV CASC_VAULT_FILE="/var/secrets/seed_secrets/jcasc_vault"
# COPY secrets /var/secrets/seed_secrets

# RUN addgroup --gid 2222 --system docker
# RUN usermod -aG docker 
# RUN chown -R 1000:1000 /var/jenkins_home
EXPOSE 8080