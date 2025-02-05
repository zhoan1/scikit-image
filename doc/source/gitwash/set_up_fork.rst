.. _set-up-fork:

==================
 Set up your fork
==================

First you follow the instructions for :ref:`forking`.

Overview
========

::

   git clone git@github.com:your-user-name/scikit-image.git
   cd scikit-image
   git remote add upstream https://github.com/scikit-image/scikit-image.git

In detail
=========

Clone your fork
---------------

#. Clone your fork to the local computer with ``git clone
   git@github.com:your-user-name/scikit-image.git``
#. Investigate.  Change directory to your new repo: ``cd scikit-image``. Then
   ``git branch -a`` to show you all branches.  You'll get something
   like::

      * main
      remotes/origin/main

   This tells you that you are currently on the ``main`` branch, and
   that you also have a ``remote`` connection to ``origin/main``.
   What remote repository is ``remote/origin``? Try ``git remote -v`` to
   see the URLs for the remote.  They will point to your github fork.

   Now you want to connect to the upstream `scikit-image github`_ repository, so
   you can merge in changes from trunk.

.. _linking-to-upstream:

Linking your repository to the upstream repo
--------------------------------------------

::

   cd scikit-image
   git remote add upstream https://github.com/scikit-image/scikit-image.git

``upstream`` here is just the arbitrary name we're using to refer to the
main `scikit-image`_ repository at `scikit-image github`_.

Note that we've used ``https://`` for the URL rather than ``git@``.  The
``https://`` URL is read only.  This means we that we can't accidentally
(or deliberately) write to the upstream repo, and we are only going to
use it to merge into our own code.

Just for your own satisfaction, show yourself that you now have a new
'remote', with ``git remote -v show``, giving you something like::

   upstream	https://github.com/scikit-image/scikit-image.git (fetch)
   upstream	https://github.com/scikit-image/scikit-image.git (push)
   origin	git@github.com:your-user-name/scikit-image.git (fetch)
   origin	git@github.com:your-user-name/scikit-image.git (push)

.. include:: links.inc
