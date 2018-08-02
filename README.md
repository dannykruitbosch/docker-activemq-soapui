# ActiveMQ and SOAP-UI mock runner container.

## Introduction

This docker image allows you to run ActiveMQ and SOAP-UI mocks in one container. This way you can create ActiveMQ (JMS) mocks and
REST/SOAP mocks using SOAP-UI.

## Background

This image/container was created for one of our projects where we were integrating with SOAP services and were receiving messages over JMS.
To be able to emulate this environment (e.g. when developing off-site) we created this image in which we could run our SOAP-UI mocks.

## Running the container

The image contains a default SOAP-based mock that receives a soap message and sends the soap response. It also sends a JSON message to the ActiveMQ JMS broker.

To run the container:
  
  > `$ docker pull dannykruitbosch/activemq-soapui:latest`
  
  > `$ docker run -p8888:8888 -p61616:61616 -p8161:8161 dannykruitbosch/docker-activemq-soapui:latest`

## Adding your own SOAP-UI mockservice

There are two ways to add your own mock service to the container

### By mapping a local volume into the container

    $ docker run --rm -p8888:8888 -p8161:8161 -p61616:61616 \
    -v /path/to/your/soapui/mock:/home/soapui/soapui-prj \
    -e MOCK_SERVICE_NAME=YourMockService \
    -e PROJECT=your-soapui-project.xml \
    -e MOCK_SERVICE_PORT=8888 \
    dannykruitbosch/docker-activemq-soapui:latest


### By building your own image/container

Add your own mock service to the container. Create a `Dockerfile` inside the project folder of your SOAP-UI mock, with the following contents:

    FROM dannykruitbosch/activemq-soapui
    ENV MOCK_SERVICE_NAME=YourMockService
    COPY your-soapui-project.xml /home/soapui/soapui-prj/default-soapui-project.xml

And then build this image, by using

> `$ docker build -t your-tag .`

And finally run by using:

> `$ docker run -p8888:8888 -p61616:61616 -p8161:8161 -e MOCK_SERIVCE_NAME=YourMockService your-tag`

( *if you rename your mock service to `default-mock`, you can leave the `MOCK_SERVICE_NAME` env variable out of the run command* )

## Ports and customization

### Port Map

    8888    MOCK (Soap-UI)
    61616   JMS (ActiveMQ)
    8161    UI (ActiveMQ)
    5672    AMQP (ActiveMQ)
    61613   STOMP (ActiveMQ)
    1883    MQTT (ActiveMQ)
    61614   WS (ActiveMQ)

### Customizing ActiveMQ configuration and persistence location

ActiveMQ checks your environment for the variables *ACTIVEMQ_BASE*, *ACTIVEMQ_CONF* and *ACTIVEMQ_DATA*.
Just override them with your desired location:

    docker run -p 61616:61616 -p 8161:8161 -e ACTIVEMQ_CONF=/etc/activemq/conf -e ACTIVEMQ_DATA=/var/lib/activemq/data dannykruitbosch/docker-activemq-soapui:latest

As an alternative you can just mount your persistent config and data directories into the default location:

    docker run -p 61616:61616 -p 8161:8161 -v /opt/activemq/conf:/opt/activemq/conf -v /opt/activemq/data:/opt/activemq/data dannykruitbosch/docker-activemq-soapui:latest

This image has one small config option extra enabled, namely [_schedulerSupport_](http://activemq.apache.org/delay-and-schedule-message-delivery.html). This allows you to delay sending messages as a response from a MockRequest (see the small tutorial on JMS and SOAP-UI mocks).

## Creating a mock service that send JMS messages to the broker.

Here's a small tutorial on how to send messages from SOAP-UI mocks to the JMS broker. The default mock in this container uses this method.
See https://github.com/dannykruitbosch/docker-activemq-soapui/blob/master/docs/using-jms-in-soapui.md

## Thanks

This container is based of another great ActiveMQ container maintained by `rmohr`, https://hub.docker.com/r/rmohr/activemq/

And the work done on Soap-UI MockService image by `fbascheper`, https://hub.docker.com/r/fbascheper/soapui-mockservice-runner/
