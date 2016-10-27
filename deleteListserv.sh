#!/usr/bin/bash
#
#  This script will delete a mailman listserv & the associated LDAP entries.
#  
#  It calls /opt/mailman/bin/rmlist:
#  rmlist -a listname 
#
if [ $# -ne 1 ]; then
   echo "usage: deleteListserv.sh listname"
   exit
fi
if [ ${1} = "-h" ]; then
   echo "usage: deleteListserv.sh listname"
   exit
fi

LDIF=/usr/local/admin/dls.ldif
if [ -f ${LDIF} ]; then
   rm -i ${LDIF}
fi

var=`ldapsearch -Lb o=kutztown.edu cn=${1} dn`
if [ "${var}" != "" ]; then
   /opt/mailman/bin/rmlist -a ${1}

   echo "dn: cn=${1},ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-admin,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-bounces,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-confirm,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-join,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-leave,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-owner,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-request,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-subscribe,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
   echo >> $LDIF
   echo "dn: cn=${1}-unsubscribe,ou=groups,o=kutztown.edu" >> $LDIF
   echo "changetype: delete" >> $LDIF
 
   PASSWORD=`cat /usr/local/admin/conf/conf.dir` 
   ldapmodify -h sbv100-3.kutztown.edu -D "cn=directory manager" -w $PASSWORD -f ${LDIF}
else 
   echo "listname ${1} does not exist, please try a different name"
   echo "usage: deleteListserv.sh listname"
   exit
fi
