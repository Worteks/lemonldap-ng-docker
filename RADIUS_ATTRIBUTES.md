# RADIUS ATTRIBUTES

## Install patch and configure

This patch is provided as a zip file to be unzipped within lemonldap-ng-docker-master directory :

```
cd lemonldap-ng-docker-master
unzip ../radius_patch.zip
```

Current patch provides patch/radiusexportedvars.ini with example values to be edited before docker build.

Once done follow README.md as usual.

## General

### Configuration

Within conf ini a **radiusExportedVars** hashmap has to be populated with key => value mapping within ```[portal]``` section.

key ( ex myradius_id2 ) is name of variable within session, this session attribute can then be used for SSO pruposes.

value ( ec Callback-Id ) is radius attribute name to collect.

after ```[portal]]``` section keyword and before any other section :

```
radiusExportedVars={\
    'myradius_id1' => 'Callback-Id',\
    'myradius_id2' => 'Callback-Number'\
}
```

On docker install conf ini file is within local volume  /etc/lemonldap-ng/ of the container in file 
```/etc/lemonldap-ng/lemonldap-ng.ini```.

File patch/radiusexportedvars.ini contains radiusExportedVars configuration that will be copied
to container at build time and injected in initial configuration at run time.

You can edit this file but it will copied at build time so any change later will require an action
on docker volume, see Notes.

## Notes

### This patch

With this patch there is no way to configure **radiusExportedVars** within manager it can be done only in lemonldap-ng.ini
configuration file.

This will be integrated as part of  https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2819. . 
When this feature will be delivered officialy current patch will be fully obsolete.

### Docker volume

To copy local files to docker volume you need to use ```sudo docker cp file1 container:file2```

where container, file1 file2 are respectively the container identifier, local file and file within
container.

### Within Manager

A Radius authentication should be setup with a valid radius server

See https://lemonldap-ng.org/documentation/latest/authradius.html documentation.


### Dependencies

Radius relies on ```Authen::Radius``` then Dockerfile will retrieve with debian package ```libauthen-radius-perl```.

To be able to set radius attributes name that will be set in session ```Authen::Radius``` library requires to have a /etc/raddb/dictionary 
that will contain all attribute or will reference import of other dictionary file.

This patch contains the full set of dictionaries as provided by freeradius 3.0 version within freeradius/dicitonaries and those will be
copied within docker image /etc/raddb. This can be tailored to select only relevant dictionaries to limit memory footprint.

Updated dictionaries can be found here : https://github.com/FreeRADIUS/freeradius-server/tree/master/share/dictionary .

### Code

This patch comes with ```Lemonldap:NG:Portal:Auth:Radius.pm``` library that is used when radius authentication is used, this is where actual
session population occurs.

Radius attributes are captured at radius authentication time only, if configuration change this won't change attribute mapping until a
brand new session is created using Radius Authentication.

### Remark

this patch was created using ./create_zip_patch.sh.

-- 22th november 2022 by worteks
