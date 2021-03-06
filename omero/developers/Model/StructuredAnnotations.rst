Working with annotations
========================

Structured annotations permit the attachment of data and metadata
outside the OMERO data model to certain types within the model. The
annotations are designed for individualized use by both sites and tools.
Annotations can be attached to multiple instances simultaneously to
quickly annotated all entities in a view. Each annotation has a "name"
which can be interpreted as a "namespace" by tools, which can filter out
all unknown namespaces. Further, to prevent users from overwriting or
editing important information, annotations are immutable, but editing
can be simulated via copy and delete.

Annotated and annotating types
------------------------------

Each type which can be annotated implements ``ome.model.IAnnotated``.
Currently, these are:

-  ``Project``
-  ``Dataset``
-  ``Image``
-  ``Pixels``
-  ``OriginalFile``
-  ``PlaneInfo``
-  ``Roi``
-  ``Channel``
-  ``Annotation`` and all annotation subtypes in order to form hierarchies
-  ScreenPlateWell: ``Screen``, ``ScreenAcquisition``, ``Plate``, ``Well``, 
   ``Reagent``
-  ``Folder``

Annotation hierarchy
^^^^^^^^^^^^^^^^^^^^

Though they largely are all String or numeric values, a hierarchy of
annotations makes differentiating between just what interpretation
should be given to the annotation. This may eventually include
validation of the input string and/or file.

::

       Annotation (A*) ....................... A name field and a description
         ListAnnotation ...................... Uses AnnotationAnnotation links to form a list of annotations
         BasicAnnotation (A*) ................ Literal or "primitive" values
           BooleanAnnotation ................. A simple true/false flag
           TimeStampAnnotation ............... A date/time
           TermAnnotation .................... A term used in an ontology
           NumericAnnotation (A*) ............ Floating point and integer values
             DoubleAnnotation
             LongAnnotation
         MapAnnotation ....................... A list of key-value pairs
         TextAnnotation (A*) ................. A single text field
           CommentAnnotation ................. A user comment
           TagAnnotation ..................... Interpreted as a Web 2.0 "tag" on an object, tags on tags form tag bundles
           XmlAnnotation ..................... An xml snippet attached to some object
         TypeAnnotation (A*) ................. Links some entity to another (possibly to be replaced by <any/>)
           FileAnnotation .................... Uses the Format field on OriginalFile to specify type

       A* = abstract

.. seealso::
	:schema:`Schema documentation for Structured Annotations <Documentation/Generated/OME-2013-06/SA_xsd.html#Annotation>`
		Section of the auto-generated schema documentation describing the
		structured annotations

Names and namespaces
--------------------

Since arbitrary blobs or clobs can be attached to an entity, it is
necessary for clients to have some way to differentiate what it can
parse. In many cases, the name might be a simple reminder for a user to
find the file s/he has annotated. Applications, however, will most
likely want to define a namespace, like
``http://name-of-application-provider.com/name-of-application/file-type/version``.
Queries can then be produced which search for the proper namespace or
match on a part of the name space:

::

       iQuery.findAllByQuery("select annotation from FileAnnotation where "+
        "name like 'http://name-of-application-provider.com/name-of-application/%'");

Tags will most likely begin without a namespace. As a tag gets escalated
to a common vocabulary, it might make sense to add a possibly
site-specific namespace with more well-defined semantics.

Descriptions
------------

Unlike the previous, ``ImageAnnotation`` and ``DatasetAnnotation``
types, the new structured annotations do not have a description field.
The single description field was limited for multi-user scenarios, and
can be fully replaced by ``TextAnnotations`` attached to another
annotation.

::

       FileAnnotation fileAnnotation = …;
       TextAnnotation description = …;
       fileAnnotation.linkAnnotation(description);

Examples
--------

Examples of creating various type of Annotations can also be found on the
:doc:`Java </developers/Java>` and :doc:`Python </developers/Python>` pages.

Basics
^^^^^^

::

     import ome.model.IAnnotated;
     import ome.model.annotations.FileAnnotation;
     import ome.model.annotations.TagAnnotation;
     import ome.model.core.OriginalFile;
     import ome.model.display.Roi;

     List<Annotation> list = iAnnotated.linkedAnnotationList();
     // do something with list

Attaching a tag
^^^^^^^^^^^^^^^

::

      TagAnnotation tag = new TagAnnotation();
      tag.setTextValue("interesting");
      
      Roi roi = …; // Some region of interest
      ILink link = roi.linkAnnotation(tag);
      
      iUpdate.saveObject(link);

Attaching a file
^^^^^^^^^^^^^^^^

::

     // or attach something new
     OriginalFile myOriginalFile = new OriginalFile();
     myOriginalFile.setName("output.pdf");
     // upload PDF

     FileAnnotation annotation = new FileAnnotation();
     annotation.setName("http://example.com/myClient/analysisOutput");
     annotation.setFile(myOriginalFile);

     ILink link = iAnnotated.linkAnnotation(annotation)
     link = iUpdate.saveAndReturnObject(link);

All write changes are intended to occur through the IUpdate interface,
whereas searching should be significantly easier through ome.api.Search
than IQuery.


.. seealso::

    |ExtendingOmero|
    
    :doc:`KeyValuePairs`

