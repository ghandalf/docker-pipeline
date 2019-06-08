# Nexus installation

This document explains how Nexus is configure and how to access it.

## Diagram of the actual configuration

![Nexus repositories](../../resources/presentation/architecture/stack/Docker/nexus/NexusComponents.png)

## Maven Repositories

ghandalf-internal-releases (hosted): this repository contains only the releases that we tags from a push in GitLab or a build in Jenkins.
ghandalf-internal-snapshots (hosted): this repository contains the snapshots provide by our internal projects, like ghandalf-dot-com 6.0.0-SNAPSHOTS
ghandalf-old-releases (proxy): this repository links the old repository to this new one. It will be removed once the migration will be completed.
ghandalf-old-snapshot (proxy): this repository links the old repository to this new one. It will be removed once the migration will be completed. 
ghandalf-releases (proxy): major releases from the outside world.
ghandalf-snapshots (proxy): major snapshots from the outside world.

ghandalf-central (group): where we can find our internal and external libraries used by our projects.
blob-store: where maven's artifacts will be stored. Maven uses the default store.

## Npm Repositories
ghandalf-npm-internal-releases (hosted): this repository contains our JavaSript, TypeScript, React, and NodeJs projects
ghandalf-npm-releases (proxy): this repository is our proxy for external libraries: https://registry.npmjs.org
ghandalf-npm-central (group): this is where you can find the list of our internal and external libraries used in our projects.
npm-blob-store : where npm's artifacts will be stored.

## User

A user has been created to push from Jenkins in ghandalf-internal-snapshots and ghandalf-internal-releases.
The username is nexus, and the password can be found by the root user in the .hidden/nexus/.pwd file.