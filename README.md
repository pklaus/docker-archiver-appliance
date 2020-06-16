# Docker Image of the EPICS Archiver Appliance

This is the source repository for a Docker image containing
the [EPICS Archiver Appliance][] served by Apache Tomcat.  
A pre-built image can be found on the Docker Hub at:
[/r/pklaus/archiver-appliance][].

By the time of its creation, only a few Dockerfiles/
Docker deployments of the Archiver Appliance were published
by controls scientists form around the world.
Here's how this one differs / stands out:

* It uses a multi-stage build to pick (copy) only relevant
  assets from the Archiver Appliance release file.
* omits the typical installation scripts such as
  `quickstart.sh` / `single_machine_install.sh`,
* avoids puppet configuration management scripts,
  although a lot was learned from [one of them][puppet],
* out of the box supports InMemoryPersistence and RedisPersistence
  (to use MySQL instead, its Connector/J .jar file would have to
  be added to the image),
* was also inspired by [a Docker deployment by jsparger][jsparger]
  concerning the mounting of a local `storage` directory and
  the use of a docker-compose file (see example deployment below).

### Example Deployment

This image may be deployed in many different ways
depending on the network layout, need to reach other
Docker containers on the same host etc.

A quick example of how to use it with an EPICS
example IOC and a Redis db for persistence,
check out [pklaus / archiver-appliance-with-example-ioc][].

For a production environment, it seems very favorable
to run the container with `--network=host` in order
to be reachable from the other machines on the network.

### Guidelines for the Dockerfile

The Dockerfile for this image was written with the following aspects in mind:

* Attempt to be compact in size.
* Download the EPICS Archiver Appliance release in a
  first build stage and extract it.
* In the second build stage, start with a lightweight tomcat Docker
  image copy the unpacked Java web applications (.war files) from
  the first build stage to `/usr/local/tomcat/webapps`.
* Put any additional/modified/custom files in `/etc/archappl/`.
  If they are intended to replace other existing files of the
  software, those files are removed and a softlink to their
  replacement in `/etc/archappl` is created to make the customization
  transparent.
* Sane defaults for the environment variables are set in the
  Dockerfile, see the section below.
  Those environment variables can be adapted (overridden) on
  demand when deploying the container.

This way, the Dockerfile is very compact,
the docker build context is small because
downloading the release takes place inside
the first build stage and in addition, the
Dockerfile is very explicit about what parts
of the release file are really needed to
run the appliance.

### Environment Variables Relevant for the EPICS Archiver Appliance

The Archiver Appliance has a set of various
environment variables used to configure the appliance.
Many of them can be found on the website, for example
in the [Installation Guide][], the [FAQ][] or the
Javadoc documentation of the [ConfigService class][].

Some of them, however, are hard to find in the documents.
As most of them start with `ARCHAPPL_`, I decided to search
the Archiver Appliance source code for all of them. I ran
`grep -R ARCHAPPL_ . | grep -E -o 'ARCHAPPL_[A-Z0-9_]+' | sort | uniq`
inside a local copy of the [source code][]. Here's the result:

```
ARCHAPPL_ALL_APPS_ON_ONE_JVM
ARCHAPPL_APPLIANCES
ARCHAPPL_COMPONENT
ARCHAPPL_CONFIGSERVICE_IMPL
ARCHAPPL_DEPLOY_DIR
ARCHAPPL_JDBM2_FILENAME
ARCHAPPL_LONG_TERM_FOLDER
ARCHAPPL_MEDIUM_TERM_FOLDER
ARCHAPPL_MYIDENTITY
ARCHAPPL_NAGIOS_EMAIL_CONFIG
ARCHAPPL_NAMEDFLAGS_PROPERTIES_FILE_PROPERTY
ARCHAPPL_PBRAW
ARCHAPPL_PERSISTENCE_LAYER
ARCHAPPL_PERSISTENCE_LAYER_JDBM2FILENAME
ARCHAPPL_PERSISTENCE_LAYER_REDISURL
ARCHAPPL_POLICIES
ARCHAPPL_PROPERTIES_FILENAME
ARCHAPPL_PVNAME_TO_KEY_MAPPING_CLASSNAME
ARCHAPPL_SHORT_TERM_FOLDER
ARCHAPPL_SITEID
ARCHAPPL_SRC
```

For their meaning, please refer to the sources cited.
They are just stated here to serve as a reference.
It has proven quite useful in many cases to check how they
are used in the source code of the Archiver Appliance.

[EPICS Archiver Appliance]: https://slacmshankar.github.io/epicsarchiver_docs/index.html
[/r/pklaus/archiver-appliance]: https://hub.docker.com/r/pklaus/archiver-appliance
[jsparger]: https://github.com/jsparger/docker-epics-archiver-appliance
[puppet]: https://github.com/frib-high-level-controls/mark0n-epics_archiver_appliance
[pklaus / archiver-appliance-with-example-ioc]: https://github.com/pklaus/archiver-appliance-with-example-ioc
[ConfigService class]: https://slacmshankar.github.io/epicsarchiver_docs/api/org/epics/archiverappliance/config/ConfigService.html
[Installation Guide]: https://slacmshankar.github.io/epicsarchiver_docs/installguide.html
[FAQ]: https://slacmshankar.github.io/epicsarchiver_docs/faq.html
[source code]: https://github.com/slacmshankar/epicsarchiverap/
