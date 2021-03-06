Release jobs
------------

The following table lists the main Jenkins jobs used during the release
process. All release jobs should be listed under the :jenkinsview:`Release`
view.

.. list-table::
    :header-rows: 1

    -   * Job task
        * OMERO
    -   * Trigger the OMERO release jobs
        * :jenkinsjob:`OMERO-DEV-release-trigger`
    -   * Tags the OMERO source code repository
        * :jenkinsjob:`OMERO-DEV-release-push`
    -   * Build the OMERO download artifacts
        * :jenkinsjob:`OMERO-DEV-release`
    -   * Generate the OMERO downloads page
        * :jenkinsjob:`OMERO-DEV-release-downloads`

.. list-table::
    :header-rows: 1

    -   * Job task
        * Bio-Formats   
    -   * Trigger the Bio-Formats release jobs
        * :jenkinsjob:`BIOFORMATS-DEV-release-trigger`
    -   * Tags the Bio-Formats source code repository
        * :jenkinsjob:`BIOFORMATS-DEV-release-push`
    -   * Build the Bio-Formats download artifacts
        * :jenkinsjob:`BIOFORMATS-DEV-release`
    -   * Generate the Bio-Formats downloads page
        * :jenkinsjob:`BIOFORMATS-DEV-release-downloads`


Bio-Formats
^^^^^^^^^^^

.. glossary::

    :jenkinsjob:`BIOFORMATS-DEV-release-trigger`

        This job triggers the Bio-Formats release jobs. Prior
        to running it, its variables need to be properly configured:

        - :envvar:`RELEASE` is the Bio-Formats release number.

        #. Triggers :term:`BIOFORMATS-DEV-release-push`
        #. Triggers :term:`BIOFORMATS-DEV-release`

    :jenkinsjob:`BIOFORMATS-DEV-release-push`

        This job creates a tag on the `develop` branch

        #. Runs `scc tag-release $RELEASE` and pushes the tag to the
           snoopycrimecop fork of bioformats.git_

    :jenkinsjob:`BIOFORMATS-DEV-release`

        This job builds the Java downloads artifacts of Bio-Formats

        #. Checks out the :envvar:`RELEASE` tag of the
           snoopycrimecop fork of bioformats.git_
        #. |buildBF|
        #. |copyreleaseartifacts|
        #. Triggers :term:`BIOFORMATS-DEV-release-downloads`

    :jenkinsjob:`BIOFORMATS-DEV-release-downloads`

        This job builds the Bio-Formats Java downloads page

        #. Checks out the `develop` branch of
           https://github.com/openmicroscopy/ome-release.git
        #. Runs `make clean bf`

OMERO
^^^^^

.. glossary::

    :jenkinsjob:`OMERO-DEV-release-trigger`

        This job triggers the OMERO release jobs. Prior to running it, its
        variables need to be properly configured:

        - :envvar:`RELEASE` is the OMERO release number.
        - :envvar:`ANNOUNCEMENT_URL` is the URL of the forum release
          announcement and should be set to the value of the URL of the
          private post until it becomes public.
        - :envvar:`MILESTONE` is the name of the Trac milestone which the
          download pages should be linked to.

        #. Triggers :term:`OMERO-DEV-release-push`
        #. Triggers :term:`OMERO-DEV-release`

        See :jenkinsjob:`the build graph <OMERO-DEV-release-trigger/lastSuccessfulBuild/BuildGraph>`

    :jenkinsjob:`OMERO-DEV-release-push`

        This job creates a tag on the `develop` branch

        #. Runs `scc tag-release $RELEASE` and pushes the tag to the
           snoopycrimecop fork of openmicroscopy.git_

    :jenkinsjob:`OMERO-DEV-release`

        This matrix job builds the OMERO components with Ice 3.5

        #. Checks out the :envvar:`RELEASE` tag of the
           snoopycrimecop fork of openmicroscopy.git_
        #. |buildOMERO|
        #. Executes the `release-hudson` target for the `ome.staging` Maven
           repository
        #. |copyreleaseartifacts|
        #. Triggers :term:`OMERO-DEV-release-downloads`

    :jenkinsjob:`OMERO-DEV-release-downloads`

        This job builds the OMERO downloads page

        #. Checks out the `develop` branch of
           https://github.com/openmicroscopy/ome-release.git
        #. Runs `make clean omero`


Documentation release jobs are documented on :doc:`ci-docs`.
