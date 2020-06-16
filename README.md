# Docker Image of the EPICS Archiver Appliance

* Intended to use Redis based persistence (instead of MySQL).
* Omitting the typical installation scripts such as
  `quickstart.sh` / `single_machine_install.sh`.
* Using a multi-stage build process in order to pick (copy)
  only relevant assets from the Archiver Appliance releases.
* In parts inspired by this (older) puppet deployment:
  <https://github.com/frib-high-level-controls/mark0n-epics_archiver_appliance>
* In parts inspired by this (older) docker deployment:
  <https://github.com/jsparger/docker-epics-archiver-appliance>

### Environment Variables Relevant for the EPICS Archiver Appliance

The [EPICS Archiver Appliance][] has a set of various
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

[EPICS Archiver Applianc]: https://slacmshankar.github.io/epicsarchiver_docs/index.html
[ConfigService class]: https://slacmshankar.github.io/epicsarchiver_docs/api/org/epics/archiverappliance/config/ConfigService.html
[Installation Guide]: https://slacmshankar.github.io/epicsarchiver_docs/installguide.html
[FAQ]: https://slacmshankar.github.io/epicsarchiver_docs/faq.html
[source code]: https://github.com/slacmshankar/epicsarchiverap/
