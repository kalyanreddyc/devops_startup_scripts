# drilldevops_startup_scripts
DrillDevops_Startup_Scripts_Automations

##Jenkins agent.jar on linux 
#!/bin/bash

# Define variables
JENKINS_URL="http://<your-jenkins-server>"
JENKINS_AGENT_NAME="<your-agent-name>"
JENKINS_SECRET="<your-agent-secret>"

# Run the agent
java -jar agent.jar -jnlpUrl ${JENKINS_URL}/computer/${JENKINS_AGENT_NAME}/jenkins-agent.jnlp -secret ${JENKINS_SECRET} -workDir "/home/jenkins" >> jenkins-agent.log 2>&1 &


##Create a Systemd Service File: Create a service file, e.g., /etc/systemd/system/jenkins-agent.service
[Unit]
Description=Jenkins Agent

[Service]
ExecStart=/usr/bin/java -jar /path/to/agent.jar -jnlpUrl http://<your-jenkins-server>/computer/<your-agent-name>/jenkins-agent.jnlp -secret <your-agent-secret> -workDir "/home/jenkins"
StandardOutput=file:/var/log/jenkins-agent.log
StandardError=file:/var/log/jenkins-agent-error.log
Restart=always

[Install]
WantedBy=multi-user.target


##Reload Systemd and Start the Service:
sudo systemctl daemon-reload
sudo systemctl start jenkins-agent
sudo systemctl enable jenkins-agent

